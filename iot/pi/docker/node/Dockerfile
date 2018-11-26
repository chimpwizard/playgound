#FROM arm32v6/node:10-alpine
FROM arm32v6/alpine:3.6

RUN apk add --update nodejs nodejs-npm

WORKDIR /var/app
ADD package.json .
RUN npm install
ADD app.js .

CMD ["node", "./app.js"]