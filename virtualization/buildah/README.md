建置 Image 方式可以使用 docker、podman、buildah 等工具。而 podman 是使用 buildah 實現，使用方式基本上和 docker 一致。


```bash
$ podman build -t mybaits-java .
$ $ buildah bud -t buildah-spring .
```

使用 podman 查看 image

```bash
$ podman image ls
REPOSITORY                        TAG                    IMAGE ID      CREATED         SIZE
localhost/mybaits-java            latest                 26c1e41c4eb6  3 minutes ago   174 MB # this
<none>                            <none>                 31d49697d358  4 minutes ago   538 MB
<none>                            <none>                 01bc28fe5229  27 minutes ago  120 MB
docker.io/library/maven           3.8.1-openjdk-11-slim  95b9d0f48ecd  2 weeks ago     444 MB
docker.io/library/nginx           latest                 4f380adfc10f  2 weeks ago     137 MB
docker.io/library/busybox         latest                 69593048aa3a  5 weeks ago     1.46 MB
docker.io/adoptopenjdk/openjdk11  jre-11.0.10_9-alpine   ec93007d8201  2 months ago    151 MB
k8s.gcr.io/pause                  3.5                    ed210e3e4a5b  3 months ago    690 kB
docker.io/library/maven           3.5.2-jdk-8-alpine     293423a981a7  3 years ago     120 MB
```
使用 buildah 查看，會看見結果是一樣


```bash
$ buildah images
REPOSITORY                         TAG                     IMAGE ID       CREATED          SIZE
localhost/mybaits-java             latest                  26c1e41c4eb6   5 minutes ago    174 MB
<none>                             <none>                  31d49697d358   6 minutes ago    538 MB
<none>                             <none>                  01bc28fe5229   29 minutes ago   120 MB
docker.io/library/maven            3.8.1-openjdk-11-slim   95b9d0f48ecd   2 weeks ago      444 MB
docker.io/library/nginx            latest                  4f380adfc10f   2 weeks ago      137 MB
docker.io/library/busybox          latest                  69593048aa3a   5 weeks ago      1.46 MB
docker.io/adoptopenjdk/openjdk11   jre-11.0.10_9-alpine    ec93007d8201   2 months ago     151 MB
k8s.gcr.io/pause                   3.5                     ed210e3e4a5b   3 months ago     690 KB
docker.io/library/maven            3.5.2-jdk-8-alpine      293423a981a7   3 years ago      120 MB
```


buildah 允許從運行中容器、Dockerfile 或從頭開始建立容器 image。該 Image 會符合 OCI 標準，因此只要有符合 OCI 標準的 CRI 都可運行。

buildah 和 docker 建構方式還是存在些許不同，如下
- No Daemon
  - buildah 不須透過 Docker daemon，So no container runtime (Docker, CRI-O, or other) is needed to use Buildah.
- Base image or scratch
  - 可基於另一個容器構建 image，或從 scratch 開始建構（從頭建構）
- Build tools external
  -  不包括 image 本身中的構建工具
  -  減少構建 Image 大小
  -  在生成的 Image 中不包含用於構建容器的軟體（gcc、make、dnf...），使 Image 更安全
  -  創建較少資源的 image
 
buildah 能夠在沒 Docker 或其它框架下運行，方法是單獨儲存數據。在域設下，buildah 將 Image 儲存在 `/var/lib/containers` 中。因此在容器上編輯 Image 時，可以透過指示 `docker-daemon` 儲存在 `/var/lib/docker` 中，將該容器導出為本地 Docker Image。

使用 buildah 建構 Image 時，可以搭配以下方法

- Build a container from a Dockerfile
  -  `buildah bud` 使用 Dockerfile 建構容器 Image
- Build a container from another image or scratch
  -  `buildah from <imagename>` 從現有的基礎 Image 建構新的容器 Image
  -  `buildah from scratch` 從頭建構
-  Inspecting a container or image
  -  `buildah inspect` 查看與容器或 Image 關聯的元數據
-  Mount a container
  - `buildah mount` 掛載容器的 root filesystem 以添加或更改內容
- Create a new container layer
  - `buildah commit` 使用容器 root filesystem 的更新內容作為文件系統層將內容提交到新 Image
- Unmount a container
  - `buildah umount` 卸載已掛載的容器
- Delete a container or an image
  - `buildah rm` 移除容器
  - `buildah rmi` 移除容器 Image

整體來說，在 Docker 基本功能 buildah 都可以輕鬆使用。
