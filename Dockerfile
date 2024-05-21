FROM ubuntu:22.04

# Exit on error
RUN set -ex;

ARG RUNNER_VERSION=2.316.1

# Prevent prompts for user input
ENV DEBIAN_FRONTEND=noninteractive

# Add environment variables that can be used in the entrypoint script
ENV WORKDIR /github-runner

# Install dependencies
RUN apt-get update; \
    apt-get upgrade -y --no-install-recommends; \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    jq \
    libicu70;


# Install Cleanup
RUN apt-get -y autoremove; \
    apt-get -y clean; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /tmp/*; \
    rm -rf /var/tmp/*

# Create the github user
RUN useradd -m github

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
