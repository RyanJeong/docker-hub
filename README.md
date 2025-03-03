# docker-hub
A modular Docker repository with a core image and customizable build scripts for different use cases.

## Install Docker on macOS

```shell
brew install --cask docker
```

If you want to re-install Docker, follow the steps below:

```shell
sudo rm -rf ~/Library/Group\ Containers/group.com.docker
sudo rm -rf ~/Library/Containers/com.docker.docker
sudo rm -rf ~/.docker

brew uninstall --cask docker --force
brew uninstall --formula docker --force

brew install --cask docker
```

## Build `dockerfile`

If you set `USE_LOCAL_SSH_KEY` as `false`, port forwarding and filewall tasks (e.g., `sudo ufw allow <PORT>`) must be performed first.

```shell
# USE_LOCAL_SSH_KEY
# - true  : use ${SSH_PUB_KEY} to set the container's authorized_keys
# - false : use ${AUTH_KEY} to set the container's authorized_keys
USE_LOCAL_SSH_KEY=true
docker build \
  --build-arg PASSWORD=docker \
  --build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
  --build-arg SSH_PRIV_KEY="$(cat ~/.ssh/id_rsa)" \
  --build-arg AUTH_KEY="$(cat ~/.ssh/authorized_keys)" \
  --build-arg USE_LOCAL_SSH_KEY="${USE_LOCAL_SSH_KEY}" \
  -t docker ./
```

After building the `dockerfile`, create a container using following command:

```shell
# -p: port, e.g., -p 52780:8080
# -v: mount the host directory, e.g., -v ${HOME}/share:/home/docker/share
docker run -p 32541:22 -itd --name docker docker
```

