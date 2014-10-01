var WebSocketServer = require('ws').Server;

var openConnections = [];

var initializeSocket = function(server, path){
  var options = {
    server: server,
    path: path
  }

  var wss = new WebSocketServer(options);

  wss.on('connection', function(ws){
    openConnections.push(ws);
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

