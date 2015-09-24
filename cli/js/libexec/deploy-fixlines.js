// Usage: deploy fixlines
// Summary: Convert Unix line-endings
// Help: Checks modified files for those that contain Unix line-endings,
//       and converts them to Windows line-endings.

// Adapted from answer by JasonMArcher here:
// http://stackoverflow.com/questions/724083/unix-newlines-to-windows-newlines-on-windows

var core = require('../lib/core');
var path = require('path');
var fs = require('fs');
var child_process = require('child_process');

exports.exec = function() {
  var root = core.root();
  if(!root) {
    core.abort('no deploy project found');
  }

  var changes = child_process.execSync('git status --porcelain',
    { stdio: 'pipe'} ).toString().trim().split(/\r?\n/);

  // console.log('changes: ' + changes);

  // only process files that Git thinks are text
  var non_binary = child_process.execSync('git grep -I --name-only -e "" -- .',
    { stdio: 'pipe', cwd: root }).toString().split(/\r?\n/);

  // console.log('non-binary: ' + non_binary);

  for(var i = 0; i < changes.length; i++) {
    var change = changes[i];
    var sep = /\w\s/.exec(change).index + 1;

    var type = change.substring(0,sep).trim();
    var relpath = change.substring(sep+1);

    // console.log(change + ' -- type: ' + type + ', path: ' + relpath);

    if(type != 'D' && non_binary.indexOf(relpath) != -1) {
      var fullpath = path.join(root, relpath);
      var content = fs.readFileSync(fullpath, { encoding: 'utf8' });
      if(/[^\r]\n/m.test(content)) {
        process.stdout.write('Fixing line endings for ' + relpath + '...');
        content = content.replace(/\n/g, '\r\n'); // replaces \n or \r\n
        fs.writeFileSync(fullpath, content);
        console.log('done.')
      }
    }
  }
}
