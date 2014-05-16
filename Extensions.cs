using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace deploy {
	public static class Extensions {

		// milliseconds since Jan 1, 1970
		public static long? JSDate(this DateTime? date) {
			if(date == null) return null;

			return (long)(date.Value - new DateTime(1970, 1, 1)).TotalMilliseconds;
		}
	}
}