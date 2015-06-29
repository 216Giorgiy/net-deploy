// Usage: deploy status
// Summary: Display status info

var core = require('../lib/core');

exports.exec = function() {
  var root = core.root();
  var git_root = core.git_root();

  if(!root) {
    if(git_root) {
      console.log("no deploy config. use 'deploy init'");
    } else {
      console.log("no deploy config, and not inside a git repo");
      process.exit(1);
    }
  } else {
    console.log("App: " + core.app());
    console.log("Deploy URL: " + core.baseurl());
    console.log("Local: " + root);
  }
}
