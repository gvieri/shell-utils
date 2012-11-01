#!/bin/bash
#######################################################
# this scripts set the environment and the directories 
# copies the files necessary to set up a chrooted user
#######################################################
# AUTHOR: Giovambattista Vieri 
# LICENSE: GPL v2
#
# parameter: user name 
#
# WARNING no checks are done on input 
#
#######################################################

function jaillibforAcommand {
COMMAND=$1
DEST=$2

if [ -f $COMMAND ]
then
        FILES="$(ldd $COMMAND | awk '{ print $3 }' |egrep -v ^'\(')"
        
        for FILE in $FILES
        do
                DIRDEST="$(dirname $FILE)"
                echo $DIRDEST
                if [ ! -d $DEST$DIRDEST ]
                then
                        mkdir -p $DEST$DIRDEST
                fi
                cp $FILE $DEST$DIRDEST
        done

else
        echo "file $COMMAND does not exist or, cannot be read"
        exit  1
fi
}

# verifica utente

if [ -d /home/$1 ]
then
mkdir -p /home/$1/{dev,etc,lib,usr,bin}
mkdir -p /home/$1/usr/bin
mkdir -p /home/$1/usr/libexec/openssh
mknod -m 666 /home/$1/dev/null c 1 3
mknod -m 666 /home/$1/dev/zero c 1 3
cp -p /lib/{ld-linux.so.2,libc.so.6,libdl.so.2,libtermcap.so.2,libnss_files.so.2,libnss_compat.so.2} /home/$1/lib/
cp -p /lib64/{ld-linux-x86-64.so.2,libc.so.6,libdl.so.2,libtermcap.so.2,libnss_files.so.2,libnss_compat.so.2} /home/$1/lib64/
chown root:root /home/$1

################################################################
# do not copy too much files from your server /etc directory....
################################################################

cd /home/$1/etc
##cp /etc/ld.so.cache .
##cp -avr /etc/ld.so.conf.d/ .
cp /etc/ld.so.conf .
##cp /etc/nsswitch.conf .
grep $1 /etc/passwd >/home/$1/etc/passwd
##cp /etc/group .
cp /etc/hosts .
##cp /etc/resolv.conf .

cd /home/$1/usr/bin
cp /usr/bin/scp .
cp /usr/bin/rssh .
cp /usr/bin/sftp .
cd /home/$1/usr/libexec/openssh/
cp /usr/libexec/openssh/sftp-server .
cd /home/$1/usr/libexec
cp /usr/libexec/rssh_chroot_helper .


jaillibforAcommand /usr/bin/scp /home/$1/
jaillibforAcommand /usr/bin/rssh /home/$1/
jaillibforAcommand /usr/bin/sftp /home/$1/
jaillibforAcommand /usr/libexec/openssh/sftp-server /home/$1/
jaillibforAcommand /usr/libexec/rssh_chroot_helper /home/$1/


else
	echo "home directory for $1 user not found"
	exit 1


fi



