FROM ubuntu:22.04

# Exit on error
RUN set -e

ARG RUNNER_VERSION=2.316.1

# Prevent prompts for user input
ENV DEBIAN_FRONTEND noninteractive

# Add environment variables that can be used in the entrypoint script
ENV WORKDIR /github-runner

# Create the github user
RUN useradd -m github

# Create the docker group with the same GID as the host
RUN groupadd -g 999 docker

# Install Updates
RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends

# Install Dependencies
RUN apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    jq \
    libicu70 \
    apt-transport-https \
    software-properties-common \
    gnupg \
    lsb-release

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    docker-ce \
    docker-ce-cli \
    containerd.io

# Add the github user to the docker group
RUN usermod -aG docker github

# Install Cleanup
RUN apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Create the runner directory
RUN mkdir /github-runner

# Change the working directory
WORKDIR ${WORKDIR}

# Download the runner package
RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Extract the runner package
RUN tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Remove the runner package to clean up
RUN rm ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Change the ownership of the runner directory
RUN chown -R github:github /github-runner

USER github

COPY --chown=github:github --chmod=700 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
