## Ring Prep for my lab work

#### Ansible playbook to setup fresh install for Ring install


This will resolve common issues in setting up a lab:


* Stop firewalld
* Disable service firewalld
* Disable SELinux
* Add DNS to /etc/resolv.conf, without passing regexp
* create /etc/scality directory unless present
* create /etc/scality/backup.conf unless present
* Install the latest version of vim
* Install the latest version of tmux
* Install the latest version of iperf3

#### For Storage Servers only
* add fix for vmware virtual drives to ensure they show up as ssd
* add fix for vmware virtual drives to ensure they show up as hdd


