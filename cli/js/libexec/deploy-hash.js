var core = require('../lib/core.js')

exports.exec = function(username) {
  if(!username) {
    core.abort('username is required');
  }

  console.log("hash: " + username);
}
