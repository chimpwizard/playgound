
console.log("LOADING PARSER....")
var Handler = function Addaptor () {
  // do nothing
};

Handler.parser = function (fileName) {
    var Parser = require("jison").Parser;
    var fs = require("fs");

    var grammar = fs.readFileSync("./src/parser/grammar.jison", "utf8");
    var parser = new Parser(grammar);
    var parserSource = parser.generate();

    // you can also use the parser directly from memory

    console.log("OUTOUT: " + fileName)
    // returns true
    var model = fs.readFileSync(fileName, "utf8");
    var mapping = parser.parse(model);

    return mapping;
}



module.exports = Handler;