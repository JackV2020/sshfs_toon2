#!/bin/sh
#
# Filename  : sshfs-mount.sh
# Purpose   : mount a remote filesystem via remote sftp server
#
# Optional parameters :
#   1 : MODE       rw to enable write access
#   2 : MOUNTPOINT mount directory, created by this script when missing
#   3 : REMOTE     the remote directory
#
# Defaults for these 3 optional parameters are configured below.
#
# Access Requirements:
#
#   A toon specific public key in ~/.ssh/authorized_keys on the target
#   host is required to avoid password prompts.
#   Generate the key on your toon :
#     Execute: dropbearkey -f id_ecdsa -t ecdsa -s 256
#     When asked for passwords just enter.
#     Copy the part 'ecdsa-sha2-nistp256 ..... root@hostname-of-toon'
#     from the output.
#     Add this as a line to authorized_keys on the target....
#       (On the target, so not on your toon and be carefull):
#     Logon with the account you want to have the public key like pi on
#     your raspberry pi.
#       NOTE THE 2 chevrons >> in the next command, make sure to use 2 and not 1 !!
#     execute: echo ecdsa-sha2-nistp256 ..... root@hostname-of-toon >> ~/.ssh/authorized_keys
#   Now the remote host trusts your toon root account to login with the key however...
#   Your toon does not know the remote host yet so you have to tell it once.
#     On your toon:
#     Execute: ssh -i ~/.ssh/id_ecdsa <user@remote-host>
#         like ssh -i ~/.ssh/id_ecdsa pi@pi31.home
#         or like ssh -i ~/.ssh/id_ecdsa pi@192.168.4.123
#  
#   LOST YOUR PUBLIC KEY and need it for another host?
#   You can retrieve it on your toon:
#     Execute: dropbearkey -y -f id_ecdsa
#     Find 'ecdsa-sha2-nistp256 ..... root@hostname-of-toon'
#
# EXTRA ACCESS REQUIREMENTS MAY BE:
#
# When you do call sshfs-mount.sh interactively but via tsc or inittab
# or maybe something else the process may just be created and not run
# from /root but simply from / and it does not know the remote host.
# Fix this on your toon:
#   Execute: mkdir /.ssh
#   Execute: ln -s /root/.ssh/known_hosts /.ssh/known_hosts
# Now the next time the process will know the remote host.
#
set -eu
#
# BUNDLE=full path to this script directory
#
BUNDLE=$(dirname "$(readlink -f "$0")")
#
# Configure your defaults
#
MODE=-o${1:-ro}
MOUNTPOINT=${2:-/mnt/pi}
#
# REMOTE with hostname or when you use IP addresses.....
#     something like REMOTE=${3:-pi@192.168.4.123} 
# Note this version only supports the mount of the root
#     so no directory like pi@pi31.home:/home/pi
#
REMOTE=${3:-pi@pi31.home}
#
# sshfs-0.1 needs your private key for authentication
#
KEY=${SSHFS_KEY:-/root/.ssh/id_ecdsa}
#
# Explain where our binaries are
#
export PATH="$BUNDLE/bin:$PATH"
#
# Explain where our libraries are
#
export LD_LIBRARY_PATH="$BUNDLE/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
#
# Explain where the private key can be found
#
export SSHFS_SSH_KEY="$KEY"
#
# Make sure the mount folder exists
#
mkdir -p "$MOUNTPOINT"
#
# Make sure nothing is mounted on the mount folder
#
mount | grep "sshfs-0.1 on $MOUNTPOINT">/dev/null && $BUNDLE/bin/fusermount -u $MOUNTPOINT
#
# Mount it
#
(exec "$BUNDLE/bin/sshfs-0.1" "$REMOTE" "$MOUNTPOINT" "$MODE") &
#
# Show mount
#
sleep 5
mount | grep " on $MOUNTPOINT "
