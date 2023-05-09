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

Below is a little detail on what everything is doing...


vagrant@pw-ldap:~$ history
    1  w
    2  pwd
    3  df -h
    4  ping 192.168.56.4
    5  dpkg -l
    6  dpkg -l | grep fish
    7  dpkg -l | grep slapd
    8  ps -ef | grep slap
    9  dpkg -l | grep apparm
   10  vim /etc/default/slapd
   11  hostname
   12  cat /etc/hosts
   13  cd /etc/ldap
   14  ll
   15  ls -al
   16  cat ldap.conf
   17  hostname
   18  hostname -f
   19  ping pw-ldap
   20  ping pw-ldap.test
   21  cd
   22  ls -al
   23  pwd
   24  git clone https://github.com/jeffknerr/ldapscripts.git
   25  ll
       git clone ldapscripts from jeffknerr
   27  cd ldapscripts/
   29  cat base.ldif
   30  sudo dpkg-reconfigure slapd
           dc=test  (domain and org)
           pw is ldap.123
   31  sudo ldapwhoami -H ldap://localhost -x
       anonymous
   32  nmap localhost
   33  cat base.ldif
   34  cp base.ldif testbase.ldif
   35  vim testbase.ldif    (change dc=test)
   40  sudo ldapadd -x -D cn=admin,dc=test -f testbase.ldif -W
   42  sudo ldapmodify -H ldapi:/// -Y EXTERNAL -f logging.ldif
   44  sudo ldapwhoami -H ldap://localhost -x
   45  sudo ldapwhoami -H ldap://localhost -x -D cn=admin,dc=test -W
       dn:cn=admin,dc=test
   47  sudo ldapmodify -H ldapi:/// -Y EXTERNAL -f maxsizedb.ldif
   49  sudo ldapmodify -H ldapi:/// -Y EXTERNAL -f indexing.ldif
   51  cp access.ldif testaccess.ldif
   52  vim testaccess.ldif   (dc=test)
   53  sudo ldapmodify -H ldapi:/// -Y EXTERNAL -f testaccess.ldif
   55  sudo ldapmodify -H ldapi:/// -Y EXTERNAL -f passwd.ldif
   57  sudo ldapmodify -H ldapi:/// -Y EXTERNAL -f limits.ldif
   59  sudo ldapmodify -H ldapi:/// -Y EXTERNAL -f memberof.ldif
   62  sudo ldapadd -H ldapi:/// -Y EXTERNAL -f refint.ldif
   64  cp groupofnames.ldif testgroupofnames.ldif 
   65  vim testgroupofnames.ldif  (dc=test)
   66  sudo ldapadd -x -D cn=admin,dc=test -H ldapi:// -W -f testgroupofnames.ldif
   71  sudo ldapadd -H ldapi:/// -Y EXTERNAL -f passwordservice.ldif    (from ansible)
   72  ls /etc/ldap/schema/    (get passwordservice.schema from ansible)
   76  sudo systemctl restart  slapd.service
   77  ps -ef | grep slap

set up /etc/ldap/ldap.conf

BASE    dc=test
URI     ldap://localhost

# configure ldapscripts

set up /etc/ldapscripts/ldapscripts.conf

SERVER="ldap://localhost"
SUFFIX="dc=test"
GSUFFIX="ou=groups"
USUFFIX="ou=people"
BINDDN="cn=admin,dc=test"
BINDPWDFILE="/etc/ldapscripts/ldapscripts.passwd"

and the passwd file with ldap.123 and :noeol in vim

# can see basics:

  106  ldapsearch -x -H ldap://localhost


# use it to add users, groups

but sudo ldapaddgroup pwapp 2023 fails...

but ldif files seem to work!!

- user1.ldif
- user2.ldif

todo:

pwapp.ldif (add the group)
admin1.ldif (add the user, add them to the group)

now see if we can get local PasswordService to talk to our vg ldap server...

  143  sudo vim /etc/ldapscripts/ldapscripts.conf
