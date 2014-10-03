var WebSocketServer = require('ws').Server;
var storage = require('./storageService');

var openConnections = [];

function handleMessage(ws, m) {
  console.log("message: ", JSON.stringify(m));
  if (m.type == "id") {
    var playerId = m.message.id;
    if (playerId == undefined) return;
    storage.getPlayerName(playerId).then(function(name) {
      ws.send(JSON.stringify({type: "playerInfo", message: {name: name}}));
    });
  }
  if (m.type == "name") {
    var playerId = m.message.id;
    var name = m.message.name;
    storage.setPlayerName(playerId, name).then(function() {
      storage.getPlayerName(playerId).then(function(name) {
        ws.send(JSON.stringify({type: "playerInfo", message: {name: name}}));
      });
    });
  }
}

var initializeSocket = function(server, path){
  var options = {
    server: server,
    path: path
  }

  var wss = new WebSocketServer(options);

  wss.on('connection', function(ws){
    openConnections.push(ws);
    ws.on('message', function(m) {
      try {
        var j = JSON.parse(m);
        handleMessage(ws, j);
      } catch (e) {
        console.log(e);
      }
    });
  });
}

var broadcast = function(message, type){
  var updatedOpenConnections = [];
  for(var i = 0; i < openConnections.length; i++){
    var ws= openConnections[i];
    if(ws.readyState === ws.OPEN){
      ws.send( JSON.stringify({
        message: message,
        type: type
      }) );
      updatedOpenConnections.push(ws);
    }
  }
  openConnections = updatedOpenConnections;
}

module.exports = {
  initializeSocket: initializeSocket,
  broadcast: broadcast
};

