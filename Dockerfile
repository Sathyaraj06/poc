# For Reference
# - https://stackoverflow.com/questions/33322103/multiple-froms-what-it-means

# Install Locally instead
# Golang Container Layer
FROM ubi:ubi-8

# https://go.dev/doc/install
# https://go.dev/dl/go1.19.5.linux-amd64.tar.gz

# Install from Local Tar
# ADD go1.19.4.linux-amd64.tar.gz ./opt/
RUN rm -rf /usr/local/go
ADD go1.19.4.linux-amd64.tar.gz /usr/local
ENV PATH="$PATH:/usr/local/go/bin"

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GO111MODULE=on

WORKDIR /tmp
COPY gotty gotty
RUN cd gotty && \
    go mod download && go build && \
    make gotty && cp gotty / && ls -l /gotty && /gotty -v

USER root

# Copy from layer
COPY --from=gotty-build /gotty /usr/bin/

# apt update
# apk add - apt install

RUN ARCH=$(uname -m) && case $ARCH in aarch64) ARCH="arm64";; x86_64) ARCH="amd64";; esac && echo "ARCH: " $ARCH && \
    yum update && ymu upgrade && \
    yum install bash bash-completion curl git wget openssl iputils busybox-extras vim && \
    \
    sed -i "s/nobody:\//nobody:\/nonexistent/g" /etc/passwd && \
    curl -sLf https://storage.googleapis.com/kubernetes-release/release/v1.25.4/bin/linux/${ARCH}/kubectl > /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl && \
    git clone --branch master --depth 1 https://github.com/ahmetb/kubectl-aliases /opt/kubectl-aliases && \
    chmod -R 755 /opt/kubectl-aliases && \
    git clone --branch 0.35.1 --depth 1 https://github.com/junegunn/fzf /opt/fzf && \
    chmod -R 755 /opt/fzf && \
    /opt/fzf/install && \
    ln -s /opt/fzf/bin/fzf /usr/local/bin/fzf && \
    \
    ARCH=$(uname -m) && case $ARCH in aarch64) ARCH="arm64";; x86_64) ARCH="x86_64";; esac && echo "ARCH: " $ARCH && \
    cd /tmp/ && \
    wget https://github.com/derailed/k9s/releases/download/v0.26.7/k9s_Linux_${ARCH}.tar.gz && \
    tar -xvf k9s_Linux_${ARCH}.tar.gz && \
    chmod +x k9s && \
    mv k9s /usr/bin && \
    KUBECTX_VERSION=v0.9.4 && \
    wget https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubens_${KUBECTX_VERSION}_linux_${ARCH}.tar.gz && \
    tar -xvf kubens_${KUBECTX_VERSION}_linux_${ARCH}.tar.gz && \
    chmod +x kubens && \
    mv kubens /usr/bin && \
    \
    wget https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_linux_${ARCH}.tar.gz && \
    tar -xvf kubectx_${KUBECTX_VERSION}_linux_${ARCH}.tar.gz && \
    chmod +x kubectx && \
    mv kubectx /usr/bin && \
    curl -L https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash && \
    chmod +x /usr/bin/gotty && \
    chmod 555 /bin/busybox && \
    \
    yum remove git && \
    # rm -rf /tmp/* /var/tmp/* /var/cache/apk/* && \
    chmod -R 755 /tmp && mkdir -p /opt/webkubectl

COPY vimrc.local /etc/vim
COPY start-webkubectl.sh /opt/webkubectl
COPY start-session.sh /opt/webkubectl
COPY init-kubectl.sh /opt/webkubectl
RUN chmod -R 700 /opt/webkubectl /usr/bin/gotty


ENV SESSION_STORAGE_SIZE=10M
ENV WELCOME_BANNER="Welcome to Web Kubectl, try kubectl --help."
ENV KUBECTL_INSECURE_SKIP_TLS_VERIFY=true
ENV GOTTY_OPTIONS="--port 7777 --permit-write --permit-arguments"

CMD ["sh","/opt/webkubectl/start-webkubectl.sh"]
