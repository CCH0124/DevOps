# Swarm

- 分散式設計
- 宣告式服務
- 容器規模縮放機制
- 預期狀態調節
- 自動探索服務機制


![](https://www.netadmin.com.tw/upload/news/NP180530000518053015183303.jpg)

使用 Raft Consensus Algorithm 機制管理集群。只能在 Manager 上座資源調度，而 Worker 只是運行容器。

## 環境
- mars
- node1.cch
- node2.cch
## 建立 Swarm

在 Master 上執行
```shell=
sudo docker swarm init --advertise-addr 192.168.134.149 # master
```
在 master 執行上述指令，並且會給予一個給 worker 加入的 token。把這指令執行至 worker 後即可變成一個 cluster。


加入後如下
```shell=
$ sudo docker node ls
ID                            HOSTNAME    STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
uw26ck3087c863quw2p2bsvq8 *   mars        Ready     Active         Leader           20.10.2
qi92st4f63rob4dpr0ee4ciky     node1.cch   Ready     Active                          20.10.2
qaqzei8k28ed94roucfy6540u     node2.cch   Ready     Active                          20.10.2
```

## Deploy Service

- --mode global
    - 每個節點都佈署
- --name
    - 名稱
- --replicas
    - 期望容器數量
- --publish
    - port 映射
```shell=
$ sudo docker service create --name nginx --replicas=2  --publish 80:80 nginx:1.17
$ sudo docker service ps nginx
ID             NAME      IMAGE        NODE        DESIRED STATE   CURRENT STATE            ERROR     PORTS
ok8indmr3zm9   nginx.1   nginx:1.17   node1.cch   Running         Running 18 seconds ago
xke8rvl81meh   nginx.2   nginx:1.17   node2.cch   Running         Running 18 seconds ago
```
在佈署時，會在目標節點上下載 Image 與啟動容器。佈署完成時，每個節點都能存取到佈署的服務。預設網路是 ingress

```shell=
...
ic2uz7y3zlag   ingress           overlay   swarm
...
```

##### 查看佈署的服務
```shell=
cch@mars:~$ sudo docker service ls
ID             NAME      MODE         REPLICAS   IMAGE        PORTS
j432dk9npe2x   nginx     replicated   2/2        nginx:1.17   *:80->80/tcp
cch@mars:~$ sudo docker service ps nginx
ID             NAME      IMAGE        NODE        DESIRED STATE   CURRENT STATE                ERROR     PORTS
8zxkvas7qk7u   nginx.1   nginx:1.17   node1.cch   Running         Running about a minute ago
vbdfvc8yxfcf   nginx.2   nginx:1.17   node2.cch   Running         Running about a minute ago
```
補驗算法

## Create Network

-  --attachable 
    - 旗標，表示除了 swarm 服務外，單獨容器 (standalone container) 亦可連接至該網路。
-  --opt encrypted
    - 應用層數據加密
    - 在 vxlan 上啟用 IPSEC 加密 

```shell=
cch@mars:~$ docker network create --driver overlay services
cch@mars:~$ docker network ls
NETWORK ID     NAME              DRIVER    SCOPE
...
uforr5bwtovv   services          overlay   swarm
```

## 嘗試佈署服務

```yaml=
version: '3.3'
services:
  postgresMaster:
    image: postgres-master
    ports:
      - "5432:5432"
      - "2222:22"
    hostname: postgres-master
    env_file:
      - .psql-master.env
    networks:
      - services
    volumes:
      - ./init-db.sh:/docker-entrypoint-initdb.d/init-db.sh
      - pg-data:/var/lib/postgresql/data
    healthcheck:
        test: ["CMD-SHELL", "pg_isready -U postgres"]
        interval: 30s
        timeout: 10s
        retries: 5
    deploy: # 這個 Key 主要是宣告交給 Swarm 運行的期望配置
      replicas: 1 # 副本數
      restart_policy: # 重啟策略
        condition: on-failure
      placement: # 選擇性佈署至某個節點上
        constraints: [node.labels.storage == true]

  userManager:
    image: IMAGE
    hostname: user-manager
    env_file:
      - .user-manager.env
    ports:
      - "3000:8080"
    depends_on:
      - postgresMaster
    networks:
      - services
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
volumes:
  pg-data:

networks: # 網路設置的宣告
  services:
    external:
      name: services
```

>在 docker swarm 下如果重啟以佈署的容器，它會自動新增一個新容器
>有一些 `container_name` 或是環境配置會和一般 docker-compose 方式不同

##### 打標籤
```shell=
$ docker node update --label-add storage=true mars
$ docker node inspect mars --format "{{.Spec.Labels}}"
map[storage:true]
```
`--label-rm` 是移除標籤

## Rollout and Rollback In Docker Swarm

```shell=
$ docker service create \ 
--name vote \
--replicas 4 \
--publish 5000:80 \
instavote/vote 
```

##### Rolling update
更新服務
```shell=
 docker service update --image instavote/vote:indent --update-parallelism 2  --update-delay 10s  vote
```

- --update-parallelis
    - 要同時更新的任務數。
- --update-delay
    - 更新下一批任務之前需要等待的時間。

##### Rollback
```shell=
docker service rollback vote
```
下面兩個參數是可設定，同理 Rolling update
- --rollback-parallelism
- --rollback-delay
