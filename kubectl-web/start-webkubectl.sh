#!/bin/bash

echo "Environment variables:"
env

echo "export TERM=xterm-256color" >> bashrc
echo "source /usr/share/bash-completion/bash_completion" >> bashrc
echo 'source <(kubectl completion bash)' >> bashrc
echo 'complete -F __start_kubectl k' >> bashrc
echo 'export PATH=$PATH:'$(pwd) >> bashrc

export PATH=$PATH:$(pwd)
export GOTTY_OPTIONS="--port 8080 --permit-write --permit-arguments"



gotty ${GOTTY_OPTIONS} ./start-session.sh
