
var Handlebars = require('handlebars');

var Helper = function (value, options) {
  

  var data;

  if (options.data) {
      data = Handlebars.createFrame(options.data);
  } else {
      data = {}
  }
  var bag = data['bag']

  var buildIn = isBuiltIn(value);

  
  var path = "'../commons/types'"
  var type = "none"

  if( bag[value] && bag[value]["type"] ) {
    type = bag[value].type;
    if (bag[value].type == "type") {
      path = "'../types/types'";
    } else if (bag[value].type == "enum") {
      path = "'../types/enums'";
    }
  } else {
    path = "'../commons/types/" + value+ "'";
  }

  //console.log("VALUE: %s", JSON.stringify(value));
  console.log("VALUE: %s BAG type: %s", JSON.stringify(value), JSON.stringify(type));


  if( buildIn ) {
      return options.inverse(this);
  } else if( bag[value] && bag[value]['import'] ) {
    return options.inverse(this);
    //return "";
  } else {
    return path;
  }
  
};

function isBuiltIn(value) {
  return  (value=="string" || value =="number")
}

module.exports = Helper;
