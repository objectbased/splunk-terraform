#!/bin/bash

# Init setup
yum update -y
instance_id=$(curl http://169.254.169.254/latest/meta-data/instance-id)
hostnamectl set-hostname "aws-splunk-single-node-$instance_id.objectbased.net"
yum install -y python3

# Set ulimits through limits.d

echo "# base ulimits for splunk" >> /etc/security/limits.d/99-splunk.conf
echo "splunk    soft    nofile    65535" >> /etc/security/limits.d/99-splunk.conf
echo "splunk    hard    nofile    65535" >> /etc/security/limits.d/99-splunk.conf
echo "splunk    soft    nproc     20480" >> /etc/security/limits.d/99-splunk.conf
echo "splunk    hard    nproc     20480" >> /etc/security/limits.d/99-splunk.conf

# disable THP

if test -f /sys/kernel/mm/transparent_hugepage/enabled;
then
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi

if test -f /sys/kernel/mm/transparent_hugepage/defrag;
then
    echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi

# Disable rsyslog
systemctl stop rsyslog
chkconfig rsyslog off

# Splunk Install and Setup
cd /tmp
wget -O splunk-9.0.5-e9494146ae5c.x86_64.rpm 'https://download.splunk.com/products/splunk/releases/9.0.5/linux/splunk-9.0.5-e9494146ae5c.x86_64.rpm'
sudo yum localinstall splunk-9.0.5-e9494146ae5c.x86_64.rpm -y
sudo su splunk
/opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd testing123
exit

# Set Alias for easier administration
echo 'alias splunk="/opt/splunk/bin/splunk"' >> /opt/splunk/.bashrc
chown splunk:splunk /opt/splunk/.bashrc
bash

# Bootstart with systemd
/opt/splunk/bin/splunk enable boot-start -user splunk -systemd-managed 1
/opt/splunk/bin/splunk restart

# Clean up
rm -f /tmp/splunk-9.0.5-e9494146ae5c.x86_64.rpm