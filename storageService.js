var redis = require('redis');
var client = redis.createClient();

client.on('error', function(err){
  console.error(err);
});

var saveRound = function(round){
  console.log(round);
}
