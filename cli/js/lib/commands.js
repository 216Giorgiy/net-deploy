var fs = require('fs');
var path = require('path');

var libexec = path.normalize(__dirname + "/../libexec");

function fileRegexp(appname) {
  return new RegExp('^' + appname + '\-(.+)\.js$')
}

function files(appname) {
  var re = fileRegexp(appname);
  return fs.readdirSync(libexec).filter(function(file) {
    return re.test(file);
  });
}

exports.get = function(appname) {
  var re = fileRegexp(appname);
  return files(appname).map(function(file) {
    return re.exec(file)[1];
  });
}

exports.exec = function(appname, cmd, arguments) {
  var file = path.join(libexec, appname + "-" + cmd + ".js");
  var script = require(file);

  script.exec.apply(this, arguments);
}

var cmdpath = exports.path = function(appname, cmdname) {
  return path.join(__dirname, '..', 'libexec', appname + '-' + cmdname + '.js');
}

exports.text = function(appname, cmdname) {
  var filePath = cmdpath(appname, cmdname);
  return fs.readFileSync(filePath, { encoding: 'utf8' });
}
