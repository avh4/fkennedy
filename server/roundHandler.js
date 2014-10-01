var flashCards = require('./flashCardService.js');
var storage = require('./storageService');
var socket = require('./socketService.js');

var currentRound = {};
var gameOptions = {
  timeBetweenRounds: 5000, // milliseconds
  timeOffset : 3000 // milliseconds, to account for network latency
}

currentRound.timeRemaining = function(){
  return currentRound.startTime + currentRound.time - new Date().getTime()
}

var activateRound = function(){
  currentRound.card = flashCards.getFlashCard();
  currentRound.choices = flashCards.getChoices(currentRound.card);
  currentRound.responses = {};
  currentRound.startTime = new Date().getTime() + gameOptions.timeOffset;
  currentRound.status = 'active';
  currentRound.time = 10000; // milliseconds
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
