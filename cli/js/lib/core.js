var colors = require('colors');
var readline = require('readline');
var path = require('path');
var fs = require('fs');
var url = require('url');

var abort = exports.abort = function(msg) {
  console.log(msg.red);
  process.exit(1);
  return null;
}

var exists = exports.exists = function(path) {
  try {
      var stats = fs.statSync(path);
      return true;
  } catch(err) {
    return false;
  }
}

// find the root directory containing deploy.json
var root = exports.root = function() {
  var dir = process.cwd();
  while(true) {
    var parent = path.dirname(dir);
    if(dir == parent) {
      break; // can't go any further up the tree
    }
    if(exists(path.join(dir, "deploy.json"))) {
      return dir;
    }
    dir = parent;
  }
  return null;
}

configpath = function() {
  return path.join(root(), "deploy.json");
}

var config = exports.config = function() {
  var path = configpath();
  if(!exists(path)) return null;

  var contents = fs.readFileSync(path,
    { encoding: 'utf-8' });

  return JSON.parse(contents);
}

var app = exports.app = function() {
  return config().app;
}
var baseurl = exports.baseurl = function() {
  return config().url;
}

exports.apiurl = function(action, url, appName) {
  url = url || baseurl();
  appName = appName || app();
  return url + "/api/" + appName + "/" + action;
}

// http functions
exports.host = function(address) {
  return url.parse(address).host;
}
function makeRequest(address, username, password, fn) {
  var opts = url.parse(address);
  opts.auth = username + ":" + password;
  var proto;
  if(opts.protocol == 'http:') {
    proto = require('http');
  } else if(opts.protocol == 'https:') {
    proto = require('https');
  } else {
    throw 'unknown protocol: ' + opts.protocol
  }

  var req = proto.request(opts, fn);
  req.end();
}

exports.request = function(address, username, password, fn) {
  makeRequest(address, username, password, function(res) {
    if(res.statusCode == 401) {
      abort('invalid credentials');
    }

    res.on('data', function(chunk) {
      process.stdout.write(chunk.toString());
    });
  });
}

exports.geturl = function(address, username, password, fn) {
  makeRequest(address, username, password, function(res) {
    var text = "";
    res.on('data', function(chunk) {
      text += chunk.toString();
    });
    res.on('end', function() {
      fn(res.statusCode, text)
    })
  });
}
