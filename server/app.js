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
  path: '/api/v1/reportAnswer',
  handler: function(request, reply){
    var message = request.url.query;
    var playerId = message.From || message.msisdn;
    var answer = message.Text || message.text;
    roundHandler.reportScore(playerId, answer);
    reply('200: OK');
  }
});

server.route({
  method: 'GET',
  path: '/api/v1/scores',
  handler: function(request, reply){
    storage.getScores()
           .then(function(data){
             reply(data);
           });
  }
});

server.route({
  method: 'GET',
  path: '/',
  handler: { file: 'web/build/index.html' }
});

server.start();
console.log('Listening on port', port);
roundHandler.startGame();
socket.initializeSocket(server.listener, socketPath);

