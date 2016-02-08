# latest: docker-registry.threega.com/ocelot:1.27

FROM alpine:3.1

RUN apk add --update nodejs

ADD ./ ./

CMD npm start

EXPOSE 8080
EXPOSE 8081
