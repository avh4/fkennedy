var Hapi = require('hapi');
var flashCards = require('./flashCardService.js');

var host = 'localhost';
var port = process.env.PORT || 4008;
var server = new Hapi.Server(host, port);

server.route({
  method: 'GET',
  path: '/api/v1/testCards',
  handler: function(request, reply){
    reply({test: "I'm a test card!"});
  }
});

server.start();
console.log('Listening on port', port);
