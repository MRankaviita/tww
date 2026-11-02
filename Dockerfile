FROM ubuntu:26.04

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    ninja-build \
    git \
    python3

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
