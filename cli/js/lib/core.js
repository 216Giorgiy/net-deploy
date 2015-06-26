var colors = require('colors');
var readline = require('readline');

exports.abort = function(msg) {
  console.log(msg.red);
  process.exit(1);
  return null;
}
