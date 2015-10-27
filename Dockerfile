# latest: dockerc01.monsanto.com:5000/ocelot:1.12

FROM alpine

RUN apk add --update nodejs

ADD ./ ./

CMD npm start

EXPOSE 8080
