#!/bin/sh

#Create snapshots of root and home
btrfs subvolume snapshot -r / /rootfs-backup_new
sync
btrfs subvolume snapshot -r /home /home/home-backup_new
sync

#Use btrfs send to mirror new backup snapshot to /backup disk
btrfs send -p /rootfs-backup /rootfs-backup_new |  btrfs receive /backup/rootfs/
btrfs send -p /home/home-backup /home/home-backup_new |  btrfs receive /backup/home/

#Use a humanfriendly date to recongise backup timestamp
btrfs subvolume snapshot -r /backup/rootfs/rootfs-backup /backup/rootfs/rootfs-backup.$(date +%d-%m-%Y)
btrfs subvolume snapshot -r /backup/home/home-backup /backup/home/home-backup.$(date +%d-%m-%Y)

#Delete old backup snpashot on root
btrfs subvolume delete /rootfs-backup
mv /rootfs-backup_new /rootfs-backup
btrfs subvolume delete /backup/rootfs/rootfs-backup
mv /backup/rootfs/rootfs-backup_new /backup/rootfs/rootfs-backup

#Delete old backup snapshot on home
btrfs subvolume delete /home/home-backup
mv /home/home-backup_new /home/home-backup
btrfs subvolume delete /backup/home/home-backup
mv /backup/home/home-backup_new /backup/home/home-backup

# Delete snapshots older than 7 days
find /backup/home/* -maxdepth 0 -mtime +7 -name "home-backup.*" | xargs btrfs subvolume delete
find /backup/rootfs/* -maxdepth 0 -mtime +7 -name "rootfs-backup.*" | xargs btrfs subvolume delete 
