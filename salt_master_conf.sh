#!/bin/bash

rpm --import https://repo.saltstack.com/yum/redhat/6/x86_64/latest/SALTSTACK-GPG-KEY.pub

cat > /etc/yum.repos.d/saltstack.repo << EOL

[saltstack-repo]
name=SaltStack repo for RHEL/CentOS 6
baseurl=https://repo.saltstack.com/yum/redhat/6/x86_64/latest/
enabled=1
gpgcheck=1
gpgkey=https://repo.saltstack.com/yum/redhat/6/x86_64/latest/SALTSTACK-GPG-KEY.pub

EOL

yum clean -y expire-cache

yum update -y

yum install -y salt-master salt-minion salt-ssh salt-syndic salt-cloud

chkconfig salt-master on

cat >> /etc/salt/master << EOL

file_roots:
  base:
    - /srv/salt


auto_accept: True

reactor:
  - 'salt/cloud/*/cache_node_new':
    - '/srv/reactor/autoscale.sls'
  - 'salt/cloud/*/cache_node_missing':
    - '/srv/reactor/autoscale.sls'

autoscale:
  provider: my-ec2-config
  ssh_username: ec2-user


EOL

cat >> /etc/salt/cloud << EOL

update_cachedir: True
diff_cache_events: True
cache_event_strip_fields:
  - password
  - priv_key

EOL

cat > /etc/salt/cloud.providers.d/ec2.conf << EOL

my-ec2-config:
  id: AKIAIDUGV6NQWK4GNGNA
  key: '1Ik7gMEHpsRPWRt18/rG4GeWPlPu68jWETqMWPcY'
  keyname: test-trial
  securitygroup: default
  private_key: /etc/salt/test-trial.pem
  location: us-west-2
  provider: ec2
  minion:
    master: $HOSTNAME.us-west-2.compute.internal
EOL

mkdir /srv/{reactor,salt}



service salt-master start






