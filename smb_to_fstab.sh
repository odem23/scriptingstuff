#!/bin/bash

# Do not change! 
# /root/creds/creds.txt is ok!
PWFILE=creds.txt    # pwfile
PWDIR=/root/.credentials  # Target credentials folder

# Configure here
BASEDIR=/mnt/smb      # Target folder (local)
SMBHOST=192.168.178.1 # IP or resolvable HOST
SMBSHARE=BigData      # Foldername
SMBUSER=user          # Leave blank to read from pwfile
SMBPASS=pass          # Leave blank to read from pwfile
#
# Configuration goal : Mount share 
#    from //$SMBHOST/$SMBSHARE (Remote) 
#    to $BASEDIR/$SMBHOST/$SMBSHARE (Local) 
#    as $SMBUSER (Remote)
#    with $SMBPASS (Remote)


# Install tools
apt-get install cifs-utils smbclient --force-yes --yes &>/dev/null


# Prepare target dir
MOUNTDIR=$BASEDIR/$SMBHOST/$SMBSHARE
umount $MOUNTDIR
mkdir -p $MOUNTDIR
chown root:root $MOUNTDIR
chmod 755 -R $MOUNTDIR
if [ -d $MOUNTDIR ] ; then
    printf "[+] Mountdir created at '$MOUNTDIR'\n"
else
    printf "[-] Mountdir NOT present!\nExiting now...\n"
    exit 1
fi

# Prepare credential file
TARGETCRED=${PWDIR}/${SMBHOST}_${PWFILE}
if [ "$SMBUSER" != ""  -a  "$SMBPASS" != "" ] ; then
    printf "[+] Copy password file to '$PWDIR'\n"
    mkdir -p $PWDIR &>/dev/null
    echo "username=$SMBUSER" >  $TARGETCRED
    echo "password=$SMBPASS" >> $TARGETCRED
    chmod 0600 -R $PWDIR
    printf "[+] Password file created!\n"
else
    printf "[-] Error on reading user and password!\nExiting now...\n"
    exit 2
fi

# Check if entry already present
FSTAB_STR="//$SMBHOST/$SMBSHARE $MOUNTDIR cifs auto,users,credentials=$TARGETCRED 0 0"
FSTAB_TEST=$(cat /etc/fstab | grep "$FSTAB_STR")
if [ "$FSTAB_TEST" == "" ] ; then
    # Append entry
    echo $FSTAB_STR >> /etc/fstab
    #cat /etc/fstab
    printf "[+] Entry appended to /etc/fstab !\n"
else
    printf "[-] Entry already present in /etc/fstab! Doing nothing...\n"
fi

# Mount and list share
printf "[+] Mounting dir '$MOUNTDIR'\n"
printf "[+] Check folder with 'ls -la $MOUNTDIR'\n"
mount $MOUNTDIR
exit 0

