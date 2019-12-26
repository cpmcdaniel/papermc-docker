FROM azul/zulu-openjdk-alpine:11

LABEL maintainer="cpmcdaniel@gmail.com"

COPY paper /usr/local/bin

ARG MINECRAFT_HOME="/opt/minecraft"

RUN apk update && apk upgrade && \
    apk add curl git tmux bash && \
    apk add gosu --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
    
RUN addgroup -g 1000 minecraft && \
    adduser -G minecraft -u 1000 -S minecraft && \
    mkdir -p $MINECRAFT_HOME /var/lib/minecraft && \
    chown minecraft:minecraft $MINECRAFT_HOME /var/lib/minecraft && \
    echo "set -g status off" > /root/.tmux.conf && \
    chmod 755 /usr/local/bin/paper

VOLUME ["${MINECRAFT_HOME}",  "/var/lib/minecraft"]

EXPOSE 25565

ENTRYPOINT ["/usr/local/bin/paper"]

CMD ["run"]
