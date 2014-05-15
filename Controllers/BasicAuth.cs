using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Mvc;

namespace deploy.Controllers {
	public class BasicAuth : FilterAttribute, IAuthorizationFilter {

		const string Realm = "deploy";
		public static Func<string, string, bool> Authenticate = (username, password) =>
			Models.Auth.Validate(username, password).Item1;

		public void OnAuthorization(AuthorizationContext filterContext) {
			var auth = filterContext.RequestContext.HttpContext.Request.Headers["Authorization"];
			if(!string.IsNullOrEmpty(auth)) {
				string[] authParts = auth.Split(' ');

				if(authParts.Length == 2 && authParts[0].ToLower() == "basic") {
					try {
						var decodedBytes = Convert.FromBase64String(authParts[1]);
						var decoded = Encoding.UTF8.GetString(decodedBytes);

						string[] parts = decoded.Split(':');
						if(Authenticate(parts[0], parts[1])) return; // all good
					} catch {
						// something was invalid
					}
				}
			}

			AuthorizationRequired(filterContext);
		}

		public void AuthorizationRequired(AuthorizationContext filterContext) {
			var response = filterContext.RequestContext.HttpContext.Response;

			response.StatusCode = 401;
			response.StatusDescription = "Authorization Required";
			response.Headers["WWW-Authenticate"] = @"Basic realm=""" + Realm + @"""";
			response.SuppressFormsAuthenticationRedirect = true;

			filterContext.Result = new EmptyResult();
			filterContext.HttpContext.ApplicationInstance.CompleteRequest();
		}
	}
}