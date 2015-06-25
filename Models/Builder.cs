using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Configuration;
using System.Text.RegularExpressions;
using System.Web.Hosting;
using System.Net;

namespace deploy.Models {
	public class Builder {
		public Action<string> LogHook;

		string _id;
		string _appdir;
		Dictionary<string, string> _config;
		string _logfile;
		string _sourcedir;
        string _workingdir;
        string _buildconfig;

		public Builder(string id) {
			_id = id;
		}

		public void Build() {
			lock(AppLock.Get(_id)) {
				Init();

				FileDB.AppState(_id, "building");
				try {					
					GitUpdate();
					NugetRefresh();
                    CopyWorking();
                    Transform();
					Msbuild();
					Deploy();
					WarmUp();

					Log("-> build completed");
					FileDB.AppState(_id, "idle");
				} catch(Exception e) {
					Log("ERROR: " + e.ToString());
					Log("-> build failed!");
					FileDB.AppState(_id, "failed");
					throw;
				}

			}
		}

		private void Init() {
			var state = FileDB.AppState(_id);
			if(state.Item2 != "idle" && state.Item2 != "failed") throw new Exception("Can't build: current state is " + state.Item2);

			_appdir = FileDB.AppDir(_id);
			_config = FileDB.AppConfig(_id);
			_logfile = Path.Combine(_appdir, "log.txt");
			_sourcedir = Path.Combine(_appdir, "source");
            _workingdir = Path.Combine(_appdir, "working");

            if(!_config.TryGetValue("build_config", out _buildconfig)) _buildconfig = "Release";

			if(File.Exists(_logfile)) File.Delete(_logfile); // clear log
		}

		private void GitUpdate() {
			var giturl = _config["git"];
			string git_branch = null;
			_config.TryGetValue("git_branch", out git_branch);
			if(string.IsNullOrWhiteSpace(git_branch)) {
				git_branch = null;
			}
			if(string.IsNullOrEmpty(giturl)) throw new Exception("git missing from config");


			if(!Directory.Exists(_sourcedir)) {
				Directory.CreateDirectory(_sourcedir);
				Log("-> cloning git repo");
				var git_branch_param = "";
				if(git_branch != null) {
					git_branch_param = " -b " + git_branch;
				}

				Cmd.Run("git clone " + giturl + " source" + git_branch_param,
					runFrom: _appdir, logPath: _logfile).EnsureCode(0);
			} else {
				Log("-> pulling git changes");
				if(git_branch != null) {
					// force pull for branches that might have been rebased
					Cmd.Run("git fetch --all", runFrom: _sourcedir, logPath: _logfile).EnsureCode(0);
					Cmd.Run("git reset --hard origin/" + (git_branch ?? "master"),
						runFrom: _sourcedir, logPath: _logfile).EnsureCode(0);
				} else {
					// quick pull
					Cmd.Run("git pull", runFrom: _sourcedir, logPath: _logfile).EnsureCode(0);
				}
				
			}
		}

		private void NugetRefresh() {
			Log("-> refreshing nuget packages");
			Cmd.Run("echo off && for /r . %f in (packages.config) do if exist %f echo found %f && nuget i \"%f\" -o packages", runFrom: _sourcedir, logPath: _logfile)
				.EnsureCode(0);
		}

        private void CopyWorking() {
            Log("-> copying to working dir");

            if(!Directory.Exists(_workingdir)) Directory.CreateDirectory(_workingdir);

            Cmd.Run("\"robocopy . \"" + _workingdir + "\" /s /purge /nfl /ndl /xd bin obj .git\"", runFrom: _sourcedir, logPath: _logfile);
        }

        private void Transform() {
            Log("-> transforming web.configs");

            var msbuild = ConfigurationManager.AppSettings["msbuild"];

            var scriptpath = Path.Combine(HostingEnvironment.ApplicationPhysicalPath, "Scripts\\msbuild");

            var candidates = Directory.GetFiles(_workingdir, "web.config", SearchOption.AllDirectories);
            //Log("     found " + candidates.Length + " web.config files");
            foreach(var webConfig in candidates) {
                var dir = Path.GetDirectoryName(webConfig);
                var transform = Path.Combine(dir, "web." + _buildconfig + ".config");
                if(File.Exists(transform)) {
                    Cmd.Run("\"\"" + msbuild + "\""
                        + " /p:Dir=\"" + dir + "\""
                        + " /p:Source=" + Path.GetFileName(webConfig)
                        + " /p:Transform=" + Path.GetFileName(transform)
                        + " transform.msbuild\"", scriptpath, _logfile).EnsureCode(0);

                    // delete transforms
                    foreach(var trsfm in Directory.GetFiles(dir, "web.*.config", SearchOption.TopDirectoryOnly)) {
                        File.Delete(trsfm);
                    }
                    File.Delete(webConfig);
                    File.Move(webConfig + ".transformed", webConfig);
                }
            }
        }

