var testCards = require('./testCards');

exports.getFlashCard = function(){
  var random = Math.floor(Math.random() * testCards.length);
  return testCards[random];
}

