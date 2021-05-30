Docker 如何使用主機的硬碟空間 ? 以及在不再使用時如何回收 ?

`Docker` 提供了*建構*、*推送*和*運行*等資源。這讓開發者不會汙染本機資源，但當我們運行 `docker run`、`pull image`或部署複雜的應用程式構建屬於開發團隊自己的 `image` 時，主機檔案系統上的佔用空間可能會明顯的增加。

下面指令，可以顯示出 Docker 的操作使用了本機多少資源。當資源沒被使用時應該要回收。

```bash
$ docker system df
```

- Images
    - 從 `registry` 中提取的 `image` 和本地鍵置的 `image` 大小
- Containers
    - 系統上運行的容器所使用的硬碟空間，即每個容器的*讀寫層空間*
- Local Volumes
    - 儲存在主機上但在容器的檔案系統之外
- Build Cache
    - `image` 鍵置過程生成的緩存


### Containers Disk Usage
當啟動一個容器時會在 `/var/lib/docker`  下創建多個目錄和檔案。默認下容器使用 JSON 格式儲存日誌到該目錄下，所以日誌應當做相對應的處裡，否則將會影響本地主機的硬碟空間。
`/var/lib/docker/overlay2` 中的其中目錄包含容器的*讀寫層*。如果容器將數據保存在自己的檔案系統中，該數據將儲存在主機上的 `/var/lib/docker/overlay2` 下。


當啟動容器時，這個空間如何回收? 透過刪除容器，將*刪除關聯讀寫容器的層*。

以下指令，允許一次刪除所有*停止*的容器並回收它們正在使用的硬碟空間
```bash
docker container prune
```

如果要刪除運行和無運行的容器可以使用以下方式

```bash
$ docker rm -f $(docker ps -aq)
$ docker container rm -f $(docker container ls -aq)
```

>`image` 被至少一個容器使用，它使用的硬碟空間就無法回收


### Images Disk Usage

有一些 `image` 對終端使用者是不直接可見的
- 中間 `image` 被其他 `image`（child image）引用，無法移除
- `Dangling images` 是不再引用的 `image`，它們佔用一些硬碟空間，是可被刪除
    - 就是 `REPOSITORY` 欄位為 `<none>` 


```bash
docker image ls -f dangling=true
```

```bash
docker image rm $(docker image ls -f dangling=true -q)
```

```bash
docker image prune
```

```bash
docker image rm $(docker image ls -q)
```

### Volumes Disk Usage
卷(volume)用於在容器檔案系統之外來儲存數據。通常容器運行有狀態應用程式時，會希望將數據保存在容器外部，以便與容器生命週期分離。容器中頻繁的檔案系統操作會帶來效能的影響。

假設運行容器時使用 `-v` 選項，而容器內部進行像是備份操作則結果會儲存至 `/var/lib/docker/volumes` 下。

當我們終止或停止容器的運行時，卷並不會被移除。因此重新相同容器時，會在使用該位被刪除的卷(匿名卷沒辦法)，除非明確刪除否則將佔用空間。

```bash
docker volume rm $(docker volume ls -q)
docker volume prune
```

### Build Cache Disk Usage
Next time...

### Cleaning Everything at Once

```bash
docker system prune
```
