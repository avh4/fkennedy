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
  currentRound.startTime = new Date().getTime() + gameOptions.timeOffset;
  setTimeout(endRound, currentRound.timeRemaining());
}

var reportScore = function(message){

}

var endRound = function(){
  reportRound();
  currentRound.card = null;
  setTimeout(startNewRound, gameOptions.timeBetweenRounds);
}

var reportRound = function(){

}

module.exports = {
  startNewRound: startNewRound,
  reportScore: reportScore,
  endRound: endRound
}
