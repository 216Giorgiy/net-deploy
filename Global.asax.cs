﻿using deploy.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace deploy {
	// Note: For instructions on enabling IIS6 or IIS7 classic mode, 
	// visit http://go.microsoft.com/?LinkId=9394801

	public class MvcApplication : System.Web.HttpApplication {
		public static void RegisterGlobalFilters(GlobalFilterCollection filters) {
			filters.Add(new HandleErrorAttribute());
		}

		protected void Application_Start() {
			AreaRegistration.RegisterAllAreas();

			RegisterGlobalFilters(GlobalFilters.Filters);
			
			RouteConfig.RegisterRoutes(RouteTable.Routes);
			BundleConfig.RegisterBundles(BundleTable.Bundles);

            LogService.Info("Application start");
		}

        protected void Application_Error(object sender, EventArgs e) {
            HttpApplication application = (HttpApplication)sender;
            Exception error = application.Server.GetLastError();

            string formStr = "";
            foreach(var formVar in application.Context.Request.Form.AllKeys) {
                formStr += formVar + ": " + application.Context.Request.Form[formVar] + Environment.NewLine;
            }

            string message = error.GetLogMessage();
            if(formStr.Length > 0) {
                message += Environment.NewLine + "Posted values: " + Environment.NewLine + formStr;
            }

            LogService.Fatal(message);
        }
	}
}