var init = Date.now();

$(function() {
	$('.time').each(function(index, el) {
		$time = $(el);
		var date_ms = $time.data('date');
		if(!date_ms) return;
		var date = new Date(init + date_ms);

		var update = function() {
			var ms = Date.now() - date;
			var s = Math.round(ms / 1000);
			var m = Math.round(s / 60);
			var h = Math.round(m / 60);
			var d = Math.round(h / 24);

			var next_refresh = 10; // seconds

			if(d > 1) {
				$time.text(d + ' days ago');
				next_refresh = 10 * 60; // 10 minutes
			} else if(h > 1) {
				$time.text(h + ' hours ago');
				next_refresh = 1 * 60; // 1 minute
			} else if(m > 1) {
				$time.text(m + ' minutes ago');
				next_refresh = 10; // 10 seconds
			} else {
				$time.text(s + ' seconds ago');
				next_refresh = 1;
			}

			setTimeout(update, next_refresh * 1000);
		}
		update();
	});
});