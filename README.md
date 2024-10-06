# scripts

## NVME Prep Script (nvme_prep.sh)
This script is what I use to prep my NVME drives. It will:
1. Wipe any partitions
2. Format the drive in ext4
3. Remove any reserve space
4. Create a mount point
5. Add a fstab entry
6. Mount the drives

## Message of the Day
A simple MOTD that can be added to Debian

```bash
sudo nano /etc/update-motd.d/00-custom-welcome
```

Then paste in the script and save.

Looks like:
```
=============================================
            System Information
=============================================
LAN IP Address: 192.168.69.111
Uptime:         up 9 minutes
CPU Model(s):   Cortex-A55,Cortex-A76
Total Cores:    8
Total RAM:      15GB
Disk Usage:     1G used of 56G
=============================================
```
