# latest: docker-registry.threega.com/ocelot:1.19

FROM alpine

RUN apk add --update nodejs

ADD ./ ./

CMD npm start

EXPOSE 8080
EXPOSE 8081
