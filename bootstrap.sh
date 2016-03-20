#!/usr/bin/env bash
export PYTHONUNBUFFERED=1
export ANSIBLE_FORCE_COLOR=1

VAGRANT_DIRECT="vagrant-guest-direct"
VAGRANT_PROXY="vagrant-guest-proxy"

INVENTORY_FILE="${VAGRANT_DIRECT}"
LIMIT="${VAGRANT_DIRECT}"                          # which ansible group to run

USE_PROXY=false
ANSIBLE_TAGS=""
MAIN_PLAYBOOK="install-elk-playbook.yml"

while getopts "p:t:m:i:l:" opt; do
    case "$opt" in
        p)  USE_PROXY=$OPTARG
            ;;
        t)  ANSIBLE_TAGS=$OPTARG
            ;;
        m)  MAIN_PLAYBOOK=$OPTARG
            ;;
        i)  INVENTORY_FILE=$OPTARG
            ;;
        l)  LIMIT=$OPTARG
            ;;
    esac
done

# initialize the inventory and the limit
if [[ "${USE_PROXY}" == "true" ]]; then
  INVENTORY_FILE="${VAGRANT_PROXY}"
else
  INVENTORY_FILE="${VAGRANT_DIRECT}"
fi


# build ansible options
ANSIBLE_OPTS=()
ANSIBLE_OPTS+=( "${MAIN_PLAYBOOK}" )
ANSIBLE_OPTS+=( "--connection=local" )
ANSIBLE_OPTS+=( "-vv" )
ANSIBLE_OPTS+=( "--inventory=/tmp/${INVENTORY_FILE}" )
# ANSIBLE_OPTS+=( "-l ${LIMIT}" )
ANSIBLE_OPTS+=( "--extra-vars=\"{java_useproxy=$USE_PROXY}\"" )

if [[ ! -z "${ANSIBLE_TAGS}" ]]; then
    ANSIBLE_OPTS+=( "--tags=${ANSIBLE_TAGS}" )
fi

# setup inventory for vagrant guests
# directory is mirrored on guest
cd /vagrant/provisioning
# fix permissions on ansible logging dir
sudo find log -type d -exec chmod 777 {} \;

cp "${INVENTORY_FILE}" /tmp
chmod -X "/tmp/${INVENTORY_FILE}"

echo "Inventory file : ${INVENTORY_FILE}"
echo "Ansible Playbook Run Parameters : ${ANSIBLE_OPTS[@]}"


if [ $(dpkg-query -W -f='${Status}' ansible 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Add APT repositories"
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get install -qq software-properties-common &> /dev/null || exit 1

    sudo apt-add-repository ppa:ansible/ansible &> /dev/null || exit 1
    echo "Run APT update"
    sudo apt-get update -qq

    echo "Installing Ansible"
    sudo apt-get install -qq ansible &> /dev/null || exit 1
    echo "Ansible installed"
fi

# invoke ansible playbook with options
ansible-playbook "${ANSIBLE_OPTS[@]}"
