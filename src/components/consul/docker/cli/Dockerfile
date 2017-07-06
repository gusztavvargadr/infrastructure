FROM consul

WORKDIR /consul
ADD tls tls/

RUN apk update && apk add ca-certificates
RUN cp tls/ca.cert /usr/local/share/ca-certificates
RUN update-ca-certificates
