var Hapi = require('hapi');
var roundHandler = require('./roundHandler.js');

var host = '0.0.0.0';
var port = process.env.PORT || 4008;
var server = new Hapi.Server(host, port, {cors: true});

server.route({
  method: 'GET',
  path: '/api/v1/testCards',
  handler: function(request, reply){
    reply(roundHandler.getCurrentRound());
  }
});

server.route({
  method: 'GET',
  path: '/api/v1/reportScore',
  handler: function(request, reply){
    roundHandler.reportScore(request.url.query);
    reply('200: OK');
  }
});

server.route({
	method: 'GET',
	path: '/index.html',
	handler: { file: 'build/index.html' }
})

server.start();
console.log('Listening on port', port);
roundHandler.startGame();
