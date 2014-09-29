var Hapi = require('hapi');
var roundHandler = require('./roundHandler.js');
var storage = require('./storageService');
var socket= require('./socketService.js');

var host = '0.0.0.0';
var port = process.env.PORT || 4008;
var server = new Hapi.Server(host, port, {cors: true});
var socketPath = '/api/v1/stream';

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
  path: '/api/v1/scores',
  handler: function(request, reply){
    storage.getScores(reply);
  }
});

server.route({
  method: 'GET',
  path: '/index.html',
  handler: { file: 'build/index.html' }
});

server.start();
console.log('Listening on port', port);
roundHandler.startGame();
socket.initializeSocket(server.listener, socketPath);

