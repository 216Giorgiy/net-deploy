var fs = require('fs');

var usagetext = exports.usagetext = function(text) {
  var m = /^\/\/ *Usage: ([^\r\n]*)$/mi.exec(text);
  if(m == null) return '';
  return "usage: " + m[1];
}

exports.helptext = function(text) {
  var m = /[\n^]\/\/ *Help:\s?((.|(\r?\n\/\/))*)/mi.exec(text);
  if(m == null) return '';
  return m[1].replace(/\/\/ */g, '');
}

exports.summarytext = function(text) {
  var m = /^\/\/ *Summary: ([^\r\n]*)$/mi.exec(text);
  if(m == null) return '';
  return m[1];
}

exports.usage = function(path) {
  var text = fs.readFileSync(path, { encoding: 'utf8' });
  return usagetext(text);
}
