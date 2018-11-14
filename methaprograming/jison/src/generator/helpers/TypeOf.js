
var Helper = function (value, options) {
    console.log("VALUE: %s", JSON.stringify(value));
    console.log("CONTEXT: %s", JSON.stringify(options));
    var type = options.hash.type;
    var vEval = value;
    try {
        vEval=eval(value);
    } catch(e) {}

    console.log("TYPE: %s", type);
    console.log("TYPEOF: %s", typeof(vEval));



    if( typeof(vEval) != type ) {
        return options.inverse(this);
    } else {
        return options.fn(this);
    }
};
  
  
  module.exports = Helper;