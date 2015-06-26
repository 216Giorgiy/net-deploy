var core = require('../lib/core.js');
var creds = require('../lib/creds.js')

exports.exec = function() {
  var url = core.apiurl('build');

  console.log('authenticating...');
  var auth = creds.ensure(function(username, password) {
    console.log('starting build...')
    core.request(url, username, password, function(err, res) {
      console.log('server state: who knows?')
    })
  });
}
