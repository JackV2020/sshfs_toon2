# sshfs bundle for Toon 2

This bundle provides sshfs support for Toon 2.

Why this sshfs bundle? See **The story behind...** below.

It enables you to mount the root directory exposed by the remote SFTP servers on your Toon 2 so Toon 2 can read and optionally write on the remote file systems.

Sadly it is not possible to build this bundle for Toon 1 because that kernel lacks fuse support.

## License

[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)

This project is licensed under the terms of the Unlicense.
<br>For more details, please refer to [UNLICENSE.md](UNLICENSE.md).
<br>For more information, please refer to <http://unlicense.org>.

## Install on Toon 2

Simply copy everything into a directory like /root/sshfs_toon2 and make 3 things executable:

  - chmod 755 /root/sshfs_toon2/bin/sshfs-0.1
  - chmod 755 /root/sshfs_toon2/bin/fusermount
  - chmod 755 /root/sshfs_toon2/sshfs-mount.sh

Other files are fine the way they are and do not need to be executable.

## Enable access from Toon 2

I assume that the remote server like a Raspberry Pi has an SFTP server installed.

You may edit the script sshfs-mount.sh and change the defaults for:

  - MODE ro for read only or rw for read and write access
  - MOUNTPOINT local mount directory to use like /mnt/pi
  - REMOTE remote server to mount like pi@mypi.home

Note that REMOTE mounts the complete SFTP-root because it is limited to user@host and does not support user@host:/remote-directory.

In sshfs-mount.sh you find the instructions to set up the passwordless ssh authentication which is needed to initiate the connection to the target server.

When you follow these instructions you will:

  - generate a private and public ecdsa key pair
  - implement the public key on the target host so it trusts your toon
  - make an initiating connection so your toon knows the remote server
  - and maybe do something extra to support automatic startup

After this you can manually make the mount of the root directory exposed by the SFTP server with:

  - /root/sshfs_toon2/sshfs-mount.sh [ MODE [ MOUNTPOINT [ REMOTE  ] ] ]

You can unmount with:

  - /root/sshfs_toon2/bin/fusermount -u MOUNTPOINT

like

  - /root/sshfs_toon2/bin/fusermount -u /mnt/pi

### The story behind...

Why this SSHFS bundle? Why not?  
I had no need for it but wondered if it would be possible to create it using a tool like GitHub Copilot.  
Since that is a bit tricky because it can run scripts and write your file system I decided to run it in a virtual machine in which I would use a Shared Folder (Machine Folder) so I could export files to the host.  
I installed Oracle VirtualBox with extension pack on my Kubuntu pc and built a virtual Kubuntu machine.  
I also downloaded the Guest additions from the same page: https://download.virtualbox.org/virtualbox/7.2.16/ and copied that file to /usr/share/virtualbox/VBoxGuestAdditions.iso so it was mountable from the VM and installed that.  
I downloaded GitHub-Copilot-linux-x64.AppImage from https://github.com/github/app/releases , made it executable, started it and managed to login using the authenticator app on my phone.  
In the shared folder on my host I made a read only mount of the root of a Toon 2 so it was possible to read everything on the Toon 2 from within the virtual machine via the mount point of the shared folder. The Toon 2 was mounted read-only, so it could not be modified from the VM....  
In the virtual machine I gave my account sudo access to apt (/etc/sudoers.d/99-jack-nopasswd contains: jack ALL=(ALL:ALL) NOPASSWD: /usr/bin/apt, /usr/bin/apt-get)  
This is where the journey began in the VM.  
I asked GitHub Copilot to have a look in my Toon 2 via the share and build me an sshfs client for Toon 2 and said that it could install all software like cross compilers as needed.  
The result of the build process would be written to the shared folder so I had it available on my physical pc too.  

On the way I found out that it was also handy to have passwordless ssh access to root in my Toon 2 so I implemented that.  
I used "ssh-keygen -t rsa" to generate a keypair (just enter when asked for password) and created ~/.ssh/config on my virtual machine to be able to ssh to my Toons:
```
cat ~/.ssh/config
Host toon*.home 192.168.4.23*
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedAlgorithms +ssh-rsa
    MACs +hmac-sha1,hmac-sha1-96
```
Note that the hostname and ip address parts with the * are placeholders like they could be. You may have to use other values there.

I added the contents of id_rsa.pub to /root/.ssh/authorized_keys on my Toon 2 and did an initial ssh from the command line to my Toon 2 to get the Toon 2 in my ~/.ssh/known_hosts  

After this I instructed Github Copilot that it was allowed to use ssh to access my Toon 2 but not to change anything and it did not change anything but found interesting details it needed.  
So Github Copilot investigated in the Toon 2, installed software in my VM, built software for sshfs and came up with a version which looked good, I copied the result to my Toon 2, tested and had issues, of course.  
I gave the errors to GitHub Copilot and it investigated some more and made changes and I tested.  
This happened a number of times.  
It kept changing the software until it created a working version based on a very old version 0.1 of sshfs.  
Hence the name sshfs-0.1 of the executable.  
This worked fine but every write of any tool to the sshfs mounted filesystem of my Raspberry Pi gave an error although the file was written just fine.  
I gave the error to GitHub Copilot which found and solved a bug in the old version.  
After this I made some changes to sshfs-mount.sh to make it easier to use and wrote all documentation in it.  
The tool worked just fine and it was time to ask to make a build for Toon 1.  
I set up the passwordless ssh access to Toon 1 and asked GitHub Copilot to make the software for Toon 1 and install any software in the VM it needed.  
GitHub Copilot looked into the Toon 1 and came to the conclusion that it was not possible because the kernel lacks basic fuse support.  
This is why I have no build for Toon 1.  

Thanks for reading.
