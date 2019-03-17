# Setup cluster note documents

## Model

Two nodes:

- 192.168.123.10
- 192.168.123.11



## Install steps

- Install packages and enable pcsd

```bash

<!-- perform both on two nodes 192.168.123.10, 192.168.123.11 -->
// Install package

yum install -y pacemaker pcs psmisc policycoreutils-python

// Disable selinux
setenforce 0
sed -i.bak "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/selinux/config

// Enable pcsd

systemctl start pcsd.service
systemctl enable pcsd.service

// change passwd of hacluster user - username: hacluster, password: hacluster

passwd hacluster

```


## Design cluster HA script for jenkins master single

- Script: `jenkins-master.sh`
- Docker-compose file `jenkins-master.yml`
- Start args - `startargs` arg in pcs command: `--start --docker-compose /home/centos/jenkins_master.yml --container-name jenkins-master --startup-timeout 90`
- Stop args - `stopargs` arg in pcs command: `--stop --docker-compose /home/centos/jenkins_master.yml --container-name jenkins-master`
- Monitor args - `args` arg in pcs command: `--monitor --container-name jenkins-master`
- `startandstop` arg value: 1
- `alwaysrun` arg value: 1

With this setup

- Start command:  `jenkins-master.sh --start --docker-compose /home/centos/jenkins_master.yml --container-name jenkins-master --startup-timeout 360`
- Stop command:  `jenkins-master.sh --stop --docker-compose /home/centos/jenkins_master.yml --container-name jenkins-master`
- Monitor command: `jenkins-master.sh --monitor --container-name jenkins-master`