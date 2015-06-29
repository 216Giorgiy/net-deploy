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
var creds = require('../lib/creds');
var fs = require('fs');
var path = require('path');

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
    process.exit(1);
  }

  var git_root = core.git_root();

  url = url.replace(/\/$/, ''); // remove trailing slash

  var pingurl = core.apiurl('ping', url, 'global');
  console.log('pinging deploy server...')
  core.geturl(pingurl, null, null, function(statusCode, text) {
    if(text != 'net-deploy' || statusCode != 200) {
    	console.log(url + "doesn't look like a deploy server");
      process.exit(1);
    }

    creds.ensure(url, app, function(username, password) {
      var config = {
      	app: app,
      	url: url
      }

      var configPath = path.join(git_root, 'deploy.json');
      fs.writeFileSync(configPath, JSON.stringify(config, null, 2), { encoding: 'utf8' });

      console.log("initialized!");
    });
  });
}
