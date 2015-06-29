// Usage: deploy status
// Summary: Display status info

var core = require('../lib/core');
var creds = require('../lib/creds');
var table = require('text-table');

exports.exec = function() {
  var root = core.root();
  var git_root = core.git_root();

  if(!root) {
    if(git_root) {
      console.log("git root: " + git_root);
      console.log("no deploy config. use 'deploy init'");
    } else {
      console.log("no deploy config, and not inside a git repo");
    }
    process.exit(1);
  } else {
    var url = core.baseurl();

    var vals = [
      [ 'app:', core.app() ],
      [ 'deploy URL:', url ],
      [ 'root:', root ]
    ];

    var host = core.host(url);
    var auth = creds.get(host);

    if(auth != null) {
      var username = auth[0];
      var password = auth[1];
      var maskpass = password.replace(/./g, '*');
      vals.push(['credentials:', username + ':' + maskpass ])

      core.getstate(username, password, function(state) {
        vals.push(['server state:', state.state ])
        console.log(table(vals));
      })
    } else {
      vals.push(['credentials:', '(none saved)']);
      console.log(table(vals));
    }

  }
}
