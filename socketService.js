var WebSocketServer = require('ws').Server;

module.exports = function(server){

  var options = {
    server: server.listener,
    path: '/api/v1/stream'
  }
  var wss = new WebSocketServer(options);

  wss.on('connection', function(ws){
    console.log('connected!');
  });
}

