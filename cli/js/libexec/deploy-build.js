// Usage: deploy [build]
// Summary: Deploy to server
// Help: Use this command to deploy the committed changes on the server.
//
// This is the default command, so you can just type 'deploy' to run it.

var core = require('../lib/core');
var creds = require('../lib/creds')

exports.exec = function() {
  var url = core.apiurl('build');

  if(!url) {
  	core.abort('no deploy project found');
  }

  console.log('authenticating...');
  var auth = creds.ensure(null, null, function(username, password) {
    console.log('starting build...')
    core.request(url, username, password, function(err, res) {
      console.log('server state: who knows?')
    })
  });
}
