# latest: docker-registry.threega.com/ocelot:<same as npm version>

FROM alpine

RUN apk add --update nodejs

ADD ./ ./

CMD npm start

EXPOSE 80
EXPOSE 81
