var redis = require('redis');
var url = require('url');

if(process.env.REDISTOGO_URL){
  var redisURL = url.parse(process.env.REDISTOGO_URL);
  var client = redis.createClient(redisURL.port, rediURL.hostname);
} else {
  var client = redis.createClient();
}

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

var getScores = function(){

}

module.exports = {
  saveRound: saveRound,
  getScores: getScores
}
