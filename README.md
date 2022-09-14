## Ring Prep for my lab work

#### Ansible playbook to setup fresh install for Ring install





### Remove later
```
#### Fix rotational drive settings for vmware install
for i in $(cat /etc/hosts |grep scal-data |awk '{print $2}');do ssh ${i} "echo 1 > /sys/block/sda/queue/rotational;echo 1 > /sys/block/dm-0/queue/rotational;echo 1 > /sys/block/dm-1/queue/rotational";done


####Verify SELinux disabled if not edit config and scp to the rest of the cluster
[root@scal-sup ~]# vim /etc/sysconfig/selinux
[root@scal-sup ~]# for i in $(grep scal /etc/hosts |awk '{print $2}');do echo ${i};scp /etc/sysconfig/selinux 
${i}:/etc/sysconfig/selinux;done
scal-sup
selinux 100% 542 588.5KB/s 00:00 
scal-data1a
selinux 100% 542 567.0KB/s 00:00 
scal-data1b
selinux 100% 542 552.8KB/s 00:00 
scal-data1c
selinux 100% 542 629.0KB/s 00:00 
scal-data2a
selinux 100% 542 751.4KB/s 00:00 
scal-data2b
selinux 100% 542 673.9KB/s 00:00 
scal-data2c
selinux 100% 542 684.2KB/s 00:00 
scal-data3a
selinux 100% 542 786.3KB/s 00:00 
scal-data3b
selinux 100% 542 715.3KB/s 00:00 
scal-data3c
selinux 100% 542 704.4KB/s 00:00

#### Ethernet Settings
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
NAME="ens192"
DEVICE="ens192"
ONBOOT="yes"
IPADDR=192.168.1.59
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS=192.168.1.107

#### Add ssh key from supervisor to all servers
ssh-copy-id -i ~/.ssh/id_rsa.pub user@host
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1Y+iwuVhe4V52df9sQPt0Dz4rqc5a0+u5XblljYjkHsiqqyrkkQlXD6wpB/CIhw9zGoKwfAK0pfzJCxwnA0ntM5W1qmGzD+AqLY92ChstZ7lgLt5d/bTg79gHwCcATXt/LyMFsi1dQOg+x6baX7GoHBecQ73EAO8uohyYVHxP658UkIOIJMehg9cnouwhhISTZKTkJHiSZLKoqGIuagUFyQzySfNqEcfI2DCTArAp2tldxoypdroMykQs2w5iMVl9RVnpKMy/CiJ95kj4Ps8T67a8+xPzaqMu27RkcizfqQWN/QYmC42pjk0dcCakIc6/i5Du0daw5o/sc7+8KEcP root@scal-sup.localdomain

#### add dns to resolv.conf (IF NEEDED)
[root@scal-sup ~]# for i in $(cat /etc/hosts |grep data); do ssh ${i} "echo 'nameserver 192.168.1.107' > /etc/resolv.conf";done


##### yum add cache for faster installs
yum makecache


#### Verify Time & NTP
timedatectl status |grep -i ntp
NTP enabled: yes
NTP synchronized: yes

systemctl status chronyd.service


#### added virtual memeory setting per (IF NEEDED)
Virtual memory should be tuned, please add "vm.min_free_kbytes = 2097152" in /etc/sysctl.d/60-scality.conf
for i in $(cat /etc/hosts |grep -v "#" |grep -v scal-sup |awk '{print $2}'|grep -v localhost); do echo ${i};scp 60-scality.conf ${i}:/etc/sysctl.d/60-scality.conf;done


#### set rotational on Storage Nodes
[root@scal-sup ~]# for i in $(cat /etc/hosts |grep scal-data |awk '{print $2}');do ssh ${i} "echo 1 > /sys/block/sda/queue/rotational";done
[root@scal-sup ~]# for i in $(cat /etc/hosts |grep scal-data |awk '{print $2}');do ssh ${i} "echo 1 > /sys/block/dm-0/queue/rotational";done
[root@scal-sup ~]# for i in $(cat /etc/hosts |grep scal-data |awk '{print $2}');do ssh ${i} "echo 1 > /sys/block/dm-1/queue/rotational";done


/etc/salt /var/cache/salt /var/run/salt

[root@scal-sup ~]# systemctl stop firewalld.service
[root@scal-sup ~]# systemctl disable firewalld.service
Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service.
Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.

#### Had to make /etc/scality and touch /etc/scality/backup.conf to allow pre-checks to continue
for i in $(cat /etc/hosts |awk '{print $2}' |grep -v localhost |grep -v scal-sup |grep . |sort -u);do echo ${i};ssh ${i} "mkdir /etc/scality/";done
for i in $(cat /etc/hosts |awk '{print $2}' |grep -v localhost |grep -v scal-sup |grep . |sort -u);do echo ${i};ssh ${i} "touch /etc/scality/backup.conf";done


/etc/hosts
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.1.50 scal-sup
192.168.1.51 scal-data1a
192.168.1.52 scal-data1b
192.168.1.53 scal-data1c
192.168.1.54 scal-data2a
192.168.1.55 scal-data2b
192.168.1.56 scal-data2c
192.168.1.57 scal-data3a
192.168.1.58 scal-data3b
192.168.1.59 scal-data3c
```

