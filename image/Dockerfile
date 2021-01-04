# Copyright Stryd, Inc. February 2020, All rights reserved.
ARG base_image=ubuntu:20.04 

FROM ${base_image}
ENV DOCKER_BASE_IMAGE ${base_image:-unspecified}

# Install all our dependencies, then blow away our list.
# apt-get has a stable CLI, but apt does not.  Prefer apt-get.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        gcc-arm-none-eabi \
        jq \
        libnewlib-arm-none-eabi \
        libusb-1.0-0 \
        make \
        python3.8 \
        python3-pip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --install /usr/bin/python3 python /usr/bin/python3.8 1

# Setup our entrypoint
COPY ./entrypoint.sh /opt/image/entrypoint
ENV PATH="/opt/image:${PATH}"

LABEL description="The Rainier Build System - arm-none-eabi compatible build suite" \
      version="1.0" \
      image.base="${base_image}"