BINDDN="cn=admin,dc=test"
BINDPWDFILE="/etc/ldapscripts/ldapscripts.passwd"
(were other entries for these farther down...)
  144  sudo ldapaddgroup foo 2222
  145  sudo ldapaddgroup pwapp 2000
(fails...it's not a posix group, and already exists)

  147  ldapsearch -x -H ldapi:///
  149  sudo ldapaddusertogroup user2 foo
  150  sudo ldapaddusertogroup user2 pwapp
(also fails, there's a special way to add members of this)

  155  sudo ldapadduser stu1 users 5000
  156  ldapsearch -x -H ldapi:///
  157  cp user2.ldif user3.ldif
  158  vim user3.ldif
  166  sudo ldapadd -x -D cn=admin,dc=test -H ldapi:// -W -f user3.ldif
failed...can't add swatcs stuff this way
  167  cp user3.ldif notworking.ldif
  168  vim user3.ldif
  169  sudo ldapadd -x -D cn=admin,dc=test -H ldapi:// -W -f user3.ldif
  170  cp notworking.ldif swatcs.ldif
  171  vim swatcs.ldif
dn: uid=user3,ou=people,dc=test
changetype: modify
add: objectClass
objectClass: SwatCSUser
-
add: swatcsAgreed
swatcsAgreed: FALSE
-
add: swatcsLastSeen
swatcsLastSeen: 19700101000000-0500

  172  sudo ldapadd -x -D cn=admin,dc=test -H ldap://localhost -W -f swatcs.ldif
  174  ldapsearch -x -H ldapi:///
  177  cp ldapscripts/pwappGROUP.ldif .
  178  vim pwappGROUP.ldif
dn: uid=user1,ou=people,dc=test
changetype: modify
add: memberOf
memberOf: cn=pwapp,ou=groups,dc=test
-

dn: cn=pwapp,ou=groups,dc=test
changetype: modify
add: member
member: uid=user1,ou=people,dc=test
-

  185  sudo ldapadd -x -D cn=admin,dc=test -H ldap://localhost -W -f pwappGROUP.ldif
  186  ldapsearch -x -H ldapi:///

* iterate again, figure out how to ansible stuff:
     - dpkg-reconfigure, set ldap password
     - configure the ldapscripts stuff (password and conf files)

5/1/2023
--------

Vagrant.configure("2") do |config|
  config.vm.box = "generic/debian11"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 512
    v.linked_clone = true
  end

  # Application server 1.
  config.vm.define "pw1" do |app|
    app.vm.hostname = "pw-app1.test"
    app.vm.network :private_network, ip: "192.168.56.4"
  end

  # Application server 2.
  config.vm.define "pw2" do |app|
    app.vm.hostname = "pw-app2.test"
    app.vm.network :private_network, ip: "192.168.56.5"
  end

  # LDAP server.
  config.vm.define "ldap" do |db|
    db.vm.hostname = "pw-ldap.test"
    db.vm.network :private_network, ip: "192.168.56.6"
  end
end

- iterate another time:
vim ~/.ssh/known_hosts   (del the keys for pw1,pw2,ldap)
vg up
vg ssh pw2
vg status ldap
vg status pw1
vg ssh pw1
vg plugin install vagrant-scp
ansible-playbook ldap.yml


todo:
- vg: use same ssh keys each time???
- vg: cp allspice root auth_keys file over
> export ANSIBLE_NOCOWS=1
- crypt passwords in ldif files

iterate:
vg halt
vg destroy
vg up
vg status
vim ~/.ssh/known_hosts
 (delete old keys)
 or:
ssh-keygen -f "/home/knerr/.ssh/known_hosts" -R "192.168.56.6"
ssh-keygen -f "/home/knerr/.ssh/known_hosts" -R "192.168.56.5"
ssh-keygen -f "/home/knerr/.ssh/known_hosts" -R "192.168.56.4"
 then:
ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.4
ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.5
ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.6
ansible pwserv -a date
 (say "yes" to all)
ansible-playbook ldap.yml
ansible-playbook pwapp.yml
vg ssh ldap
vg ssh pw1
vg ssh pw2
 (just to check)
http://192.168.56.5
http://192.168.56.4
