// Usage: deploy help <command>
// Summary: Show help for a command
var commands = require('../lib/commands.js');
var help = require('../lib/help.js');
var fs = require('fs');
var path = require('path')

var appname = 'deploy';

function printHelp(cmd) {
  var text = commands.text(appname, cmd);

  var usage = help.usagetext(text);
  var helptext = help.helptext(text);

  if(usage) {
    console.log(usage);
  }
  if(helptext) {
    console.log(helptext);
  }
}

function printSummaries(cmds) {
  for(var i = 0; i < cmds.length; i++) {
    var cmd = cmds[i];
    var text = commands.text(appname, cmd);
    var summary = help.summarytext(text);
    console.log(cmd + ': ' + summary);
  }
}

exports.exec = function(cmd) {
  var cmds = commands.get(appname);

  if(!cmd) {
    console.log("usage: " + appname + " <command> [args]");
    console.log();
    console.log("Some useful commands are:");
    printSummaries(cmds);
    console.log();
    console.log("type '" + appname + " help <command>' to get help for a specific command");
  } else if(cmds.indexOf(cmd) > -1) {
    printHelp(cmd);
  } else {
    console.log(appname + " help: no such command '" + cmd + "'");
    process.exit(1);
  }
}
