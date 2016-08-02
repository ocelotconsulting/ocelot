FROM alpine

RUN apk add --update nodejs

WORKDIR /ocelot

ADD ./ /ocelot/

CMD npm start

EXPOSE 80
EXPOSE 81
