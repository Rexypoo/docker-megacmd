FROM ubuntu AS build
WORKDIR /build/tmp

# Install prerequisites
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -yq \
    autoconf \
    g++ \
    git \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libc-ares-dev \
    libcrypto++-dev \
    libcurl4-gnutls-dev \
    libfreeimage-dev \
    libmediainfo-dev \
    libpcre++-dev \
    libreadline-dev \
    libsodium-dev \
    libsqlite3-dev \
    libssl-dev \
    libswscale-dev \
    libtool \
    libuv1-dev \
    libz-dev \
    libzen-dev \
    make \
 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/meganz/MEGAcmd.git . \
 && git submodule update --init --recursive \
 && sh autogen.sh \
 && ./configure \
 && make \
 && make install

ENTRYPOINT ["mega-cmd-server"]

FROM ubuntu AS clean
COPY --from=build /usr/local /usr/local
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -yq \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libc-ares-dev \
    libcrypto++-dev \
    libcurl4-gnutls-dev \
    libfreeimage-dev \
    libmediainfo-dev \
    libpcre++-dev \
    libreadline-dev \
    libsodium-dev \
    libsqlite3-dev \
    libssl-dev \
    libswscale-dev \
    libtool \
    libuv1-dev \
    libz-dev \
    libzen-dev \
 && rm -rf /var/lib/apt/lists/*

FROM clean AS drop-privileges
ENV USER=mega
ENV UID=27328
WORKDIR "/$USER"
ENV TEMPLATE=/"$USER"/.megaCmd

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --no-create-home \
    --uid "$UID" \
    "$USER" \
 && chown $USER:$USER .

ADD https://raw.githubusercontent.com/Rexypoo/docker-entrypoint-helper/master/entrypoint-helper.sh /usr/local/bin/entrypoint-helper.sh
RUN chmod u+x /usr/local/bin/entrypoint-helper.sh
ENTRYPOINT ["entrypoint-helper.sh","mega-cmd-server"]

# Build with 'docker build -t megacmd .'
LABEL org.opencontainers.image.url="https://hub.docker.com/r/rexypoo/megacmd" \
      org.opencontainers.image.documentation="https://hub.docker.com/r/rexypoo/megacmd" \
      org.opencontainers.image.source="https://github.com/Rexypoo/docker-megacmd" \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.description="MEGAcmd on Docker" \
      org.opencontainers.image.title="rexypoo/megacmd" \
      org.label-schema.docker.cmd='mkdir -p "$HOME"/MEGA && \
      docker run -d \
      --name megacmd \
      --restart unless-stopped \
      --volume "$HOME"/MEGA:/mega \
      rexypoo/megacmd' \
      org.label-schema.docker.cmd.devel="docker run -it --rm --entrypoint bash rexypoo/megacmd" \
      org.label-schema.docker.cmd.debug="docker exec -it --user mega megacmd bash"
