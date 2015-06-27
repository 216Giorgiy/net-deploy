// Usage: deploy init <app> <url> [options]
// Summary: Initialize a Git repo for deployment
// Help: Initializes a Git repo for deployment.
//
// Parameters:
//
//   <app>: the name of the app, must be present on the server
//   <url>: the URL of the deploy server
//
// Options:
//
//   --reinit: re-init a project that's already been init'd
var help = require('../lib/help');
var core = require('../lib/core');

exports.exec = function(app, url) {
  if(!app) {
    console.log('<app> is required');
    help.usage(__filename);
    process.exit(1);
  }

  if(!url) {
    console.log('<app> is required');
    help.usage(__filename);
    process.exit(1);
  }

  if(!/^https?:/i.test(url)) {
  	console.log("invalid url: " + url);
    process.exit(1);
  }

  var reinit = core.hasarg(arguments, '--reinit');

  if(core.root() && !reinit) {
    console.log('already initialized! use --reinit to change configuration');
  }

  var git_root = core.git_root();
  console.log(git_root);
}
