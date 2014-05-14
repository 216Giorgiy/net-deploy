using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Hosting;
using System.Security.Cryptography;

namespace deploy.Models {
	public class Auth {
		// returns success, error message
		public static Tuple<bool, string> Validate(string username, string password) {
			string data;
			if(!Users.TryGetValue(username, out data)) {
				return Tuple.Create(false, "Couldn't find that user");
			}

			var split = data.Split(':');
			var iterations = int.Parse(split[0]);
			var salt = Convert.FromBase64String(split[1]);
			var hash = Convert.FromBase64String(split[2]);

			if(!Validate(password, iterations, salt, hash)) {
				return Tuple.Create(false, "Wrong password");
			}

			return Tuple.Create(true, "");
		}

		static bool Validate(string password, int iterations, byte[] salt, byte[] hash) {
			var actual = PBKDF2(password, salt, iterations, hash.Length);
			return ConstTimeEquals(actual, hash);
		}

		// prevent timing attack by comparing in constant time
		static bool ConstTimeEquals(byte[] a, byte[] b) {
			uint diff = (uint)a.Length ^ (uint)b.Length;
			for(int i = 0; i < a.Length && i < b.Length; i++)
				diff |= (uint)(a[i] ^ b[i]);
			return diff == 0;
		}

		static byte[] PBKDF2(string password, byte[] salt, int iterations, int outputBytes) {
			var pbkdf2 = new Rfc2898DeriveBytes(password, salt);
			pbkdf2.IterationCount = iterations;
			return pbkdf2.GetBytes(outputBytes);
		}

		static Dictionary<string, string> Users = LoadUsers();
		static Dictionary<string, string> LoadUsers() {
			var users = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
			var path = HostingEnvironment.MapPath("~/App_Data/users.txt");
			if(System.IO.File.Exists(path)) {
				foreach(var line in System.IO.File.ReadAllLines(path)) {
					if(line.StartsWith("#")) continue;
					if(string.IsNullOrWhiteSpace(line)) continue;
					var split = line.Trim().Split(' ');
					users.Add(split[0], split[1]);
				}
			}
			return users;
		}
	}
}