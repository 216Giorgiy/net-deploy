using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;

namespace deploy.Models {
	public class Log : IDisposable {
		string _appid;
		string _logPath;
		StringBuilder _sb = new StringBuilder();
		object sync = new object();

		public Log(string appid) {
			_appid = appid;
			_logPath = FileDB.LogPath(appid);
			Set(appid, this);
		}

		public void Write(string message) {
			lock(sync) {
				_sb.AppendLine(message);
			}
		}

		public string Text {
			get {
				lock(sync) {
					return _sb.ToString();
				}
			}
		}

		public void Dispose() {
			if(_logPath != null && _sb != null) {
				try {
					File.WriteAllText(_logPath, _sb.ToString());
				} catch(IOException e) {
					LogService.Error(e);
				}
				Remove(_appid);
			}
		}

		static Dictionary<string, Log> logs = new Dictionary<string, Log>();
		static object logsSync = new object();
		static Log Get(string appid) {
			Log log;
			lock(logsSync) {
				if(!logs.TryGetValue(appid, out log)) return null;
				return log;
			}
		}
		static void Set(string appid, Log log) {
			lock(logsSync) {
				logs[appid] = log;
			}
		}

		/// <returns>True if the log was found and removed, otherwise false.</returns>
		static bool Remove(string appid) {
			lock(logsSync) {
				return logs.Remove(appid);
			}
		}

		public static string GetText(string appid) {
			var log = Get(appid);
			if(log != null) return log.Text;
			try {
				return File.ReadAllText(FileDB.LogPath(appid));
			} catch {
				return null;
			}
		}
	}
}