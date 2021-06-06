`Docker` 是一個用於開發、發布和運行應用程式的開放平台。使用 `Docker`，可以將應用程式與基礎架構分離，並將基礎架構視為託管應用程序。Docker 更快的交付代碼、更快的測試、更快的部署，並縮短編寫代碼和運行代碼之間的周期。`Docker` 透過將內核容器化功能與可幫助管理和部署應用程序的工作流和工具相結合來做到這一點。`Docker` 容器可直接在 `Kubernetes` 中使用，這使得它們可以輕鬆在 `Kubernetes Engine` 中運行。

## Hello World

打開 `Cloud Shell` 運行一個容器

```shell
docker run hello-world
```
輸出

```shell
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
9db2ca6ccae0: Pull complete
Digest: sha256:90659bf80b44ce6be8234e6ff90a1ac34acbeb826903b02cfa0da11c82cbc042
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

`docker daemon` 搜索了 `hello-world` 鏡像，但未在本地找到該鏡像，而是從 `Docker Hub` 的提取了該鏡像，並從該鏡像創建了一個容器，最後運行了該容器​​。



查看從 `Docker Hub` 拉出的容器鏡像
```shell
docker images
```

輸出
```shell
 docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              bf756fb1ae65        8 months ago        13.3kB
```

`IMAGE ID` 為 `SHA256` 哈希格式，該字段指定已配置的 `Docker` 鏡像。當 `docker daemon` 無法在本地找到鏡像時，默認情況下它將在 `Docker Hub` 中搜索該映像。


查看正在運行的容器
```shell
docker ps
```

輸出

```shell
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

表示沒有運行的容器。

為了查看所有容器，包括已完成執行的容器，使用 `-a` 選項。

```shell
docker ps -a
```

輸出

```shell
CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS                          PORTS               NAMES
7be6e4b8cb55        hello-world         "/hello"            About a minute ago   Exited (0) About a minute ago                       xenodochial_keldysh
student_03_0d34e1a500e3@cloudshell:~$
```

顯示 `Container ID`，由 `Docker` 生成以識別容器的 `UUID` 以及有關運行的更多資訊。容器 `NAMES` 也是隨機生成的，可以使用 `docker run --name [container-name] hello-world` 指定。


## Build
構建一個基於簡單節點應用程序的 `Docker` 鏡像。

```shell
mkdir test && cd test
```

建立 `Dockerfile`

```shell
cat > Dockerfile <<EOF
# Use an official Node runtime as the parent image
FROM node:6

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Make the container's port 80 available to the outside world
EXPOSE 80

# Run app.js using node when the container launches
CMD ["node", "app.js"]
EOF
```

此 `Dockerfile` 指導 `Docker daemon`如何構建鏡像。

- 初始指定基本父鏡像，它是 node 版本是 6 的 `Docker` 鏡像
- 在 `WORKDIR` 中，我們設置容器的工作目錄
- 在 `ADD` 中，將當前目錄的內容添加到容器中
- `EXPOSE` 暴露容器的端口，以便可以接受該端口上的連接，最後用 `CMD` 運行 node 以啟動應用程序

