var core = require('../lib/core.js');
var pbkdf2 = require('pbkdf2');
var crypto = require('crypto');


const ITERATIONS = 1000;
const SALT_SIZE = 24;
const HASH_SIZE = 24;

exports.exec = function(username) {
  if(!username) {
    core.abort('username is required');
  }

  core.getpass('password: ', function(err, password) {
    if(err) { process.exit(1); }
    
    console.log("oh, so your password is " + password);
    var salt = crypto.randomBytes(SALT_SIZE);
    var hash = pbkdf2.pbkdf2Sync(password, salt, ITERATIONS, HASH_SIZE, 'sha1');

    console.log(username + ' ' + ITERATIONS + ':' +
      salt.toString('base64') + ':' + hash.toString('base64'));
  });
}
