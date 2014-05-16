using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using deploy.Models;
using System.Web.Security;
using System.Configuration;
using System.Web.UI;

namespace deploy.Controllers {
    public class RootController : BaseController {

        [OutputCache(Duration = 0)]
        public ActionResult Login() {
            return View();
        }

        public ActionResult Logout() {
            FormsAuthentication.SignOut();
            TempData["flash"] = "You've logged out";
            return RedirectToAction("login");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(string username, string password, string returnUrl) {

			var res = Auth.Validate(username, password);
			if(res.Item1) {
				int oneDay = 24 * 60;
				var ticket = new FormsAuthenticationTicket(username, false, oneDay);

				HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket));
				Response.Cookies.Add(cookie);

				LogService.Info("successful login for " + username);
				if(!string.IsNullOrEmpty(returnUrl)) return Redirect(returnUrl);
				return RedirectToAction("index");
			}

            LogService.Warn("failed login attempt for " + username);
            TempData["flash"] = "Invalid login: " + res.Item2;
            return View();
        }

        [Authorize]
        public ActionResult Index() {
            var apps = FileDB.Apps();

            return View(apps);
        }

    }
}