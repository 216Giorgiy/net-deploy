var fs = require('fs');
var core = require('./core.js');
var path = require('path');
var read = require('read');

var cachePath = path.join(process.env.HOME, '.deploy', 'auth.txt');

var get = exports.get = function(host) {
  var cached = loadCache();
  return cached[host];
}

function set(host, username, password) {
  var cached = loadCache();
  cached[host] = [username, password];
  saveCache(cached);
}

function ask(fn) {
  read({ prompt: 'deploy username: '}, function(err, username) {
    if(err) { process.exit(1); }
    read({ prompt: 'password: ', silent: true, replace: '*' }, function(err, password) {
      if(err) { process.exit(1); }
      fn(username, password);
    });
  })
}

exports.ensure = function(baseurl, app, fn) {
  var url = baseurl || core.baseurl();
  app = app || core.app();

  var host = core.host(url);
  var auth = get(host);

  var getNew = function() {
    ask(function(username, password) {
      set(host, username, password);
      fn(username, password);
    });
  }

  if(auth == null) {
    getNew();
    return;
  }

  var username = auth[0];
  var password = auth[1];
  var checkurl = core.apiurl('detail', baseurl, app);

  checkCreds(checkurl, username, password, function(valid) {
    if(!valid) {
      getNew();
    } else {
      fn(username, password);
    }
  });
}

function loadCache() {
  if(!core.exists(cachePath)) return { };

  var text = fs.readFileSync(cachePath, { encoding: 'utf8' });
  var lines = text.split('\n');
  var cached = {};
  // format is host "username" password
  var re = new RegExp("([^ ]+) \"([^\"]+)\" (.+)")
  for(var i = 0; i < lines.length; i++) {
    var match = re.exec(lines[i])
    if(match == null) continue;

    var host = match[1];
    var username = match[2];
    var password = match[3].trim();

    cached[host] = [username, password];
  }

  return cached;
}

function saveCache(dic) {
  // ensure directory
  try {
    fs.mkdirSync(path.dirname(cachePath))
  } catch(e) {
    if(e.code != 'EEXIST') throw e;
  }

  var text = "";
  for(var host in dic) {
    var creds = dic[host];
    text += host + ' "' + creds[0] + '" ' + creds[1] + '\n';
  }

  fs.writeFileSync(cachePath, text);
}

function checkCreds(url, username, password, fn) {
  core.geturl(url, username, password, function(status, text) {
    if(status == 401) {
      fn(false);
    } else if(status == 200) {
      fn(true);
    } else {
      core.abort("error accessing " + url + ": " + status);
    }
  });
}
