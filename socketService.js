var WebSocketServer = require('ws').Server;

var initializeSocket = function(server, path){
  var options = {
    server: server,
    path: path
  }

  var wss = new WebSocketServer(options);

  wss.on('connection', function(ws){
    ws.send('Great success');
  });
}

module.exports = {
  initializeSocket: initializeSocket
};

