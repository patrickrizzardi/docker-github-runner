#!/bin/bash

blue_text='\033[0;36m'
red_text='\033[0;31m'
color_reset='\033[0m'
environment=""

set -e

# Ensure organization name is set and not empty
if [ -z "$ORGANIZATION_NAME" ]; then
    echo -e "${red_text}Organization name is not set. Exiting...${color_reset}"
    exit 1
fi

# Ensure access token is set and not empty
if [ -z "$GITHUB_ACCESS_TOKEN" ]; then
    echo -e "${red_text}GitHub access token is not set. Exiting...${color_reset}"
    exit 1
fi

RUNNER_TOKEN=$(
    curl -X POST \
        -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/orgs/${ORGANIZATION_NAME}/actions/runners/registration-token" |
        jq .token --raw-output
)

$WORKDIR/config.sh --url https://github.com/${ORGANIZATION_NAME} --token ${RUNNER_TOKEN}

# If we get Cannot configure the runner because it is already configured. To reconfigure the runner, run 'config.cmd remove' or './config.sh remove' first. then we need to remove the runner and re-run the config.sh
if [ $? -ne 0 ]; then
    cleanup
    $WORKDIR/config.sh --url https://github.com/${ORGANIZATION_NAME} --token ${RUNNER_TOKEN}
fi

cleanup() {
    echo -e "${blue_text}Removing runner...${color_reset}"
    $WORKDIR/config.sh remove --unattended --token ${RUNNER_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh &
wait $!
