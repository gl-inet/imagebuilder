FROM debian:stretch-slim

RUN apt update && apt install -y \
    device-tree-compiler \
    git \
    make \
    python \
    wget

RUN if ![ -x python ]; then ln -s /usr/bin/python2.7 /usr/bin/python ;fi

ENV SOURCE_DIR="/src"
WORKDIR ${SOURCE_DIR}

ENTRYPOINT ["python", "gl_image"]
