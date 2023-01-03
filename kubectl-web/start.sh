export SESSION_STORAGE_SIZE=10M
export WELCOME_BANNER="Welcome to Web Kubectl, try kubectl --help."
export KUBECTL_INSECURE_SKIP_TLS_VERIFY=true

cp .bashrc bashrc

exec sh -c './start-webkubectl.sh'
