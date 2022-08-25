#!/bin/bash

MENU="- Ansible Devstack Menu -"
OPTIONS=( \
  "Install Devstack" \
  "Install Devstack with Monasca" \
  "Install Devstack with Monasca + Skyline" \
  "Install Devstack with Monasca + Skyline + Safir Gocmen" \
  "Install Devstack with Monasca + Skyline + Safir Billing" \
  "Install Devstack with Monasca + Skyline + Safir Gocmen + Safir Billing" \
  "Install Safir Gocmen to a Devstack that is already created" \
  "Install Safir Billing to a Devstack that is already created" \
)

createLocalConf(){
  for i in $(eval echo {0..$(($numberofhosts - 1))})
  do
    var_ip=host${i}_ip
 
    cat <<EOF > devstack/local$i-deneme.conf
[[local|localrc]]
HOST_IP=${!var_ip}

ADMIN_PASSWORD=admin
DATABASE_PASSWORD=\$ADMIN_PASSWORD
RABBIT_PASSWORD=\$ADMIN_PASSWORD
SERVICE_PASSWORD=\$ADMIN_PASSWORD
SERVICE_TOKEN=\$ADMIN_PASSWORD

LOGFILE=\$DEST/logs/stack.sh.log
LOGDIR=\$DEST/logs
LOG_COLOR=False

enable_service rabbit key horizon mysql
EOF
  done
}

addMonascaToLocalConf(){
  for i in $(eval echo {0..$(($numberofhosts - 1))})
  do
  
    cat <<EOF >> devstack/local$i-deneme.conf
enable_service tempest

MONASCA_DATABASE_USE_ORM=\${MONASCA_DATABASE_USE_ORM:-false}
MONASCA_API_IMPLEMENTATION_LANG=\${MONASCA_API_IMPLEMENTATION_LANG:-python}
MONASCA_PERSISTER_IMPLEMENTATION_LANG=\${MONASCA_PERSISTER_IMPLEMENTATION_LANG:-python}
MONASCA_METRICS_DB=\${MONASCA_METRICS_DB:-influxdb}

enable_plugin monasca-api https://opendev.org/openstack/monasca-api
enable_plugin monasca-tempest-plugin https://opendev.org/openstack/monasca-tempest-plugin
EOF
  done
}

addSkylineToLocalConf(){
  for i in $(eval echo {0..$(($numberofhosts - 1))})
  do
    cat <<EOF >> devstack/local$i-deneme.conf
enable_plugin skyline-apiserver https://opendev.org/skyline/skyline-apiserver
EOF
  done
}

createInventory(){
  echo -n "" > inventory

  for i in $(eval echo {0..$(($numberofhosts - 1))})
  do
    var_ip=host${i}_ip
    var_user=host${i}_user
    var_private_key=host${i}_private_key
  
    cat <<EOF >> inventory
host$i ansible_ssh_host=${!var_ip} ansible_user=${!var_user} ansible_ssh_private_key_file=${!var_private_key} \
local_conf_file=local$i-deneme.conf
EOF
  done
}

createAnsibleCfg(){
cat <<EOF > ansible.cfg
[defaults]
inventory = inventory
EOF
}

getHostInfo(){
  for i in $(eval echo {0..$(($numberofhosts - 1))})
  do
    read -p "Please Enter Host$i IP: `echo $'\n> '`" host${i}_ip
    read -p "Please Enter Host$i Username: `echo $'\n> '`" host${i}_user
    read -p "Please Enter Host$i Key File Location: `echo $'\n> '`" host${i}_private_key
  
    var_ip=host${i}_ip
    var_user=host${i}_user
    var_private_key=host${i}_private_key
  
    echo "Host$i IP: ${!var_ip}"
    echo "Host$i Username: ${!var_user}"
    echo "Host$i Key File Location: ${!var_private_key}"
  done
}

