var colors = require('colors');

exports.abort = function(msg) {
  console.log(msg.red);
  process.exit(1);
}
