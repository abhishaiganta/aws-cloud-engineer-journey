# Week 4: Storage Decision Guide

| Service | What it is | Use this when... |
|---|---|---|
| S3 | Object storage | you need cheap, durable storage for files like backups, logs, datasets or website assets. |
| EBS | Block storage (a disk for one server) | a single EC2 instance needs its own disk, like a boot drive or database files. |
| EFS | Shared file system | several servers or containers need to read and write the same files at the same time. |
| RDS | Managed SQL database | you need tables, joins and transactions without managing the database server yourself. |
| DynamoDB | Serverless NoSQL (key-value) | you need very fast lookups by key at any scale with almost no setup or servers. |
