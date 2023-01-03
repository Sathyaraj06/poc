#!/bin/bash
set -e

if [ "${WELCOME_BANNER}" ]; then
    echo ${WELCOME_BANNER}
fi

arg1=$1
arg2=$2

rm -fr ./cache
mkdir -p ./cache

cp bashrc ./cache/bashrc

# mount -t tmpfs -o size=${SESSION_STORAGE_SIZE} tmpfs ./cache
cd ./cache

#cp /root/.bashrc ./
#cp /etc/vim/vimrc.local .vimrc
echo 'source kubectl-aliases/.kubectl_aliases' >> bashrc
echo -e 'PS1="> "\nalias ll="ls -la"' >> bashrc
mkdir -p .kube

export HOME=./cache
if [ -z "${arg2}" ]; then
    echo $arg1| base64 -d > .kube/config
else
    echo `kubectl config set-credentials webkubectl-user --token=${arg2}` > /dev/null 2>&1
    echo `kubectl config set-cluster kubernetes --server=${arg1}` > /dev/null 2>&1
    echo `kubectl config set-context kubernetes --cluster=kubernetes --user=webkubectl-user` > /dev/null 2>&1
    echo `kubectl config use-context kubernetes` > /dev/null 2>&1
fi

if [ ${KUBECTL_INSECURE_SKIP_TLS_VERIFY} == "true" ];then
    {
        clusters=`kubectl config get-clusters | tail -n +2`
        for s in ${clusters[@]}; do
            {
                echo `kubectl config set-cluster ${s} --insecure-skip-tls-verify=true` > /dev/null 2>&1
                echo `kubectl config unset clusters.${s}.certificate-authority-data` > /dev/null 2>&1
            } || {
                echo err > /dev/null 2>&1
            }
        done
    } || {
        echo err > /dev/null 2>&1
    }
fi

#chown -R $(whoami):users .kube

export TMPDIR=./cache

envs=`env`
for env in ${envs[@]}; do
    if [[ $env == GOTTY* ]];
    then
        unset ${env%%=*}
    fi
done

unset WELCOME_BANNER PPROF_ENABLED KUBECTL_INSECURE_SKIP_TLS_VERIFY SESSION_STORAGE_SIZE KUBECTL_VERSION

exec sudo -u root /bin/bash --init-file ./bashrc
