using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Routing;
using System.Web.Mvc;

namespace deploy {
	public class RouteConfig {
		public static void RegisterRoutes(RouteCollection routes) {
			routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
			routes.IgnoreRoute("favicon.ico");

			routes.MapRoute("api_global", "api/global/{action}", new { controller = "api" });
			routes.MapRoute("api", "api/{id}/{action}", new { controller = "api", action = "detail" });
			
			routes.MapRoute("apps", "apps/{action}/{id}", new { controller = "apps", id = UrlParameter.Optional });

			routes.MapRoute(
				"Default", // Route name
				"{action}/{id}", // URL with parameters
				new { controller = "root", action = "index", id = UrlParameter.Optional } // Parameter defaults
			);
		}
	}
}