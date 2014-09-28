var flashCards = require('./flashCardService.js');
var currentRound = {};
var gameOptions = {
  timeBetweenRounds: 5000, // milliseconds
  timeOffset : 3000 // milliseconds, to account for network latency
}

currentRound.timeRemaining = function(){
  return new Date().getTime() - (currentRound.startTime + currentRound.card.time)
}

var startNewRound = function(){
  currentRound.card = flashCards.getFlashCard();
  currentRound.startTime = new Date().getTime()
  return currentRound;
}

var reportScore = function(message){

}

var endRound = function(){

}

var reportRound = function(){

}

module.exports = {
  startNewRound: startNewRound,
  reportScore: reportScore,
  endRound: endRound
}
