using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace deploy.Controllers {

	[UseRequireHttpsFromAppSettings]
	public class APIController : Controller {

		public ActionResult Detail(string id) {

			return View();
		}
	}
}