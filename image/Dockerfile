# Copyright Stryd, Inc. February 2020, All rights reserved.
ARG base_image=ubuntu:18.04 

FROM ${base_image}
ENV DOCKER_BASE_IMAGE ${base_image:-unspecified}

# Install all our dependencies, then blow away our list.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
       make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup our entrypoint
COPY ./entrypoint.sh /opt/image/entrypoint.sh
CMD /opt/image/entrypoint.sh

LABEL description="The Rainier Build System - arm-none-eabi compatible build suite" \
      version="1.0" \
      image.base="${base_image}"
