要運行非 root 容器必須要 kernel 支援 cgroups v2。在 podman 底層的 OCI 也須支援 cgroups v2。 在非 root 執行容器 `/etc/subuid` 和 `/etc/subgid` 也是其中一個關鍵，從下面的值可以說可創建 65536 使用者，UID 從 100000 開始，但盡可能不與主機重疊

```bash=
$ cat /etc/subuid
vagrant:100000:65536
```

非 root 容器的運行權限相對會比外部使用者更小，對於網路設備需要使用第三方套件實現，對於 Port 的映射必須大於 1024，小於 1024 都是最高權限的。

- 使用非 root 容器，容器 image 儲存在家目錄 ($HOME/.local/share/containers/storage/) 下，而不是 `/var/lib/containers`
- 使用非 root 容器的用戶在系統上作為一系列 user 和 group ID 運行的特殊權限，否則對系統沒有 root 權限

## Run Nginx


```bash=
$ podman run -dt -p 8080:80 --name nginx nginx:latest
$ podman ps -a
CONTAINER ID  IMAGE                           COMMAND               CREATED        STATUS            PORTS                 NAMES
b45417dc08b9  docker.io/library/nginx:latest  nginx -g daemon o...  7 seconds ago  Up 7 seconds ago  0.0.0.0:8080->80/tcp  nginx
$ podman inspect nginx # 檢視該容器的訊息
```

```bash=
$ podman port -a 
b45417dc08b9    80/tcp -> 0.0.0.0:8080
```

```bash=
$ podman start nginx
$ podman stop nginx
$ podman restart nginx
```

## Remote Container

```bash=
$ podman exec -it nginx /bin/bash
```

## Log

```bash=
$ podman logs nginx
```


## Resource

```bash=
$ podman top nginx
USER    PID   PPID   %CPU    ELAPSED            TTY     TIME   COMMAND
root    1     0      0.000   22m43.282450439s   pts/0   0s     nginx: master process nginx -g daemon off;
nginx   26    1      0.000   22m43.283496235s   pts/0   0s     nginx: worker process
nginx   27    1      0.000   22m43.284438811s   pts/0   0s     nginx: worker process
```

```bash=
$ podman stats nginx
Error: stats is not supported in rootless mode without cgroups v2
```

