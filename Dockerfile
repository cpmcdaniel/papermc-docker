FROM azul/zulu-openjdk-alpine:11

LABEL maintainer="cpmcdaniel@gmail.com"

COPY paper /usr/local/bin

ENV MINECRAFT_HOME /opt/minecraft
ENV WORLD_DIR /var/lib/minecraft

RUN apk update && apk upgrade && \
    apk add curl git tmux bash && \
    apk add gosu --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
    
RUN addgroup -g 1000 minecraft && \
    adduser -G minecraft -u 1000 -S minecraft && \
    mkdir -p $WORLD_DIR $MINECRAFT_DIR && \
    chown minecraft:minecraft $WORLD_DIR $MINECRAFT_DIR && \
    echo "set -g status off" > /root/.tmux.conf && \
    chmod 755 /usr/local/bin/paper

VOLUME [$WORLD_DIR, $MINECRAFT_DIR]

EXPOSE 25565

ENTRYPOINT ["/usr/local/bin/paper"]

CMD ["run"]
