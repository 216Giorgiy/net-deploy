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
				date = state.Item1 == null ? (int?)null: (int)(state.Item1.Value - new DateTime(1970,1,1)).TotalMilliseconds
			}, JsonRequestBehavior.AllowGet);
		}
	}
}