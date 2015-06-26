var core = require('../lib/core.js');
var creds = require('../lib/creds.js')

exports.exec = function() {
  var url = core.apiurl('build');

  if(!url) {
  	core.abort('no deploy project found');
  }

  console.log('authenticating...');
  var auth = creds.ensure(function(username, password) {
    console.log('starting build...')
    core.request(url, username, password, function(err, res) {
      console.log('server state: who knows?')
    })
  });
}
