使用 docker-compose 建置

```yaml
version: '3.7'
services:
  postgres:
    container_name: postgres
    image: postgres
    restart: always
    ports:
      - "5432:5432"
    hostname: postgres
    environment:
      - POSTGRES_PASSWORD=123456
    volumes:
      - ./psql/init.sql:/docker-entrypoint-initdb.d/init.sql # 如果有要初始劃一些資料庫東西
      - pv_postgresql:/var/lib/postgresql/data
    healthcheck:
        test: ["CMD-SHELL", "pg_isready -U postgres"]
        interval: 30s
        timeout: 10s
        retries: 5
volumes:
  pv_postgresql:
```

預設帳好是 `postgres`
```bash
$ docker exec -it postgres_test /bin/bash
root@postgres:/# psql -U postgres -h localhost -p 5432
psql (14.1 (Debian 14.1-1.pgdg110+1))
Type "help" for help.

postgres=#
```
## 連線管理
- TCP
使用 `psql` 指令
- socket

## PG 防火牆
`pg_hba.conf` 是 pg 的防火牆實例。其分為以下部分
- TYPE  
- DATABASE        
- USER            
- ADDRESS                 
- METHOD


```bash
root@postgres:/# cat /var/lib/postgresql/data/pg_hba.conf
...
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            trust
host    replication     all             ::1/128                 trust

host all all all scram-sha-256
```

## 使用者管理
### 建立使用者
關鍵字使用 `CREATE USER`，用 `du` 來顯示使用者列表；或是 `pg_catalog.pg_user` 來查看資訊

```sql
CREATE USER test WITH PASSWORD '123456';

postgres=# \du+
                                          List of roles
 Role name |                         Attributes                         | Member of | Description 
-----------+------------------------------------------------------------+-----------+-------------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}        |
 test      |                                                            | {}        |

postgres=# SELECT * FROM pg_catalog.pg_user;
 usename  | usesysid | usecreatedb | usesuper | userepl | usebypassrls |  passwd  | valuntil | useconfig
----------+----------+-------------+----------+---------+--------------+----------+----------+-----------
 postgres |       10 | t           | t        | t       | t            | ******** |          |
 test     |    16384 | f           | f        | f       | f            | ******** |          |
(2 rows)
```

授予一些權限
```sql
# CREATE USER itachi WITH ENCRYPTED PASSWORD '123456' CREATEDB CREATEROLE;
CREATE ROLE
postgres=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 itachi    | Create role, Create DB                                     | {}
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 test      |                                                            | {}
```

以 test 使用者來看是無法建立 ddatabase 的；但 itachi 有授予權限因此能夠建立。
```sql
# psql -U test -h localhost -p 5432 -d postgres
postgres=>create database test
postgres-> ;
ERROR:  permission denied to create database
# psql -U itachi -h localhost -p 5432 -d postgres
postgres=> CREATE DATABASE itachi;
CREATE DATABASE
```
### 測試使用者連線
透過 `create database` 建立資料庫，再用 `CREATE TABLE` 建立一張 accounts 表，建立完後使用 test 使用者連線。爾後發現該 test 使用者沒有權限操做 `mydb` 表
```sql
postgres=# create database mydb;
CREATE DATABASE
postgres=# \c mydb 
You are now connected to database "mydb" as user "postgres".
mydb=# CREATE TABLE accounts (
        user_id serial PRIMARY KEY,
        username VARCHAR ( 50 ) UNIQUE NOT NULL,
        password VARCHAR ( 50 ) NOT NULL,
        email VARCHAR ( 255 ) UNIQUE NOT NULL,
        created_on TIMESTAMP NOT NULL,
        last_login TIMESTAMP 
);
CREATE TABLE
# psql -U test -h localhost -p 5432 -d mydb
psql (14.1 (Debian 14.1-1.pgdg110+1))
Type "help" for help.

mydb=>
mydb=> select * from accounts;
ERROR:  permission denied for table accounts
```

對 `mydb` 進行授權，切換 `postgres` 最高權限。

```sql
postgres=# GRANT ALL PRIVILEGES ON DATABASE mydb TO test; --ON 表示針對哪個 Table；TO 表示要指定哪個 role 或 user 擁有此 privilege--
GRANT
mydb=# GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO test; --針對 Database 中的 Table 賦予權限--
GRANT
# psql -U test -h localhost -p 5432 -d mydb
mydb=> select * from accounts;
 user_id | username | password | email | created_on | last_login 
---------+----------+----------+-------+------------+------------
(0 rows)
```


>PRIVILEGES 包含 SELECT, INSERT, UPDATE, DELETE, TRUNCATE 等或直接使用 ALL 來賦予所有 privilege
>其它可能地 privileges 還有 REFERENCES、TRIGGER、CREATE、CONNECT、TEMPORARY、EXECUTE、USAGE

### 移除帳號的權限
```sql
postgres=# REVOKE ALL PRIVILEGES ON DATABASE mydb FROM test;
REVOKE
postgres=# \c mydb
You are now connected to database "mydb" as user "postgres".
mydb=# REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM test;
REVOKE
mydb=> select * from accounts;
ERROR:  permission denied for table accounts
```