		private void Msbuild() {
			Func<string, bool> hasFiles = (string s) => {
				return Directory.GetFiles(_workingdir, s).Length > 0;
			};

			if(!hasFiles("*.sln") && !hasFiles("*.csproj") && !hasFiles("*.vbproj")) {
				Log("-> nothing to build");
				return; // nothing to build
			}

            var msbuild = _config["msbuild"];

			var buildver = Regex.Replace(msbuild, @".*\\Microsoft.NET\\", @"..\");

			Log("-> building with " + buildver + " (" + _buildconfig + ")");

			string parameters = "";
            if(_buildconfig != null) {
                parameters += " /p:Configuration=" + _buildconfig;
			}

            Cmd.Run("\"" + msbuild + "\"" + parameters, runFrom: _workingdir, logPath: _logfile)
				.EnsureCode(0);
		}

		private void Deploy() {
			string deploy_base, deploy_to, deploy_ignore = null;

			_config.TryGetValue("deploy_base", out deploy_base);
			_config.TryGetValue("deploy_to", out deploy_to);
			_config.TryGetValue("deploy_ignore", out deploy_ignore);

			if(string.IsNullOrWhiteSpace(deploy_to)) throw new Exception("deploy_to not specified in config");

			Log("-> deploying to " + deploy_to);

			var source = string.IsNullOrEmpty(deploy_base) ? _workingdir : Path.Combine(_workingdir, deploy_base);

			if(!Directory.Exists(deploy_to)) Directory.CreateDirectory(deploy_to);

			List<string> simple;
			List<string> paths;
			GetIgnore(source, deploy_to, deploy_ignore, out simple, out paths);

			var xf = new List<string>(simple);
			var xd = new List<string>(simple);
			xd.AddRange(paths);

			var xf_arg = xf.Count > 0 ? " /xf " + string.Join(" ", xf) : null;
			var xd_arg = xd.Count > 0 ? " /xd " + string.Join(" ", xd) : null;

			Cmd.Run("\"robocopy . \"" + deploy_to + "\" /s /purge /nfl /ndl " + xf_arg + xd_arg + "\"", runFrom: source, logPath: _logfile);
		}

		private void WarmUp() {
			string warmup;
			_config.TryGetValue("warmup_url", out warmup);
			if(!string.IsNullOrEmpty(warmup)) {
				Log("-> warming up");
				var req = WebRequest.CreateHttp(warmup);
				var res = req.GetResponse() as HttpWebResponse;
			}
		}

		private void GetIgnore(string source, string dest, string ignore_str, out List<string> simple, out List<string> paths) {
			simple = new List<string>();
			paths = new List<string>();

			if(string.IsNullOrWhiteSpace(ignore_str)) return; // nothing to ignore

			var ignore = Regex.Split(ignore_str, @"(?<!\\)\s+"); // split on spaces, unless they're escaped with \

			var path_segments = new List<string>();
			foreach(var i in ignore) {
				var part = i.Replace(@"\ ", " ");
				if(part.Contains("\\")) path_segments.Add(part);
				else simple.Add(QuoteSpacesInPath(part));
			}

			if(path_segments.Count > 0) {
				// have to manually look for directories that match the path segment
				foreach(var seg in path_segments) {
					var sourcepath = Path.Combine(source, seg);
					if(File.Exists(sourcepath) || Directory.Exists(sourcepath)) paths.Add(QuoteSpacesInPath(sourcepath.TrimEnd('\\')));
					else {
						var destpath = Path.Combine(dest, seg);
						if(File.Exists(destpath) || Directory.Exists(destpath)) paths.Add(QuoteSpacesInPath(destpath.TrimEnd('\\')));
					}
				}
			}
		}

		private static string QuoteSpacesInPath(string path) {
			return Regex.Replace(path, @"^(\S*\s+)(\S*\s*)*", "\"$&\"");
		}

		private void Log(string message) {
			File.AppendAllText(_logfile, message + "\r\n");
			if(LogHook != null) LogHook(message);
		}
	}
}