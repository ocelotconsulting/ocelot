# latest: dockerc01.monsanto.com:5000/ocelot:1.13

FROM alpine

RUN apk add --update nodejs

ADD ./ ./

CMD npm start

EXPOSE 8080
