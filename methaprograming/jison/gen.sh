#!/bin/bash

node ./src/parser/parser.js --model ./src/model/model.m3 --output ./build/metadata.yaml
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/variables.ts.hbs --output ./build/src/model
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/types.ts.hbs --output ./build/src/types
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/enums.ts.hbs --output ./build/src/types
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/model.ts.hbs --output ./build/src/model