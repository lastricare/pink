ARG VERSION=3.9-slim
FROM python:$VERSION

ARG COMMIT_SHA=main
ARG CREATED=""

# Fill in your labels as appropriate here
LABEL \
    org.opencontainers.image.created="$CREATED" \
    org.opencontainers.image.authors="Mariano Alesci" \
    org.opencontainers.image.url=https://github.com/malesci/wasabi \
    org.opencontainers.image.documentation=https://github.com/malesci/wasabi/README.md \
    org.opencontainers.image.source=https://github.com/malesci/wasabi \
    org.opencontainers.image.revision=$COMMIT_SHA \
    org.opencontainers.image.vendor="Mariano Alesci" \
    org.opencontainers.image.licenses=MIT \
    org.opencontainers.image.ref.name=wasabi \
    org.opencontainers.image.title="wasabi container" \
    org.opencontainers.image.description="wasabi built into a container"

# Set the SHELL option -o pipefail before RUN with a pipe in
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Installs google-chrome, chromedriver
RUN set -ex \
    && apt-get update --no-install-recommends -y \
    && apt-get install --no-install-recommends -y  \
       chromium \
       chromium-driver \ 
    && rm -rf /var/lib/apt/lists/*

# Set display port as an environment variable
ENV DISPLAY=:99

# Create a user for wasabi
RUN useradd -m nonroot
RUN mkdir -p /home/nonroot
WORKDIR /home/nonroot
ENV PATH="/home/nonroot/.local/bin:${PATH}"

# Copy wasabi folder
COPY wasabi .

COPY entrypoint.sh .
RUN chmod +x ./entrypoint.sh

# Now that the OS has been updated to include required packages, update ownership and then switch to nonroot user
RUN chown -R nonroot:nonroot /home/nonroot

USER nonroot
# Install additional Python requirements
RUN pip install --no-warn-script-location -r ./requirements.txt

CMD [ "./entrypoint.sh" ]