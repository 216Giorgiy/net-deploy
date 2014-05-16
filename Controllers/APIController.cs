using deploy.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace deploy.Controllers {

	[ConditionalHttps]
	[BasicAuth]
	public class APIController : Controller {

		public ActionResult Detail(string id) {
			var state = FileDB.AppState(id);

			return Json(new {
				state = state.Item2,
				date = state.Item1.JSDate()
			}, JsonRequestBehavior.AllowGet);
		}

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