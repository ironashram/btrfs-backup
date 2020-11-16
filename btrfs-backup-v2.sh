#!/bin/sh
btrfs subvolume snapshot -r / /rootfs-backup_new
sync
btrfs subvolume snapshot -r /home /home/home-backup_new
sync
btrfs send -p /rootfs-backup /rootfs-backup_new |  btrfs receive /backup/rootfs/
btrfs send -p /home/home-backup /home/home-backup_new |  btrfs receive /backup/home/

btrfs subvolume snapshot -r /backup/rootfs/rootfs-backup /backup/rootfs/rootfs-backup.$(date +%d-%m-%Y)
btrfs subvolume snapshot -r /backup/home/home-backup /backup/home/home-backup.$(date +%d-%m-%Y)

btrfs subvolume delete /rootfs-backup
mv /rootfs-backup_new /rootfs-backup
btrfs subvolume delete /backup/rootfs/rootfs-backup
mv /backup/rootfs/rootfs-backup_new /backup/rootfs/rootfs-backup

btrfs subvolume delete /home/home-backup
mv /home/home-backup_new /home/home-backup
btrfs subvolume delete /backup/home/home-backup
mv /backup/home/home-backup_new /backup/home/home-backup

find /backup/home/* -maxdepth 0 -mtime +7 -name "home-backup.*" | xargs sudo btrfs subvolume delete
find /backup/rootfs/* -maxdepth 0 -mtime +7 -name "rootfs-backup.*" | xargs sudo btrfs subvolume delete 
