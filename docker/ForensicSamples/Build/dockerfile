FROM ubuntu:14.04
MAINTAINER Alex Verboon 
USER root
RUN apt-get update && apt-get install -y \
  git \
  ruby \
  ruby-dev \
  bundler \
  build-essential && \
  rm -rf /var/lib/apt/lists/*

RUN groupadd -r nonroot && \
  useradd -r -g nonroot -d /home/nonroot -s /sbin/nologin -c "Nonroot User" nonroot && \
  mkdir /home/nonroot && \
  chown -R nonroot:nonroot /home/nonroot

USER nonroot
WORKDIR /home/nonroot

RUN git clone https://github.com/volatilityfoundation/volatility.git

USER root





