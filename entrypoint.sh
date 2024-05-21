#!/bin/bash

set -ex

ORGANIZATION_NAME $ORGANIZATION_NAME
GITHUB_ACCESS_TOKEN $TOKEN

RUNNER_TOKEN=$(
    curl -X POST \
        -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/orgs/${ORGANIZATION_NAME}/actions/runners/registration-token" |
        jq .token --raw-output
)

cd /home/docker/actions-runner

$WORKDIR/config.sh --url https://github.com/${ORGANIZATION_NAME} --token ${RUNNER_TOKEN}

cleanup() {
    echo "Removing runner... "
    $WORKDIR/config.sh remove --unattended --token ${RUNNER_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh &
wait $!
