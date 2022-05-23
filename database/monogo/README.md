## Backup and Restore

Backup

```bash
docker exec -i mongo_router sh -c 'mongodump -h 127.0.0.1 --authenticationDatabase admin -u <user> -p <password> --db <database> --archive' > db.dump
```

Restore

```bash
 docker exec -i aiot_mongo_router_dev sh -c 'mongorestore -h 127.0.0.1 --authenticationDatabase admin -u <user> -p <password> --db <database> --archive' < db.dump
```
