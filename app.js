var Hapi = require('hapi');

var host = 'localhost';
var port = process.env.PORT || 4008;
var server = new Hapi.Server(host, port);

server.route({
  method: 'GET',
  path: '/',
  handler: function(request, reply){
  reply('^_^');
  }
});

server.start();
console.log('Listening on port', port);