### 刪除使用者

```sql
# DROP USER test;
```

## 角色管理
`CREATE ROLE` 預設不帶 LOGIN 屬性。基本上和建立使用者是一樣的。使用 `select * from pg_roles` 會發現系統有很多角色。

```sql
postgres=# CREATE ROLE role_test;
postgres=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 itachi    | Create role, Create DB                                     | {}
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 role_test | Cannot login                                               | {}
 test      |                                                            | {}
```

角色屬性
|屬性|說明|
|---|---|
|LOGIN|可用來與資料庫做連接|
|SUPERUSER||
|CREATEDB|建立資料庫的權限|
|CREATEROLE|允許其建立或刪除其它一般使用者的使用角色|
|REPLICATION|做複制的時候用到的一個使用者屬性|
|PASSWORD|登入時要求指定密碼時才會起作用，像是 MD5、PASSWORD 等模式|
|INHERIT|用戶組隊組員一個繼層標示，可用來繼層權限|

賦予建立 DB 的權限

```sql
postgres=# ALTER ROLE role_test WITH CREATEDB LOGIN;
ALTER ROLE
postgres=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 itachi    | Create role, Create DB                                     | {}
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 role_test | Create DB                                                  | {}
 test      |                                                            | {}
```

## 權限管理
- cluster
    - pg_hba 配置
- database
    - 資料庫權限透過 GRANT 和 REVOKE 操作 schema 配置
- TBS
    - 表空間權限透過 GRANT 和 REVOKE 操作表、視圖、索引、臨時表配置
- schema
    - 模式權限透過 GRANT 和 REVOKE 操作模式下的對象配置
- object
    - 物件權限透過 GRANT 和 REVOKE 配置

### database 權限設置
```sql
GRANT CREATE ON DATABASE [DATABASE_NAME] TO [USER];
```

### schema 權限設置
schema 是一個 namespace，其包含 tables、views、indexes、data types、functions、stored procedures 和 operators 等物件。
```sql
ALTER SCHEMA abc OWNER TO [USER]; 
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA test TO [USER];
```
也可使用 `CREATE SCHEMA IF NOT EXISTS itachi;`

回傳當前的 schema
```sql
SELECT current_schema();
```

下面表示對某一個表進行搜索時會查詢的 namespace，下面表示會查詢 `public` 下資源，如果有多個會繼續搜索。要新增的話可使用 `SET search_path TO [SCHEMA]`。
```sql
cch=> SHOW search_path;
   search_path   
-----------------
 "$user", public
(1 row)
cch=> SET search_path TO itachi, public;
SET
```

下面是刪除 schema 方式
```sql
DROP SCHEMA IF EXISTS [SCHEMA_NAME];
```

### object 權限設置
```sql
GRANT SELECT,INSERT,UPDATE,DELETE ON [SCHEMA.TABLE] TO [USER]; --哪個 Schema 下的表給使用者--
```

### 範例
```sql
postgres=# CREATE DATABASE cch;
CREATE DATABASE
postgres=# \c cch
You are now connected to database "cch" as user "postgres".
cch=#
cch=# CREATE SCHEMA itachi;
cch=# CREATE USER madara WITH PASSWORD '123456';
CREATE ROLE
cch=# ALTER SCHEMA itachi OWNER TO madara;
ALTER SCHEMA
cch=# GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA itachi TO madara;
GRANT
```

```sql
SELECT * FROM pg_catalog.pg_namespace;
  oid  |      nspname       | nspowner |               nspacl
-------+--------------------+----------+-------------------------------------
    99 | pg_toast           |       10 |
    11 | pg_catalog         |       10 | {postgres=UC/postgres,=U/postgres}
  2200 | public             |       10 | {postgres=UC/postgres,=UC/postgres}
 13391 | information_schema |       10 | {postgres=UC/postgres,=U/postgres}
 16402 | itachi             |    16403 |
(5 rows)
```

>schema 默認是存在 public 上


在該 schema 建立一張 table

```sql
# psql -U madara -d cch
cch=> CREATE TABLE itachi.roles(
   role_id serial PRIMARY KEY,
   role_name VARCHAR (255) UNIQUE NOT NULL
);
CREATE TABLE
```

存取方式變成是 `schema_name.object_name` 當如果將 `itachi` 設定到 `search_path` 中時就可以不用指定 schema 前綴。

```sql
cch=> select * from roles;
ERROR:  relation "roles" does not exist
LINE 1: select * from roles;
                      ^
cch=> select * from itachi.roles;
 role_id | role_name 
---------+-----------
(0 rows)
```
當使用 `SET search_path TO itachi, public` 設定後即可讓系統自動搜尋到。除非有指定要哪個 schema 那就要前綴。
```sql
cch=> select * from roles;
 role_id | role_name 
---------+-----------
(0 rows)
```

## 性能校條
待補...
- [pgtune](https://pgtune.leopard.in.ua/#/)