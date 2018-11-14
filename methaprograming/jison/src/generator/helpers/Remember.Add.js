var Handlebars = require('handlebars');

var Helper = function (value, options) {
    
    //console.log("SCOPE: %s", JSON.stringify(options));
    var type = options.hash.type;
    var key = options.hash.key;

    console.log("REMEMBER: %s as %s", value, type);


    var data;

    if (options.data) {
        data = Handlebars.createFrame(options.data);
    } else {
        data = {}
    }
    var bag = data['bag']

    if (!bag[value]) {
        bag[value] = {};
    }

    if (!key) {
        key=type;
    }
    bag[value][key]=type;
    // bag[value]={
    //     type:type
    // }

    //data['bag'] = bag;

    //console.log("BAG: %s", JSON.stringify(bag));


};
  
module.exports = Helper;