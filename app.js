var Hapi = require('hapi');
var roundHandler = require('./roundHandler.js');

var host = 'localhost';
var port = process.env.PORT || 4008;
var server = new Hapi.Server(host, port, {cors: true});

server.route({
  method: 'GET',
  path: '/api/v1/testCards',
  handler: function(request, reply){
    var nextCard = roundHandler.startNewRound();
    reply(nextCard);
  }
});

server.route({
  method: 'GET',
  path: '/api/v1/reportScore',
  handler: function(request, reply){
    roundHandler.endRound(request.url.query);
    reply('200: OK');
  }
});

server.start();
console.log('Listening on port', port);
