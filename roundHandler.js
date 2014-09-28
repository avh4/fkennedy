var flashCards = require('./flashCardService.js');
var storage = require('./storageService');

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
  setTimeout(endRound, currentRound.timeRemaining());
}

var reportScore = function(message){
  if(currentRound.status === 'inactive') return;
  if(!currentRound.card.responses) currentRound.responses = {};
  var userResponse = message.text.toLowerCase();
  currentRound.responses[message.msisdn] = {
    response: userResponse,
    correctAnswer: userResponse === currentRound.card.answer.toLowerCase()
  }
}

var endRound = function(){
  currentRound.status = 'inactive';
  storage.saveRound(currentRound);
  currentRound.card = null;
  currentRound.responses = undefined;
  setTimeout(startNewRound, gameOptions.timeBetweenRounds);
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

