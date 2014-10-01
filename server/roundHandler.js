var flashCards = require('./flashCardService.js');
var storage = require('./storageService');
var socket = require('./socketService.js');

var currentRound = {};
var gameOptions = {
  timeBetweenRounds: 5000, // milliseconds
  timeOffset : 3000 // milliseconds, to account for network latency
}

currentRound.timeRemaining = function(){
  return currentRound.startTime + currentRound.card.time - new Date().getTime()
}

function shuffle(o){ //v1.0
    for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
};

var activateRound = function(){
  currentRound.card = flashCards.getFlashCard();
  currentRound.choices = shuffle([ 'Aaron', 'Drew', 'George', 'Barack' ]);
  currentRound.responses = {};
  currentRound.startTime = new Date().getTime() + gameOptions.timeOffset;
  currentRound.status = 'active';
}

var deactivateRound = function(){
  currentRound.status = 'inactive';
  currentRound.card = null;
  currentRound.responses = {};
}

var startNewRound = function(){
  activateRound();
  setTimeout(endRound, currentRound.timeRemaining());
  socket.broadcast(currentRound, 'next');
}

var roundSummary = function(){
  return {
    winners: pluck(currentRound.responses, 'correctAnswer'),
    answer: currentRound.card.answer
  };
}

var endRound = function(){
  socket.broadcast(roundSummary(), 'summary');
  storage.saveRound(currentRound);
  deactivateRound();
  setTimeout(startNewRound, gameOptions.timeBetweenRounds);
  storage.getScores()
         .then(function(data){
           socket.broadcast(data, 'scores');
         });
}

var reportScore = function(userId, answer){
  if(currentRound.status === 'inactive') return;
  var userResponse = answer.toLowerCase();
  currentRound.responses[userId] = {
    response: userResponse,
    correctAnswer: userResponse === currentRound.card.answer.toLowerCase()
  }
}

var getCurrentRound = function(){
  return currentRound;
}

var startGame = function(){
  startNewRound();
}

module.exports = {
  reportScore: reportScore,
  getCurrentRound: getCurrentRound,
  startGame: startGame
}

function pluck(collection, truthTest){
  var truth = [];
  for(var item in collection){
    if(item[truthTest]) truth.push(item);
  }
  return truth;
}
