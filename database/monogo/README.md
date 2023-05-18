## Backup and Restore

Backup

```bash
docker exec -i mongo_router sh -c 'mongodump -h 127.0.0.1 --authenticationDatabase admin -u <user> -p <password> --db <database> --archive' > db.dump
```

Restore

```bash
 docker exec -i mongo_router sh -c 'mongorestore -h 127.0.0.1 --authenticationDatabase admin -u <user> -p <password> --db <database> --archive' < db.dump
```

## Query and Delete

```bash
docker exec -it mongo_router /bin/bash
root@33f3344890ed:/# mongo
MongoDB shell version v4.0.22
...
mongos> show dbs # 存在的 DB
admin   0.000GB
aiot    0.116GB
config  0.001GB
mongos> use aiot # 使用某個 DB
switched to db aiot
mongos> show collections # 該 DB 下的 colleciton
ADASFCWS
ADASLDWS
mongos> db.gnss.find({ timestamp: { $lt: 1652971320000}}) # 搜尋
mongos> db.gnss.deleteMany({ timestamp: { $lt: 1652971320000}}) # 刪除該 collection 下的 Document
{ "acknowledged" : true, "deletedCount" : 90930 }

```
## Add User

登入
```bash
mongosh -u USERNAME -p PWD --authenticationDatabase admin 
```

透過 use 切換 db，在建立使用者
```bash
use shop
db.createUser({ user: "test", pwd: "00000000", roles: [{ role: "readWrite", db: "shop" },{ role: "read", db: "aiot" }]})
```

- [Mongo RBAC](https://www.bmc.com/blogs/mongodb-role-based-access-control/)
