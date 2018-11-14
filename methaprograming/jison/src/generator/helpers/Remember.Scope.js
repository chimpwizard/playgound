var Handlebars = require('handlebars');

var Helper = function (options) {
    
    var data;

    if (options.data) {
        data = Handlebars.createFrame(options.data);
    }

    var bag = {}

    data['bag'] = bag;

    return options.fn(this, { data: data })
};
  
module.exports = Helper;