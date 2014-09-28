var redis = require('redis');
var client = redis.createClient();

client.on('error', function(err){
  console.error(err);
});

var saveRound = function(round){
  for(user in round.responses){
    console.log(user);
    client.sadd('users', user);
    if(round.responses[user].correctAnswer) client.incr(user + ':score');
  }
}

module.exports = {
  saveRound: saveRound
}
