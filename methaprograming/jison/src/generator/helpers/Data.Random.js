const faker = require('faker')

var Helper = function (value, options) {
    
    var type = options.hash.type;
    var name = options.hash.name;
    // console.log("FAKE NAME: %s TYPE: %s", name, type);
 
    var fake = "null";

    var random = ""
    
    if (type == "string") {
        if (name == "email") {
            random = faker.internet.email()
        } else if (name == "name") {
            random = faker.name.findName()
        }
        fake = "'"+ random.replace("'","''") + "'";
    } if (type == "number") {
        fake = faker.random.number();
    }
    return fake;

};
  
module.exports = Helper;