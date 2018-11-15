#!/usr/bin/env node

var fs = require("fs");
var path = require('path')
var program = require('commander');
var Handlebars = require('handlebars');
var YAML = require('yamljs');

program
  .version('1.0.0')
  .usage('[options]')
  .option('-m, --metadata <fileName>', 'File that contains the model', 'metadata.yaml')
  .option('-t, --template <fileName>', 'Global template to use for generation', 'global.hbs')
  .option('-o, --output <dir>', 'Output directory locaiton', './app')
  .parse(process.argv);

console.log("MODEL: %s", program.metadata)
console.log("TEMPLATE: %s", program.template)
console.log("OUTPUT: %s", program.output)

var content = fs.readFileSync(program.metadata, "utf8");

//var model = JSON.parse(content.toString());
var model = YAML.parse(content.toString());

var context = {
    model: model
};

// console.log("MODEL: %s", JSON.stringify(model));
// console.log("MODEL VARIABLES: %s", JSON.stringify(model.variables));

// Object.keys(model.variables).forEach(function(element){
//   console.log("ELEMENT: %s", model.variables[element]);
// });


var source = fs.readFileSync(program.template, "utf8");

Handlebars.registerHelper('utils', require('./helpers/Utils'));
Handlebars.registerHelper('typeof', require('./helpers/TypeOf'));
Handlebars.registerHelper('remember-add', require('./helpers/Remember.Add'));
Handlebars.registerHelper('remember-scope', require('./helpers/Remember.Scope'));
Handlebars.registerHelper('remember-import-from', require('./helpers/Remember.Import.From'));
Handlebars.registerHelper('remember-import-check', require('./helpers/Remember.Import.Check'));
Handlebars.registerHelper('data-random', require('./helpers/Data.Random'));
Handlebars.registerHelper('repeat', require('handlebars-helper-repeat'));

var helpers = require('handlebars-helpers')(['math', 'string']);

var template = Handlebars.compile(source);
var result = template(context);

// console.log("CONTENT: %s", result);

// console.log(result);

function ensureDirectoryExistence(filePath) {
  var dirname = path.dirname(filePath);
  if (fs.existsSync(dirname)) {
      return true;
  }
  ensureDirectoryExistence(dirname);
  fs.mkdirSync(dirname);
}

var fileName = path.basename( program.template).replace(".hbs","");

var fullFileName = program.output + "/" + fileName
ensureDirectoryExistence(fullFileName);

// console.log("FILENAME: %s", fullFileName)
fs.writeFile(fullFileName, result, function(err) {
    if(err) {
        return console.log(err);
    }

    console.log("The file was saved!");
}); 

