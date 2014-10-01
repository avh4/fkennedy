var redis = require('redis');
var url = require('url');
var crypto = require('crypto');

if(process.env.REDISTOGO_URL){
  var redisURL = url.parse(process.env.REDISTOGO_URL);
  var client = redis.createClient(redisURL.port, redisURL.hostname);
	client.auth(redisURL.auth.split(':')[1]);
} else {
  var client = redis.createClient();
}

client.on('error', function(err){
  console.error(err);
});

var saveRound = function(round){
  for(playerId in round.responses){
    console.log("Round ended: " + JSON.stringify(round));
    if(round.responses[playerId].correctAnswer) {
      client.multi()
        .sadd('player:correct:' + playerId, round.card.question)
        .scard('player:correct:' + playerId)
        .exec(function(err, res) {
          var count = res[1];
          client.hset('player:scores', playerId, count);
      });
    }
  }
}

var adjs = { '0': 'Mellow', '1': 'Cool', '2': 'Peaceful', '3': 'Electric', '4': 'Determined', '5': 'Lucky', '6': 'Lovable', '7': 'Serene', '8': 'Wild', '9': 'Benevolent', 'a': 'Profound', 'b': 'Subtle', 'c': 'Loquacious', 'd': 'Charming', 'e': 'Ubiquitous', 'f': 'Fancy'};
var animals = { '0': 'Marmot', '1': 'Cucumber', '2': 'Penguin', '3': 'Emu', '4': 'Dachshund', '5': 'Llama', '6': 'Lamprey', '7': 'Skylark', '8': 'Wildebeest', '9': 'Barnacle', 'a': 'Osprey', 'b': 'Antelope', 'c': 'Leopard', 'd': 'Chipmunk', 'e': 'Yak', 'f': 'Fox'};
var anonymouseName = function(playerId) {
  var shasum = crypto.createHash('sha1');
  shasum.update(playerId);
  var digest = shasum.digest('hex');
  return adjs[digest[3]] + " " + animals[digest[5]];
}

var getScores = function(){
  var numberOfCards = require('./flashCardService').getNumberOfCards();
  var next = undefined;
  var scoreboard = [];
  client.multi()
        .hgetall('player:scores')
        .hgetall('player:names')
        .exec(function(err, replies){
          if(err) return console.error(err);
          var scores = replies[0];
          var names = replies[1] || {};
          for(var playerId in scores){
            var name = names[playerId] || anonymouseName(playerId);
            scoreboard.push({ name: name, score: 100 * scores[playerId] / numberOfCards });
          }
          next(scoreboard);
        });

  return {then: function(callback){
    next = callback;
  }};
}

var setPlayerName = function(playerId, name) {
  client.hset('player:names', playerId, name);
}

module.exports = {
  saveRound: saveRound,
  getScores: getScores,
  setPlayerName: setPlayerName
}

