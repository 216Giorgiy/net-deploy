using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Dynamic;
using deploy.Models;
using System.Threading.Tasks;

namespace deploy.Controllers {
	
	public class AppsController : BaseController {
		static HashSet<string> Tokens = new HashSet<string>();

		[Authorize]
		public ActionResult Detail(string id) {
			ViewBag.id = id;
			ViewBag.state = FileDB.AppState(id);
			ViewBag.config = FileDB.AppConfig(id).SanitizeForDisplay();
			ViewBag.logcreated = FileDB.LogCreated(id);

			return View();
		}

		[Authorize]
		public ActionResult State(string id) {
			var state = FileDB.AppState(id);
			return Content(state.Item2, "text");
		}

		[Authorize]
		[HttpPost]
		public ActionResult Build(string id) {
			var context = System.Web.HttpContext.Current;
			var builder = new Builder(id);
			new Task(() => {
				try {
					builder.Build();
				} catch(Exception e) {
                    LogService.Fatal(e);
				}
			}).Start();;

			return RedirectToAction("detail", new { id = id });
		}

		[Authorize]
		public ActionResult Log(string id) {
			var text = Models.Log.GetText(id);
			if(text == null) return HttpNotFound("No log found");

			return Content(text, "text/plain");
		}

	}
}
