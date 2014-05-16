using deploy.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace deploy.Controllers {

	[ConditionalHttps]
	public class APIController : Controller {

		// Get /api/global/ping from CLI to check if this is a deploy server
		public ActionResult Ping() {
			return Content("net-deploy", "text/plain");
		}

		[BasicAuth]
		public ActionResult Detail(string id) {
			var state = FileDB.AppState(id);

			return Json(new {
				state = state.Item2,
				date = state.Item1.JSDate()
			}, JsonRequestBehavior.AllowGet);
		}

		[BasicAuth]
		public ActionResult Test(string id) {
			Response.ContentType = "text/plain";
			for(var i = 0; i < 10; i++) {
				Response.Write("i: " + i + "\n");
				Response.Flush();
				System.Threading.Thread.Sleep(500);
			}
			return new EmptyResult();
		}
	}
}