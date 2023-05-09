# ldapexample
example LDAP setup using ansible and vagrant

## quickstart

I did all of this on an Ubuntu 22.04 (jammy) workstation, 
with 32GB of memory, starting in April 2023. Software
versions:

```
ii  ansible 7.5.0-1ppa~jammy
ii  vagrant 2.3.4
```

End result of the following should be 3 virtual machines, one
running an LDAP server, and two running a flask app that 
talks to the LDAP server (all on a private network connected
to your workstation).

```
$ alias vg='vagrant'
$ sudo apt-add-repository -y ppa:ansible/ansible
$ sudo apt-get udpdate
$ sudo apt-get install gnupg software-properties-common 
$ sudo apt-get install ansible vagrant git virtualbox
$ sudo vim /etc/ansible/hosts
$ cat /etc/ansible/hosts
[pw1]
192.168.56.4

[pw2]
192.168.56.5

[pwapp]
192.168.56.4
192.168.56.5

[ldap]
192.168.56.6

[pwserv:children]
pwapp
ldap

[pwserv:vars]
ansible_user=vagrant
ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key

$ git clone https://github.com/jeffknerr/ldapexample.git
$ cd ldapexample
$ export ANSIBLE_NOCOWS=1
# this next one takes a few minutes...
$ vg up
$ vg status
# accept the ssh host keys
$ ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.4
$ ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.5
$ ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.6
$ ansible pwserv -a date
$ ansible-playbook ldap.yml
$ ansible-playbook pwapp.yml
# just to check stuff
$ vg ssh ldap
$ vg ssh pw1
$ vg ssh pw2
# see if the app works (log in as user1 with password user1)
$ http://192.168.56.5
$ http://192.168.56.4
```

## todo

- vagrant: use same ssh keys each time???

## details

Below are some details on what everything is doing...


### vg up

This uses the `Vagrantfile` to create all virtual machines.
The `Vagrantfile` specifies which os/box to run (debian11),
and what hostnames and IP addresses to use.

### ansible-playbook ldap.yml

Once the ldap VM is up, use ansible to configure it (install
software, set up config files, run a script to import all
the ldif file data into slapd).

### ansible-playbook pwapp.yml

Also use ansible to set up the two app servers.
This playbook install software (like nginx and supervisord), 
checks out a git repo for the flask app, and sets up 
mysql and the virtualenv for the flask app.

### test ldap server

Should show user data and ldap running on port 389:

```
$ vg ssh ldap
vagrant@pw-ldap:~$ sudo slapcat
vagrant@pw-ldap:~$ nmap localhost
```

### test app

Open a browser on your workstation and go to 
http://192.168.56.4 (or .5) and you should see the flask app.


### to start over/iterate...

```
vg halt
vg destroy
vg up
vg status
vim ~/.ssh/known_hosts
# delete old keys...or:
ssh-keygen -f "/home/knerr/.ssh/known_hosts" -R "192.168.56.6"
ssh-keygen -f "/home/knerr/.ssh/known_hosts" -R "192.168.56.5"
ssh-keygen -f "/home/knerr/.ssh/known_hosts" -R "192.168.56.4"
# then:
ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.4
ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.5
ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.6
ansible pwserv -a date
ansible-playbook ldap.yml
ansible-playbook pwapp.yml
vg ssh ldap
vg ssh pw1
vg ssh pw2
http://192.168.56.5
http://192.168.56.4
```
