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

var startNewRound = function(){
  currentRound.card = flashCards.getFlashCard();
  currentRound.startTime = new Date().getTime() + gameOptions.timeOffset;
  currentRound.status = 'active';
  currentRound.responses = {};
  setTimeout(endRound, currentRound.timeRemaining());
  socket.broadcast(currentRound, 'next');
}

var reportScore = function(message){
  if(currentRound.status === 'inactive') return;
  var userResponse = message.text.toLowerCase();
  currentRound.responses[message.msisdn] = {
    response: userResponse,
    correctAnswer: userResponse === currentRound.card.answer.toLowerCase()
  }
}

var endRound = function(){
  storage.saveRound(currentRound);
  deactivateRound();
  setTimeout(startNewRound, gameOptions.timeBetweenRounds);
}

var roundSummary = function(){
  return {
    winners: pluck(currentRound.responses, 'correctAnswer'),
    answer: currentRound.card.answer
  };
}

var deactivateRound = function(){
  currentRound.status = 'inactive';
  currentRound.card = null;
  currentRound.responses = {};
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
