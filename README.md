# Github Runners using Docker

This repository contains the Dockerfile and the necessary files to create a Docker image that can be used as a self-hosted runner for Github Actions.

## Usage

You can either build the image yourself or use the pre-built image from ghcr.io.

### Environment Variables

- `ORGANIZATION_NAME`: The name of the organization that the runner should be registered to.This is the same as the organization name in the URL of the organization's Github page.
- `GITHUB_ACCESS`: The access token that the runner should use to authenticate with Github. This token should have the `repo` scope.

### Building and Running the container yourself using Docker Compose

```yaml
services:
  app:
    image: github-actions-runner
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      ORGANIZATION_NAME: 'your-organization-name'
      GITHUB_ACCESS_TOKEN: 'ghp_***'
```

```bash
docker compose up --build -d
```

### Building and Running the container yourself using Docker

```bash
docker run \
    -e ORGANIZATION_NAME='your-organization-name' \
    -e GITHUB_ACCESS_TOKEN='ghp_***' \
    github-actions-runner \
    docker build -t github-actions-runner .

```

### Running the pre-built image using Docker Compose

```yaml
services:
  app:
    image: ghcr.io/redact-digital/docker-github-runner:latest
    environment:
      ORGANIZATION_NAME: 'your-organization-name'
      GITHUB_ACCESS: 'ghp_***'
```

```bash
docker compose up -d
```

### Running the pre-built image using Docker

```bash
docker run \
    -e ORGANIZATION_NAME='your-organization-name' \
    -e GITHUB_ACCESS_TOKEN='gh_***' \
    ghcr.io/redact-digital/docker-github-runner:latest
```

## Using Docker (docker/build-push-action)

If you are using the `docker/build-push-action` action to build and push your Docker image, you will need to add the volume `/var/run/docker.sock:/var/run/docker.sock` to the container. It is also possible that you need change the permissions of the docker socket on the host machine. If that is the case you can use `sudo chmod 666 /var/run/docker.sock`. This is not recommended for production environments because it can be a security risk.

### Running the pre-built image using Docker Compose

```yaml
services:
  app:
    image: ghcr.io/redact-digital/docker-github-runner:latest
    environment:
      ORGANIZATION_NAME: 'your-organization-name'
      GITHUB_ACCESS: 'ghp_***'
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

```bash
docker compose up -d
```

### Running the pre-built image using Docker

```bash
docker run \
    -e ORGANIZATION_NAME='your-organization-name' \
    -e GITHUB_ACCESS_TOKEN='gh_***' \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    ghcr.io/redact-digital/docker-github-runner:latest
```