getBitbucketInfo(){
  read -p "Please Enter Bitbucket Username: `echo $'\n> '`" bitbucket_username
  read -sp "Please Enter Bitbucket Password: `echo $'\n> '`" bitbucket_password
}

getNumberOfHost(){
  read -p "Please enter how many hosts you want to be installed on: `echo $'\n> '`" numberofhosts
}

getOpenstackBranch(){
  read -p "`echo $'\n'`Please enter Openstack branch you want to install: `echo $'\n> '`" branch
}

installDevstack(){
  ansible-playbook playbooks/install-devstack.yml --extra-vars "openstack_branch=$branch" -v
}

makeMonascaConf(){
  ansible-playbook playbooks/configure-logs.yml -v
}

installSafirGocmenToDevstack(){
  ansible-playbook playbooks/install-safirgocmen.yml --extra-vars "username=$bitbucket_username password=$bitbucket_password" -v
}

installSafirBillingToDevstack(){
  ansible-playbook playbooks/install-safirbilling.yml --extra-vars "username=$bitbucket_username password=$bitbucket_password" -v
}

select i in "${OPTIONS[@]}" ; do
  case $i in
    "Install Devstack")
      /bin/bash install-ansible.sh
      getNumberOfHost
      getHostInfo
      getOpenstackBranch
      createInventory
      createAnsibleCfg
      createLocalConf
      installDevstack
      echo "1"
      break
      ;;
    "Install Devstack with Monasca")
      getNumberOfHost
      getHostInfo
      getOpenstackBranch
      createInventory
      createAnsibleCfg
      createLocalConf
      addMonascaToLocalConf
      installDevstack
      makeMonascaConf
      echo "2"
      break
      ;;
    "Install Devstack with Monasca + Skyline")
      getNumberOfHost
      getHostInfo
      getOpenstackBranch
      createInventory
      createAnsibleCfg
      createLocalConf
      addMonascaToLocalConf
      addSkylineToLocalConf
      installDevstack
      makeMonascaConf
      echo "3"
      break
      ;;
    "Install Devstack with Monasca + Skyline + Safir Gocmen")
      getNumberOfHost
      getHostInfo
      getOpenstackBranch
      getBitbucketInfo
      createInventory
      createAnsibleCfg
      createLocalConf
      addMonascaToLocalConf
      addSkylineToLocalConf
      installDevstack
      makeMonascaConf
      installSafirGocmenToDevstack
      echo "4"
      break
      ;;
    "Install Devstack with Monasca + Skyline + Safir Billing")
      getNumberOfHost
      getHostInfo
      getOpenstackBranch
      getBitbucketInfo
      createInventory
      createAnsibleCfg
      createLocalConf
      addMonascaToLocalConf
      addSkylineToLocalConf
      installDevstack
      makeMonascaConf
      installSafirBillingToDevstack
      echo "5"
      ;;
    "Install Devstack with Monasca + Skyline + Safir Gocmen + Safir Billing") 
      getNumberOfHost
      getHostInfo
      getOpenstackBranch
      getBitbucketInfo
      createInventory
      createAnsibleCfg
      createLocalConf
      addMonascaToLocalConf
      addSkylineToLocalConf
      installDevstack
      makeMonascaConf
      installSafirGocmenToDevstack
      installSafirBillingToDevstack
      echo "6"
      ;;
    "Install Safir Gocmen to a Devstack that is already created")
      getNumberOfHost
      getHostInfo
      getOpenstackBranch
      getBitbucketInfo
      createInventory
      createAnsibleCfg
      installSafirGocmenToDevstack
      echo "7"
      ;;
    "Install Safir Billing to a Devstack that is already created")
      getNumberOfHost
      getHostInfo
      getOpenstackBranch
      getBitbucketInfo
      createInventory
      createAnsibleCfg
      installSafirBillingToDevstack
      echo "8"
      ;;
    "Quit")
      echo "999"
      break;
      ;;
    *)
      echo "Invalid option $REPLY"
      break;
      ;;
  esac
done
