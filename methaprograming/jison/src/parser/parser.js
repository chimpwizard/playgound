#!/usr/bin/env node

var Parser = require("jison").Parser;
var path = require('path')
var fs = require("fs");
YAML = require('yamljs');

var program = require('commander');

program
  .version('1.0.0')
  .usage('[options]')
  .option('-m, --model <fileName>', 'File that contains the model', 'model.m3')
  .option('-o, --output <fileName>', 'Generated Model', 'model.json')
  .parse(process.argv);

console.log("MODEL: %s", program.model)
console.log("OUTPUT: %s", program.output)

var Handler = require("./handler")


var mapping = Handler.parser(program.model);

//console.log(JSON.stringify(mapping));

var yamlString = YAML.stringify(mapping,10,4);  // deep: 10, indent: 4
console.log("YAML: %s", yamlString)

function ensureDirectoryExistence(filePath) {
    var dirname = path.dirname(filePath);
    if (fs.existsSync(dirname)) {
        return true;
    }
    ensureDirectoryExistence(dirname);
    fs.mkdirSync(dirname);
}

ensureDirectoryExistence(program.output);

fs.writeFile(program.output, yamlString, function(err) {
    if(err) {
        return console.log(err);
    }

    console.log("The file was saved!");
}); 

// fs.writeFile(program.output+".json", JSON.stringify(mapping), function(err) {
//     if(err) {
//         return console.log(err);
//     }

//     console.log("The file was saved!");
// }); 

// throws lexical error
//parser.parse("adfe34bc zxg");