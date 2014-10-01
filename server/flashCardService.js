var testCards = require('./testCards');

var NUMBER_OF_CHOICES = 4;
var allChoices = testCards.map(function(c) { return c.answer; });

if (testCards.length < NUMBER_OF_CHOICES) {
  throw new Error("Need at least NUMBER_OF_CHOICES (" + NUMBER_OF_CHOICES + ") cards");
}

function shuffle(o){ //v1.0
    for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
}

function randomItem(items) {
  return items[Math.floor(Math.random()*items.length)];
}

exports.getFlashCard = function(){
  var random = Math.floor(Math.random() * testCards.length);
  return testCards[random];
};

exports.getChoices = function(card) {
  var choices = {};
  choices[card.answer] = true;
  while (Object.keys(choices).length < NUMBER_OF_CHOICES) {
    var choice = randomItem(allChoices);
    choices[choice] = true;
  }
  return shuffle(Object.keys(choices));
};

exports.getNumberOfCards = function() {
  return testCards.length;
}
