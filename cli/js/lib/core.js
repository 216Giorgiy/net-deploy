var colors = require('colors');
var readline = require('readline');
var path = require('path');
var fs = require('fs');
var url = require('url');
var child_process = require('child_process');

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

exports.hasarg = function(arguments, find) {
  var a = arguments;
  return Object.keys(a)
    .map(function(k) { return a[k]; })
    .indexOf(find) > -1
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
  var rootdir = root();
  if(rootdir) {
    return path.join(rootdir, "deploy.json");
  }
  return null;
}

var config = exports.config = function() {
  var path = configpath();
  if(!path || !exists(path)) return null;

  var contents = fs.readFileSync(path,
    { encoding: 'utf-8' });

  return JSON.parse(contents);
}

var app = exports.app = function() {
  var cfg = config();
  if(!cfg) { return null; }
  return cfg.app;
}
var baseurl = exports.baseurl = function() {
  var cfg = config();
  if(!cfg) { return null; }
  return config().url;
}

exports.apiurl = function(action, url, appName) {
  url = url || baseurl();
  if(!url) return null;
  appName = appName || app();
  return url + "/api/" + appName + "/" + action;
}

exports.git_root = function() {
  var res;
  try {
    res = child_process.execSync('git rev-parse --show-toplevel',
      { stdio: 'pipe'} );
    return res.toString().trim();
  } catch(err) {
    console.log(err.stderr.toString());
    process.exit(1);
  }
}

// http functions
exports.host = function(address) {
  return url.parse(address).host;
}
function makeRequest(address, username, password, fn) {
  var opts = url.parse(address);
  if(username) {
      opts.auth = username + ":" + password;
  }
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
      fn(res.statusCode, text);
    })
  });
}
