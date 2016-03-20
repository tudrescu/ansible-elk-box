run playbook with

  ansible-playbook -i vagrant-guest-direct install-elk-playbook.yml -vv --extra-vars "java_useproxy=false"

to use a proxy run with

  ansible-playbook -i vagrant-guest-proxy install-elk-playbook.yml -vv --extra-vars "java_useproxy=true"

For available tags consult documentation.