解決方式可參考此[資源](https://github.com/containers/podman/issues/4049)。這邊附上關於 `cgroups v2` 的優勢[資源](https://medium.com/nttlabs/cgroup-v2-596d035be4d7)。

解決方式如下

- edit `/etc/default/grub`
- add `systemd.unified_cgroup_hierarchy=1` to the key `GRUB_CMDLINE_LINUX_DEFAULT` (space separated list)
- run `sudo grub-mkconfig -o /boot/grub/grub.cfg` and reboot.

```bash=
$ stat -c %T -f /sys/fs/cgroup
cgroup2fs # 原先是 tmpfs
```

如果使用 `ls /sys/fs/cgroup` 檢查，若 cgroup 為前綴表示正在運行 cgroups v2。

在運行一次

```bash=
$ podman stats nginx
ID            NAME    CPU %   MEM USAGE / LIMIT  MEM %   NET IO   BLOCK IO  PIDS
b45417dc08b9  nginx   0.00%   75.19MB / 2.084GB  3.61%   -- / --  -- / --   25
ID            NAME    CPU %   MEM USAGE / LIMIT  MEM %   NET IO   BLOCK IO  PIDS
b45417dc08b9  nginx   0.00%   75.19MB / 2.084GB  3.61%   -- / --  -- / --   25
ID            NAME    CPU %   MEM USAGE / LIMIT  MEM %   NET IO   BLOCK IO  PIDS
b45417dc08b9  nginx   0.10%   75.19MB / 2.084GB  3.61%   -- / --  -- / --   25
```


## Backup and Restore
這個指令需要使用 `sudo`

```bash=
$ sudo podman container ${CONTAINER_NAME} checkpoint  -e /tmp/checkpoint.tar.gz
$ sudo podman container restore -i /tmp/checkpoint.tar.gz
```

:::warning
如果不是用 `sudo` 建立容器，則此指令無法對該容器使用，待驗證。
:::


## Pod
Pod 是由多個運行在一起的容器組成。

使用 Kubernetes 的 yml 格式
```yaml=
# pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
  labels:
    name: my-app
spec:
  containers:
  - name: nginx1
    image: nginx
    ports:
      - containerPort: 8001
        hostPort: 8001
        protocol: TCP
  - name: nginx2
    image: nginx
    ports:
      - containerPort: 8002
        hostPort: 8002
        protocol: TCP
    volumeMounts:
      - name: html1-volume
        mountPath: /opt/html
      - name: config1-volume
        mountPath: /etc/nginx/conf.d
  volumes:
    - name: html1-volume
      hostPath:
        path: /opt/myapp/html2
        type: Directory
    - name: config1-volume
      hostPath:
        path: /opt/myapp/config2
        type: Directory
```


```bash=
$ sudo podman play kube pod.yml # kube  Play a pod based on Kubernetes YAML.
Pod:
f34d0ace89e739f91734078dc920d01d3aa41240a370decf484887fde21775c5
Containers:
b9e32f350307f5293676b86401492d8865564d385d0053d0234cb67ca359ef35
3ce7e057b0a9446abae3d3210098523c547b8fc97962fc7796f26febee3f74bb
```

該 POD 中與 Kubernetes 中的 Pod 都有 `pause` 概念，用來共享資源
```bash=
$ sudo podman ps -a
CONTAINER ID  IMAGE                           COMMAND               CREATED             STATUS                 PORTS                             NAMES
549e197cfa3f  docker.io/library/nginx:latest  nginx -g daemon o...  2 hours ago         Up 2 hours ago         0.0.0.0:80->80/tcp                nginx
28da6e4b8ed6  k8s.gcr.io/pause:3.5                                  About a minute ago  Up About a minute ago  0.0.0.0:8001-8002->8001-8002/tcp  f34d0ace89e7-infra
b9e32f350307  docker.io/library/nginx:latest  nginx -g daemon o...  About a minute ago  Up About a minute ago  0.0.0.0:8001-8002->8001-8002/tcp  my-app-nginx1
3ce7e057b0a9  docker.io/library/nginx:latest  nginx -g daemon o...  About a minute ago  Up About a minute ago  0.0.0.0:8001-8002->8001-8002/tcp  my-app-nginx2
```

該 pod 的資訊
```bash=
$ sudo podman pod ls
POD ID        NAME    STATUS   CREATED        INFRA ID      # OF CONTAINERS
f34d0ace89e7  my-app  Running  4 minutes ago  28da6e4b8ed6  3
```

觀察該 POD 容器狀態
```bash=
$ sudo podman pod stats
POD           CID           NAME                CPU %  MEM USAGE/ LIMIT   MEM %  NET IO          BLOCK IO           PIDS
f34d0ace89e7  28da6e4b8ed6  f34d0ace89e7-infra  4.21%  241.7kB / 2.084GB  0.01%  978B / 1.424kB  -- / --            1
f34d0ace89e7  3ce7e057b0a9  my-app-nginx2       4.91%  3.187MB / 2.084GB  0.15%  978B / 1.424kB  8.192kB / 8.192kB  3
f34d0ace89e7  b9e32f350307  my-app-nginx1       8.41%  3.289MB / 2.084GB  0.16%  978B / 1.424kB  0B / 24.58kB       3
```

基本的操作，停止、啟動服務等
```bash=
$ sudo podman pod stop my-app
$ sudo podman pod start my-app
$ sudo podman pod rm my-app
$ sudo podman pod inspect my-app  # 查看 POD 的完整資訊
```

以下是以非 root 容器執行
```bash=
$ podman pod create --name blog -p 8443:8443 # 建立 POD
$ podman run --pod blog --name web --rm -d nginx # POD 中建立 nginx 服務
$ podman run --pod blog --name side-card --rm -d busybox /bin/sh -c "while true;do date;sleep 1;done"
```


```bash=
$ podman exec -it 2e13651d4ad /bin/sh # 遠端至 side-card
/ # id -u
0 # 映射外部主機使用者
```

如果容器從外部掛載卷至內部，會發現可能會沒有權限進行讀寫，因此要將卷目錄 `chown` 給容器的映射用戶，而這透過 `podman unshare` 實現。



更詳細的內容可以參考此[鏈結](https://mbien.dev/blog/entry/java-in-rootless-containers-with)

## Networking

下面是預設提供的網路模式

```bash=
$ sudo podman network ls
NETWORK ID    NAME    VERSION  PLUGINS
2f259bab93aa  podman  0.4.0    bridge,portmap,firewall,tuning # 預設提供
```

podman 的網路配置預設會在 `/etc/cni/net.d/87-podman-bridge.conflist`

