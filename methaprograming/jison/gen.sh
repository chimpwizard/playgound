#!/bin/bash

rm -rf ./build
ng new jison --directory "./build"
cp -R ./app/stacks/commons ./build/src/app/
node ./src/parser/parser.js --model ./src/model/model.m3 --output ./build/metadata.yaml
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/variables.ts.hbs --output ./build/src/app/model
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/types.ts.hbs --output ./build/src/app/types
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/enums.ts.hbs --output ./build/src/app/types
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/model.ts.hbs --output ./build/src/app/model
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/data.ts.hbs --output ./build/src/app/data

node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/api.ts.hbs --output ./build/src/app/services