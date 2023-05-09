#! /bin/bash

PWF=/etc/ldapscripts/ldapscripts.passwd

ldapadd -x -D cn=admin,dc=test -f testbase.ldif -y $PWF
ldapmodify -H ldapi:/// -Y EXTERNAL -f ldapscripts/logging.ldif
ldapmodify -H ldapi:/// -Y EXTERNAL -f ldapscripts/maxsizedb.ldif
ldapmodify -H ldapi:/// -Y EXTERNAL -f ldapscripts/indexing.ldif
ldapmodify -H ldapi:/// -Y EXTERNAL -f testaccess.ldif
ldapmodify -H ldapi:/// -Y EXTERNAL -f ldapscripts/passwd.ldif
ldapmodify -H ldapi:/// -Y EXTERNAL -f ldapscripts/limits.ldif
ldapmodify -H ldapi:/// -Y EXTERNAL -f ldapscripts/memberof.ldif
ldapadd -H ldapi:/// -Y EXTERNAL -f ldapscripts/refint.ldif
ldapadd -x -D cn=admin,dc=test -H ldapi:// -y $PWF -f testgroupofnames.ldif
ldapadd -H ldapi:/// -Y EXTERNAL -f passwordservice.ldif
systemctl restart  slapd.service
ldapadd -x -D cn=admin,dc=test -H ldapi:// -y $PWF -f user1.ldif
ldapadd -x -D cn=admin,dc=test -H ldapi:// -y $PWF -f user2.ldif
ldapadd -x -D cn=admin,dc=test -H ldapi:// -y $PWF -f admin1.ldif
ldapadd -x -D cn=admin,dc=test -H ldapi:// -y $PWF -f swatcsU1.ldif
ldapadd -x -D cn=admin,dc=test -H ldapi:// -y $PWF -f swatcsU2.ldif
ldapadd -x -D cn=admin,dc=test -H ldapi:// -y $PWF -f swatcsA1.ldif
ldapadd -x -D cn=admin,dc=test -H ldapi:// -y $PWF -f pwappU1.ldif
ldapadd -x -D cn=admin,dc=test -H ldapi:// -y $PWF -f pwappU2.ldif
ldapadd -x -D cn=admin,dc=test -H ldapi:// -y $PWF -f pwappA1.ldif
touch /home/vagrant/DBcreated
