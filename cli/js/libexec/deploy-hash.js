// Usage: deploy hash <username>
// Summary: Get a hashed user configuration entry
// Help: This command is used to generate an entry to be used in the users configuration file on the deploy web server.
//
// It will prompt you to enter a password for the given username.
//
// It outputs a line in the format "username iterations:salt:hash"

var core = require('../lib/core');
var help = require('../lib/help');
var pbkdf2 = require('pbkdf2');
var crypto = require('crypto');
var read = require('read');

const ITERATIONS = 1000;
const SALT_SIZE = 24;
const HASH_SIZE = 24;

exports.exec = function(username) {
  if(!username) {
    console.log('username is required');
    console.log(help.usage(__filename));
    process.exit(1);
  }

  read({ prompt: 'password: ', silent: true, replace: '*' }, function(err, password) {
    if(err) { process.exit(1); }

    var salt = crypto.randomBytes(SALT_SIZE);
    var hash = pbkdf2.pbkdf2Sync(password, salt, ITERATIONS, HASH_SIZE, 'sha1');

    console.log(username + ' ' + ITERATIONS + ':' +
      salt.toString('base64') + ':' + hash.toString('base64'));
  });
}