這是 [Dockerfile 相關配置內容](https://docs.docker.com/engine/reference/builder/#known-issues-run)

這邊在編寫 node 應用程序，然後構建鏡像。

```shell
cat > app.js <<EOF
const http = require('http');

const hostname = '0.0.0.0';
const port = 80;

const server = http.createServer((req, res) => {
    res.statusCode = 200;
      res.setHeader('Content-Type', 'text/plain');
        res.end('Hello World\n');
});

server.listen(port, hostname, () => {
    console.log('Server running at http://%s:%s/', hostname, port);
});

process.on('SIGINT', function() {
    console.log('Caught interrupt signal and will exit');
    process.exit();
});
EOF
```

是一個簡單的 `HTTP`，它監聽端口 80 並返回 `Hello World`，接著建構鏡像

```shell
docker build -t node-app:0.1 . # . 表示當前目錄
```

輸出內容會類似以下
```shell
Sending build context to Docker daemon 3.072 kB
Step 1 : FROM node:6
6: Pulling from library/node
...
...
...
Step 5/5 : CMD ["node", "app.js"]
 ---> Running in 42f2e5c666a5
Removing intermediate container 42f2e5c666a5
 ---> 646fb78d27c1
Successfully built 646fb78d27c1
Successfully tagged node-app:0.1
```

`-t` 使用 `name:tag` 語法命名和將鏡像給標籤。鏡像的名稱是 `node-app`，標籤是 `0.1`。如果未指定標籤，則標籤將默認為 `latest` 標籤，並且很難區分較新的鏡像和較舊的鏡像。

查看鏡像是否建立

```shell
docker images
```
輸出
```shell
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
node-app            0.1                 646fb78d27c1        59 seconds ago      884MB
hello-world         latest              bf756fb1ae65        8 months ago        13.3kB
node                6                   ab290b853066        16 months ago       884MB
```

`node` 是基礎鏡像，`node-app` 是我們構建的鏡像，須先刪除 `node-app` 才能刪除 `node`。與 `VM` 相比，鏡像的大小相對較小，`node` 鏡像的其他版本，如 `node:slim` 和 `node:alpine`，可以為供更小的鏡像，以便於移植。


## Run

運行建構的鏡像
```shell
docker run -p 4000:80 --name my-app node-app:0.1
```
輸出
```shell
Server running at http://0.0.0.0:80/
```

`--name` 將容器給予一個名稱，`-p` 指示 `Docker` 將主機端口 `4000` 映射到容器端口 `80`，可以透過 `http://localhost:4000` 訪問服務。沒有端口映射，將無法訪問本地主機上的容器。

```shell
curl http://localhost:4000
Hello World
```

將容器指定到後台運行，使用 `-d` 選項。運行以下以停止和刪除容器

```shell
docker stop my-app && docker rm my-app
```

增加 `-d`

```shell
docker run -p 4000:80 --name my-app -d node-app:0.1

docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                  NAMES
be0f5d5d4a8f        node-app:0.1        "node app.js"       8 seconds ago       Up 7 seconds        0.0.0.0:4000->80/tcp   my-app
```

同時也可以用 `docker logs [container_id]` 查看該容器的 `log`。


這邊再次跟改 `node` 的 `HTTP` 檔案

```shell
....
const server = http.createServer((req, res) => {
    res.statusCode = 200;
      res.setHeader('Content-Type', 'text/plain');
        res.end('Welcome to Cloud\n');
});
....
```

重新建立鏡像
```shell
docker build -t node-app:0.2 .

Sending build context to Docker daemon  3.072kB
Step 1/5 : FROM node:6
 ---> ab290b853066
Step 2/5 : WORKDIR /app
 ---> Using cache
 ---> 15093919793f
Step 3/5 : ADD . /app
 ---> a5337a49fd80
Step 4/5 : EXPOSE 80
 ---> Running in 5a796229f593
Removing intermediate container 5a796229f593
 ---> 39a62b4cc76c
Step 5/5 : CMD ["node", "app.js"]
 ---> Running in 1ac793421906
Removing intermediate container 1ac793421906
 ---> 006da30f7a93
Successfully built 006da30f7a93
Successfully tagged node-app:0.2
```

將鏡像運行，並應設 `8080` 至本機，因為 4000 已經被上一版使用，否則會有 `Port` 衝突。

```shell
docker run -p 8080:80 --name my-app-2 -d node-app:0.2
docker ps
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS              PORTS                  NAMES
43d57a8ea43e        node-app:0.2        "node app.js"       5 seconds ago        Up 4 seconds        0.0.0.0:8080->80/tcp   my-app-2
be0f5d5d4a8f        node-app:0.1        "node app.js"       About a minute ago   Up About a minute   0.0.0.0:4000->80/tcp   my-app
```

請求網頁
```shell
curl http://localhost:8080
Welcome to Cloud
curl http://localhost:4000
Hello World
```


## Debug
使用 `docker logs [container_id]` 查看容器的 `log`。要在容器運行時追蹤日誌的輸出，可使用 `-f` 選項。
```shell
docker logs -f [container_id]
```


有時會想要在正在運行的容器中啟動交互式 `Bash`。可以使用 `docker exec` 執行此操作。

```shell
docker exec -it [container_id] bash
```

`-it` 可以透過分配偽 `tty` 並保持 `stdin` 打開來與容器進行交互。注意 `bash` 在 `Dockerfile` 中指定的 `WORKDIR`目錄 `/app` 中運行。在這裡，可以在容器內進行交互式 `shell`。離開 `bash` 交互輸入 `exit`。

```shell
$ docker exec -it be0f5d5d4a8f  bash
root@be0f5d5d4a8f:/app#
Dockerfile  app.js
root@be0f5d5d4a8f:/app# exit
```

還可以使用 `docker inspect` 在 `Docker` 中檢查容器的元數據：
```shell
docker inspect [container_id]
[
    {
        "Id": "xxxxxxxxxxxx....",
        "Created": "2017-08-07T22:57:49.261726726Z",
        "Path": "node",
        "Args": [
            "app.js"
        ],
...
```

使用 `--format` 檢查返回的 `JSON` 中的特定字段

```shell
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' [container_id]
```

```shell
$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 43d57a8ea43e
172.18.0.3
```

- [inspect](https://docs.docker.com/engine/reference/commandline/inspect/#examples)
- [exec](https://docs.docker.com/engine/reference/commandline/exec/)


## Publish
現在，將鏡像推送到 `Google Container Registry(gcr)`。之後，將刪除所有容器和鏡像以模擬新的環境，然後將其鏡像拉到本地並運行容器。這說明了 `Docker` 容器的可移植性。要將鏡像推送到由 `gcr` 託管的專用 `registry` 中，需要使用 `registry`名稱標記這些鏡像。格式是 `[hostname]/[project-id]/[image]:[tag]`

- [hostname]= gcr.io
- [project-id]= your project's ID
- [image]= your image name
- [tag]= any string tag of your choice. If unspecified, it defaults to "latest".


```shell
gcloud config list project # 查看專案 ID
```

標記 `node-app:0.2` 將其轉換 [project-id]

```shell
docker tag node-app:0.2 gcr.io/[project-id]/node-app:0.2
$ docker tag node-app:0.2 gcr.io/qwiklabs-gcp-03-3335e10b0c8c/node-app:0.2
$ docker images
REPOSITORY                                     TAG                 IMAGE ID            CREATED             SIZE
node-app                                       0.2                 006da30f7a93        4 minutes ago       884MB
gcr.io/qwiklabs-gcp-03-3335e10b0c8c/node-app   0.2                 006da30f7a93        4 minutes ago       884MB
node-app                                       0.1                 646fb78d27c1        7 minutes ago       884MB
hello-world                                    latest              bf756fb1ae65        8 months ago        13.3kB
node                                           6                   ab290b853066        16 months ago       884MB
```

將其推送到 `gcr`

```shell
$ docker push gcr.io/qwiklabs-gcp-03-3335e10b0c8c/node-app:0.2
The push refers to repository [gcr.io/qwiklabs-gcp-03-3335e10b0c8c/node-app]
8fc5f55ee7cc: Pushed
2c3cb90bcbbf: Pushed
f39151891503: Pushed
f1965d3c206f: Pushed
a27518e43e49: Pushed
910d7fd9e23e: Pushed
4230ff7f2288: Pushed
2c719774c1e1: Pushed
ec62f19bb3aa: Pushed
f94641f1fe1f: Pushed
0.2: digest: sha256:db842391205f4cb28919d7ee5865aec55cb5a4d20491cce1b3f6278d44f9337e size: 2422
```

從 `GCP` 選單選擇 `Tools > Container Registry` 或直接輸入 `ttp://gcr.io/[project-id]/node-app` 訪問，在 `GCP` 上會看到如下圖

![](https://i.imgur.com/eSR9zfV.png)

![](https://i.imgur.com/nrUakV4.png)

我們測試一下鏡像，可以啟動一個新的 `VM`，`SSH` 到該 `VM` 中，然後安裝 `gcloud`。這邊將刪除所有容器和圖像以模擬全新的環境。

停止並刪除容器

```shell
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
docker rmi node-app:0.2 gcr.io/[project-id]/node-app node-app:0.1
docker rmi node:6
docker rmi $(docker images -aq) # remove remaining images
docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
```

拉取鏡像和運行

```shell
$ docker pull gcr.io/qwiklabs-gcp-03-3335e10b0c8c/node-app:0.2
$ docker run -p 4000:80 -d gcr.io/[project-id]/node-app:0.2
curl http://localhost:4000
Welcome to Cloud
```
