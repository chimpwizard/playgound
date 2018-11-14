
var Handlebars = require('handlebars');

var Helper = function (value, options) {
  console.log("VALUE: %s", JSON.stringify(value));
 
  var type = options.hash.type;
  var name = options.hash.name;

  var data;

  if (options.data) {
      data = Handlebars.createFrame(options.data);
  } else {
      data = {}
  }
  var bag = data['bag']

  var buildIn = isBuiltIn(value);

  if( buildIn ) {
      return options.inverse(this);
  } else {
    if( bag[value] && bag[value]['import'] ) {
      return options.inverse(this);
    } else {
      return options.fn(this);
    }
  }
};

function isBuiltIn(value) {
  return  (value=="string" || value =="number")
}

module.exports = Helper;