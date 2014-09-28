var flashCards = require('./flashCardService.js');
var currentRound;

var startNewRound = function(){
  currentRound = {};
  currentRound.card = flashCards.getFlashCard();
  currentRound.startTime = new Date().getTime() / 1000;
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
