#! /usr/bin/env node
var commands = require('./lib/commands.js');

var appname = 'deploy';
var args = process.argv.slice(2);
var cmd = args[0] || 'build';
var cmdArgs = args.slice(1);

var cmds = commands.get(appname);

if(['-h', '--help', '/?'].indexOf(cmd) > -1) {
  console.log("help not implemented");
} else if(cmds.indexOf(cmd) > -1) {
  commands.exec(appname, cmd, cmdArgs);
} else {
  console.log(appname + ": '" + cmd + "' isn't a " + appname + " command. " +
    "see '" + appname + " help'");
}
