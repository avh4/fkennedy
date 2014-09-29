var redis = require('redis');
var url = require('url');

if(process.env.REDISTOGO_URL){
  var redisURL = url.parse(process.env.REDISTOGO_URL);
  var client = redis.createClient(redisURL.port, redisURL.hostname);
} else {
  var client = redis.createClient();
}

client.on('error', function(err){
  console.error(err);
});

var saveRound = function(round){
  for(user in round.responses){
    console.log(user);
    if(round.responses[user].correctAnswer) client.hincrby('users', user, "1");
  }
}

var getScores = function(reply){
  var scores = {};
  client.multi()
        .hgetall('users')
        .exec(function(err, replies){
          if(err) return console.error(err);
          for(var user in replies[0]){
            scores[user] = parseInt(replies[0][user]);
          }
          reply(scores);
        });
}

module.exports = {
  saveRound: saveRound,
  getScores: getScores
}

