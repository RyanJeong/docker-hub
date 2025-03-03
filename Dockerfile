ARG UBUNTU_VERSION="18.04"

FROM ubuntu:${UBUNTU_VERSION}

ARG USER="docker"
ARG PASSWORD="docker"
ARG USER_HOME="/home/${USER}"

ARG USE_LOCAL_SSH_KEY=false

ARG SSH_PUB_KEY
ARG SSH_PRIV_KEY
ARG AUTH_KEY

RUN if [ -z "${SSH_PUB_KEY}" ]; then echo "Error: SSH_PUB_KEY is not set" && exit 1; fi
RUN if [ -z "${SSH_PRIV_KEY}" ]; then echo "Error: SSH_PRIV_KEY is not set" && exit 1; fi
RUN if [ -z "${AUTH_KEY}" ]; then echo "Error: SSH_PRIV_KEY is not set" && exit 1; fi

SHELL ["/bin/bash", "-c"]

# package updates
RUN printf "deb [ arch=amd64,i386 ] http://ftp.daumkakao.com/ubuntu/ bionic main restricted universe multiverse \n\
deb [ arch=amd64,i386 ] http://ftp.daumkakao.com/ubuntu/ bionic-updates main restricted universe multiverse \n\
deb [ arch=amd64,i386 ] http://ftp.daumkakao.com/ubuntu/ bionic-security main restricted universe multiverse \n\
deb [ arch=amd64,i386 ] http://ftp.daumkakao.com/ubuntu/ bionic-backports main restricted universe multiverse\n" \
>> /etc/apt/sources.list

# package install
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      openssh-server \
      gcc \
      g++ \
      git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# add a user and make a home directory
RUN useradd -d "${USER_HOME}" -m "${USER}" && \
    echo "${USER}:${PASSWORD}" | chpasswd && \
    usermod -aG sudo "${USER}"

# setup SSH and settings
WORKDIR "${USER_HOME}/.ssh"
RUN mkdir -p /run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    echo "${SSH_PRIV_KEY}" > id_rsa && \
    chmod 600 id_rsa && \
    ssh-keyscan github.com >> known_hosts && \
    chmod 600 known_hosts && \
    if [ "${USE_LOCAL_SSH_KEY}" = true ]; then \
      echo "${SSH_PUB_KEY}" > authorized_keys; \
    else \
      echo "${AUTH_KEY}" > authorized_keys; \
    fi && \
    chmod 600 authorized_keys && \
    chown -R ${USER}:${USER} ${USER_HOME}/.ssh && \
    chmod 700 ${USER_HOME}/.ssh

# set a default shell
RUN sed -i 's:/bin/sh:/bin/bash:g' /etc/passwd

#### To be able to run SSH
WORKDIR "${USER_HOME}"

CMD ["/usr/sbin/sshd", "-D"]
