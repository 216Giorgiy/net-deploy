var colors = require('colors');
var readline = require('readline');

exports.abort = function(msg) {
  console.log(msg.red);
  process.exit(1);
}

exports.input = function(prompt, callback) {
  var rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  rl.on('line', function(line) {
    rl.close();
    callback(null, line);
  });

  rl.write(prompt);
  rl.resume();
}

exports.getpass = function(prompt, callback) {
  process.stdout.write(prompt);

  var stdin = process.stdin;
  stdin.resume();
  stdin.setRawMode(true);
  stdin.resume();
  stdin.setEncoding('utf8');

  var password = '';
  stdin.on('data', function (ch) {
    switch (ch) {
      case "\n":
      case "\r":
      case "\u0004":
        // They've finished typing their password
        process.stdout.write('\n');
        stdin.setRawMode(false);
        stdin.pause();
        callback(false, password);
        break;
      case "\u0003":
        // Ctrl-C
        callback(true);
        break;
      case "\u007F":
        // Backspace
        if(password.length > 0) {
          process.stdout.write('\033[<1>D'); // back one column
          process.stdout.write(' ');
          process.stdout.write('\033[<1>D'); // back one column
          password = password.substring(0, password.length - 1)
        }
        break;
      default:
        // More password characters
        process.stdout.write('*');
        password += ch;
        break;
    }
  });
}
