#!/bin/bash

rm -rf ./build

## front-end
ng new www --directory "./build/www"

cp -R ./src/stacks/commons ./build/www/src/app/

node ./src/parser/parser.js --model ./src/model/model.m3 --output ./build/metadata.yaml
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/variables.ts.hbs --output ./build/www/src/app/model
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/types.ts.hbs --output ./build/www/src/app/types
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/enums.ts.hbs --output ./build/www/src/app/types
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/model.ts.hbs --output ./build/www/src/app/model
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/data.ts.hbs --output ./build/www/src/app/data
node ./src/generator/generator.js --metadata ./build/metadata.yaml --template ./src/templates/services.ts.hbs --output ./build/www/src/app/services

## Additionals
cd ./build/www
npm install angular-in-memory-web-api --save