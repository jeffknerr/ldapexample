#! /bin/bash

umask 0022

NAME=PasswordService
WHERE=/var/www
# deploy dir
DDIR=${WHERE}/${NAME}
# repo dir
REPO=/home/vagrant/PasswordService
# for debugging
OUTF=/home/vagrant/outputdeploy.txt

if [ -d $REPO ] ; then
  cd $REPO
else
  echo "no $REPO directory???"
  exit 1
fi

# stop, if already running
ps -ef | grep gunicorn | grep -v grep > /dev/null 2>&1
if [ $? -eq 0 ] ; then 
    supervisorctl stop $NAME > $OUTF 2>&1
fi

# copy files
rsync -aq --delete --exclude-from ${REPO}/sync-exclude ${REPO} $WHERE > $OUTF 2>&1
# copy in special test files
cp /home/vagrant/config.py ${DDIR}/config.py
cp /home/vagrant/env ${DDIR}/.env
chown -R vagrant:vagrant ${DDIR}

# check for venv file
# make if it doesn't exist
if [ ! -d ${WHERE}/${NAME}/venv ] ; then
  cd ${WHERE}/${NAME}
  python3 -m venv venv
  # must be bash for source to work...
  source ./venv/bin/activate
  pip install -r ${REPO}/requirements.txt > $OUTF 2>&1
  pip install gunicorn > $OUTF 2>&1
  deactivate
fi

# apply db upgrades, if any
cd ${WHERE}/${NAME}
source ./venv/bin/activate
flask db upgrade > $OUTF 2>&1
deactivate

# make the logs dir, if not already there...
if [ ! -d $DDIR/logs ] ; then
  mkdir $DDIR/logs
fi
chown -R vagrant:vagrant ${DDIR}

# start/restart
# need to reload first time new conf file is copied in
supervisorctl reload > $OUTF 2>&1
sleep 2
# start, if not already running
ps -ef | grep gunicorn | grep -v grep > /dev/null 2>&1
if [ $? -ne 0 ] ; then 
    supervisorctl start $NAME > $OUTF 2>&1
fi
