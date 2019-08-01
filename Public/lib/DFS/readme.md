# SYNOPSIS

Deploys a file server to use as a DFS namespace host and shared storage for stuff like diskImages and logs (not customer data). Originally this was designed as a two node scale out file server, but it turns out that SOFS is not very performant for use as a general SMB share, it does better when it's hosting large files like VHDs.

We use a single file server because:
* For the types of files we want to store here we don't need 100% uptime, so the single VM SLA from Azure is good enough. Application data and configuration are stored elsewhere.
* A single server is much cheaper, and performance scales linearly -- the disk I/O is usually capped by the VM SKU, so if we need more disk performance we just increase the file server SKU.
* We don't need very high performance for these types of files.
