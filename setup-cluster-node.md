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

## Create And Setup Custom OCF agent

References:

- https://dopensource.com/2017/04/27/creating-custom-ocf-resource-agents/

Steps:

- Copy file `generic-script` to `/usr/lib/ocf/resource.d/heartbeat/generic-script`
- Copy files `jenkins-master.yml` and `jenkins-master.sh` to folder `/root/jenkins-master-ha`
- Start pcs cluster: `pcs cluster start --all`
- Create jenkins resource
 
 ```bash
pcs resource create jenkins-master \
  ocf:heartbeat:generic-script \
  script="/root/jenkins-master-ha/jenkins-master.sh" \
  statedir="/dev/shm" alwaysrun="yes" startandstop="1" \
  startargs="--start --docker-compose /root/jenkins-master-ha/jenkins-master.yml --container-name jenkins-master --startup-timeout 360" \ 
  stopargs="--stop --docker-compose /root/jenkins-master-ha/jenkins-master.yml --container-name jenkins-master --startup-timeout 360" \
  args="--monitor --container-name jenkins-master" \
  op start interval=0s timeout=360s op monitor interval=60s --wait
```

- Verify cluster status: `pcs status`
- Verify jenkins-master resource `pcs resource show jenkins-master`

At this time, jenkins-master container will be created in extractly one node in cluster.

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

## References

- https://dopensource.com/2017/04/27/creating-custom-ocf-resource-agents/
- https://wiki.clusterlabs.org/wiki/Pacemaker
