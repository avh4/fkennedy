var Hapi = require('hapi');
var flashCards = require('./flashCardService.js');

var host = 'localhost';
var port = process.env.PORT || 4008;
var server = new Hapi.Server(host, port, {cors: true});

server.route({
  method: 'GET',
  path: '/api/v1/testCards',
  handler: function(request, reply){
    reply(flashCards.getFlashCard())
  }
});

server.start();
console.log('Listening on port', port);
