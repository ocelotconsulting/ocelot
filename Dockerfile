FROM alpine

RUN apk add --update nodejs

ADD ./ ./

CMD npm start

EXPOSE 80
EXPOSE 81
