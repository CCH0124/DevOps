# Docker 
- [namespace](https://www.youtube.com/watch?v=MHv6cWjvQjM&ab_channel=Docker)

## OS 層內建立虛擬環境
Linux 在核心內建的 Control Group 和 Namespaces 機制，正是用來分配 Host OS 運算資源的機制。

#### Namespaces

Namespaces 是系統資源的使用名單，記錄了系統資源要分成多少份，每一份的名字是什麼，方便呼叫和取用特定一份的資源。

就像辦公室的座位表一樣，不只是員工姓名清單，也記錄了每一個姓名所在的位置，甚至聯絡這個員工的分機。

Container 會擁有自己唯一的 Namespaces 名稱，來區分身份，透過Namespace 清單，這個 Container 不用知道其他 Container 的存在也能分配資源。

#### Control Group
有 Namespaces 機制後，可以利用 Control Group 管理每一個名字可用資源的權限。

- Control Group 可以管制
    - 記憶體
    - 檔案快取
    - CPU使用
    - 磁碟I/O等
    - 追蹤這些資源被使用的情況，安排不同資源存取的優先順序，甚至是凍結程式的執行

>LXC 技術就是利用 Control Group 來管理一個 Container 使用各種資源的權限

#### 總結
Namespaces + Control Group = 應用程式看起來是在一個孤立環境中執行

## Container 是以應用程式為中心的虛擬化
- 傳統虛擬化技術
    - vSphere、Hyper-V
    - 作業系統為中心
    - 建立一個可以用來執行整套作業系統的沙箱獨立執行環境（Virtual Machine）
        - 用軟體模擬出 vCPU、vRAM 等實體伺服器的功能，其自身感覺在實體機中
    - 將**軟體**和**硬體**的相依關係切開，讓軟體盡可能地不用綁定於特定廠牌或規格的硬體
    - 優點
        - 安全性高
    - 缺點
        - 速度
            - 虛擬機器的建立速度，受限於作業系統的開機速度
        - 映象檔容量
            - 程式碼只有 10KB，也得安裝一整套上百 MB 的作業系統軟體才行
        - 資源
            - 執行作業系統本身也得消耗不少的運算資源
                - 一臺實體伺服器內要執行100個虛擬機器，就等同於要執行一百套Guest OS
- Container
    - 應用程式為中心的虛擬化技術
    - OS 層虛擬化技術
        - 在 OS 內的核心系統層來打造虛擬機器，透過共用 Host OS 的作法，取代多個 Guest OS 的功用
        - 不需要另外安裝 Guest OS 個別管理
    - 直接將一個應用程式所需的相關程式碼、函式庫、環境配置檔都打包起來
        - 建立嚴格的資源控管機制來分配 Host OS 上的系統資源，避免 Container 占用資源或當機時，影響 Host OS 或其它 Container 的執行
    - Client-Server 架構

兩者，方便的將一套應用程式所需的執行環境打包起來，來能簡化複雜的 IT 架構方便管理、移動或部署各種應用程式。


>負責執行虛擬化平臺的是 Host OS，而在虛擬化平臺內建立的虛擬機器內則是執行 Guest OS

>Docker 是一個 Client-Server 架構的應用程式，在一個 Docker 執行環境中，包括了 Docker 用戶端程式、和在背景執行（Daemon）的 Docker 伺服器（也稱為Docker Engine）
## Docker 基本概念
- Docker images：Image（映像檔）被用來啟動容器的實際執行得應用程式環境。這概念類似 VM 的映像檔，VM 透過映像檔來啟動作業系統，並執行許多服務，但 Docker 的映像檔則只是檔案系統的儲存狀態，是一個唯讀的板模。
- Docker containers：Container（容器）是一個應用程式執行的實例，Docker 會提供獨立、安全的環境給應用程式執行，容器是從映像檔建立，並運作於主機上。

>盡量不要在一個 Container 執行過多的服務。

- Docker registries：Registries 是被用來儲存 Docker 所建立的映像檔的地方，我們可以把自己建立的映像檔透過上傳到 Registries 來分享給其他人。Registries 也被分為了公有與私有，一般公有的 Registries 是 Docker Hub，提供了所有基礎的映像檔與全球使用者上傳的映像檔。私人的則是企業或者個人環境建置的，可參考 Deploying a registry server。

## Docker 架構
![](https://i.imgur.com/3kTwFKk.png)

#### Docker Client
Docker Client 是 Docker 架構中用戶用來和 Docker Daemon 建立通信的客戶端。用戶使用的可執行文件為 docker，透過 docker 命令行工具可以發起眾多管理 container 的請求。

Docker Client 可以透過以下三種方式和 Docker Daemon 建立通信：tcp://host:port、unix://path_to_socket 和 fd://socketfd。為了簡單起見，本文一律使用第一種方式作為講述兩者通信的原型。與此同時，與Docker Daemon 建立連接並傳輸請求的時候，Docker Client 可以透過設置命令行 flag 參數的形式設置安全傳輸層協議(TLS)的有關參數，保證傳輸的安全性。

Docker Client 發送容器管理請求後，由 Docker Daemon 接受並處理請求，當 Docker Client 接收到返回的請求相應並簡單處理後，Docker Client 一次完整的生命週期就結束了。當需要繼續發送容器管理請求時，用戶必須再次通過 docker 命令創建 Docker Client。

#### Docker Daemon
Docker Daemon 是其架構中一個**常駐在後台的系統進程**，功能是：接受並處理 Docker Client 發送的請求。該守護進程在後台啟動了一個 Server，負責接受 Docker Client 發送的請求；接受請求後，Server 透過路由與分發調度，找到相應的 Handler 來執行請求。

Docker Daemon 啟動可執行文件也為 docker，與 Docker Client 啟動可執行文件 docker 相同。在 docker 命令執行時，透過傳入的參數來判別 Docker Daemon 與 Docker Client。

Docker Daemon 的架構，大致可以分為以下三部分：
1. Docker Server
2. Engine 
3. Job

![](https://i.imgur.com/gx09Lvl.png)

- Docker Server
Docker Server 在其架構中是專門服務於 Docker Client 的 server。該 server 的功能是：接受並調度分發 Docker Client 發送的請求。

![](https://i.imgur.com/fIGZ85q.png)

在 Docker 的啟動過程中，透過包 `gorilla/mux`，創建了一個 `mux.Router`，提供請求的路由功能。在 Golang 中，gorilla/mux 是一個強大的 URL 路由器以及調度分發器。該 mux.Router 中添加了眾多的路由項，每一個路由項由 HTTP 請求方法（PUT、POST、GET 或 DELETE）、URL、Handler 三部分組成。

若 Docker Client 通過 HTTP 的形式訪問 Docker Daemon，創建完 mux.Router 之後，Docker 將 Server 的監聽地址以及 mux.Router 作為參數，創建一個 httpSrv=http.Server{}，最終執行 httpSrv.Serve() 為請求服務。

在 Server 服務過程中，Server 在 listener 上接受 Docker Client 的訪問請求，並創建一個全新的 goroutine 來服務該請求。在 goroutine 中，首先讀取請求內容，然後做解析工作，接著找到相應的路由項，隨後調用相應的 Handler 來處理該請求，最後 Handler 處理完請求之後回覆該請求。

需要注意的是：Docker Server 的運行在 Docker 的啟動過程中，是靠一個名為 `serveapi` 的 job 的運行來完成的。原則上，Docker Server 的運行是眾多 job 中的一個，但是為了強調 Docker Server 的重要性以及為後續 job 服務的重要特性，將該 serveapi 的 job 單獨抽離出來分析，理解為 Docker Server。

- Engine
Engine 是其架構中的運行引擎，同時也 Docker 運行的核心模塊。它扮演 Docker container 存儲倉庫的角色，並且通過執行 job 的方式來操縱管理這些容器。

在 Engine 數據結構的設計與實現過程中，有一個 handler 對象。該 handler 對象存儲的都是關於眾多特定 job 的 handler 處理訪問。舉例說明，Engine 的 handler 對像中有一項為：{"create": daemon.ContainerCreate,}，則說明當 "create" 的 job 在運行時，執行的是 daemon.ContainerCreate 的 handler。

- Job 
一個 Job 可以認為是其架構中 Engine 內部最基本的工作執行單元。Docker 可以做的每一項工作，都可以抽象為一個 job。例如：在容器內部運行一個進程，這是一個 job；創建一個新的容器，這是一個 job，從 Internet 上下載一個文檔，這是一個 job；包括之前在 Docker Server 部分說過的，創建 Server 服務於 HTTP 的 API，這也是一個 job，等等。

Job 的設計者，把 Job 設計得與 Unix 進程相仿。比如說：Job 有一個名稱，有參數，有環境變量，有標準的輸入輸出，有錯誤處理，有返回狀態等。

#### Docker Registry
Docker Registry 是一個存儲容器鏡像的倉庫。而容器鏡像是在容器被創建時，被加載用來初始化容器的文件架構與目錄。

在 Docker 的運行過程中，Docker Daemon 會與 Docker Registry 通信，並實現搜索鏡像、下載鏡像、上傳鏡像三個功能，這三個功能對應的 job 名稱分別為 search、pull 與 push。

其中，在其架構中，Docker 可以使用公有的 Docker Registry，即大家熟知的 Docker Hub，如此一來，Docker 獲取容器鏡像文件時，必須通過互聯網訪問 Docker Hub；同時 Docker 也允許用戶構建本地私有的 Docker Registry，這樣可以保證容器鏡像的獲取在內網完成。

#### Graph
Graph 在其架構中扮演已下載容器鏡像的保管者，以及已下載容器鏡像之間關係的記錄者。一方面，Graph 存儲著本地具有版本信息的文件系統鏡像，另一方面也通過 GraphDB 記錄著所有文件系統鏡像彼此之間的關係。

![](https://i.imgur.com/zDIUnQh.png)


其中，GraphDB 是一個構建在 SQLite 之上的小型圖數據庫，實現了節點的命名以及節點之間關聯關係的記錄。它僅僅實現了大多數圖數據庫所擁有的一個小的子集，但是提供了簡單的接口表示節點之間的關係。

同時在 Graph 的本地目錄中，關於每一個的容器鏡像，具體存儲的信息有：該容器鏡像的元數據，容器鏡像的大小信息，以及該容器鏡像所代表的具體 rootfs。

#### Driver
Driver 是其架構中的驅動模塊。透過 Driver 驅動，Docker 可以實現對 Docker 容器執行環境的定制。由於 Docker 運行的生命週期中，並非用戶所有的操作都是針對 Docker 容器的管理，另外還有關於 Docker 運行信息的獲取，Graph 的存儲與記錄等。因此，為了將 Docker 容器的管理從 Docker Daemon 內部業務邏輯中區分開來，設計了 Driver 層驅動來接管所有這部分請求。

在 Docker Driver 的實現中，可以分為以下三類驅動：
1. graphdriver
2. networkdriver
3. execdriver

- graphdriver
主要用於完成容器鏡像的管理，包括存儲與獲取。即當用戶需要下載指定的容器鏡像時，graphdriver 將容器鏡像存儲在本地的指定目錄；同時當用戶需要使用指定的容器鏡像來創建容器的 rootfs 時，graphdriver 從本地鏡像存儲目錄中獲取指定的容器鏡像。
在 graphdriver 的初始化過程之前，有 4 種文件系統或類文件系統在其內部註冊，它們分別是 aufs、btrfs、vfs 和 devmapper。而 Docker 在初始化之時，通過獲取系統環境變量 "DOCKER_DRIVER" 來提取所使用 driver 的指定類型。而之後所有的 graph 操作，都使用該 driver 來執行。
![](https://i.imgur.com/rJgfkjv.png)

- networkdriver
的用途是完成 Docker 容器網路環境的配置，其中包括 Docker 啟動時為 Docker 環境創建網路橋接；Docker 容器創建時為其創建專屬虛擬網卡設備；以及為 Docker 容器分配 IP、端口並與宿主機做端口映射，設置容器防火牆策略等。

![](https://i.imgur.com/JADTrtv.png)

- execdriver
作為 Docker 容器的執行驅動，負責創建容器運行命名空間、負責容器資源使用的統計與限制、負責容器內部進程的真正運行等。在 execdriver 的實現過程中，原先可以使用 LXC 驅動調用 LXC 的接口，來操縱容器的配置以及生命週期，而現在 execdriver 默認使用 **native** 驅動，不依賴於 LXC。具體體現在 Daemon 啟動過程中加載的 ExecDriverflag 參數，該參數在配置文件已經被設為 **native**。這可以認為是 Docker 在 1.2 版本上一個很大的改變，或者說 Docker 實現跨平台的一個先兆。

![](https://i.imgur.com/a3j7oTD.png)

- libcontainer
libcontainer 是其架構中一個使用 Go 語言設計實現的庫，設計初衷是希望該庫可以不依靠任何依賴，直接訪問內核中與容器相關的 API。

正是由於 libcontainer 的存在，Docker 可以直接調用 libcontainer，而最終操縱容器的 namespace、cgroups、apparmor、網路備以及防火牆規則等。這一系列操作的完成都不需要依賴 LXC 或者其他包。

![](https://i.imgur.com/P17SYjI.png)

另外，libcontainer 提供了一整套標準的接口來滿足上層對容器管理的需求。或者說，libcontainer 屏蔽了 Docker 上層對容器的直接管理。又由於 libcontainer 使用 Go 這種跨平台的語言開發實現，且本身又可以被上層多種不同的編程語言訪問，因此很難說，未來的 Docker 就一定會緊緊地和 Linux 捆綁在一起。而於此同時，Microsoft 在其著名雲計算平台 Azure 中，也添加了對 Docker 的支持，可見 Docker 的開放程度與業界的火熱度。

#### Docker container
Docker container 是 Docker 架構中服務交付的最終體現形式。

Docker 按照用戶的需求與指令，訂製相應的 Docker 容器：

- 指定容器鏡像，使得 Docker 容器可以自定義 rootfs 等文件系統；
- 指定計算資源的配額，使得 Docker 容器使用指定的計算資源；
- 配置網路及其安全策略，使得 Docker 容器擁有獨立且安全的網絡環境；
- 指定運行的命令，使得 Docker 容器執行指定的工作。

![](https://i.imgur.com/ndsBTwc.png)

#### 範例
- docker pull
![](https://i.imgur.com/n6yfex4.png)

- docker run
![](https://i.imgur.com/OXs6UCN.png)

#### Docker Client 的創建
Docker Client 的創建，實質上是 Docker 用戶通過可執行文件docker，與 Docker Server 建立聯繫的客戶端。

## Docker 映象檔

Docker 映象檔是一種分層堆疊的運作方式，採用了 **aufs** 的檔案架構。
建構一個可讓應用程式執行的 Container 映像檔，要先從 **Base Image** 疊起。

- AUFS
因為容器是共用內核，所以 aufs 都是使用 Host 主機端
![](https://i.imgur.com/zoh1FYY.png)Linux 運行需要兩個FS: bootfs + rootfs

>AUFS（AnotherUnionFS）是一種 Union FS, 簡單來說就是支持將==不同目錄掛載到同一個虛擬文件系統下==（unite several directories into a single virtual filesystem）的文件系統，更進一步的理解，AUFS 支持為每一個成員目錄（類似 Git Branch）設定 readonly、readwrite 和 whiteout-able 權限， 同時 AUFS 裡有一個類似==分層==的概念, 對 readonly 權限的branch 可以邏輯上進行修改（增量地，不影響 readonly 部分的）。通常 Union FS 有兩個用途，一方面可以實現不借助 LVM、RAID 將多個 disk 掛到同一個目錄下，另一個更常用的就是將一個 readonly 的 branch 和一個 writeable 的 branch 聯合在一起，Live CD正是基於此方法可以允許在 OS image 不變的基礎上允許用戶在其上進行一些寫操作。Docker 在 AUFS 上構建的 container image 也正是如此。
>bootfs（boot file system）主要包含 bootloader 和 kernel，bootloader 主要是引導加載 kernel，當 boot 成功後kernel 被加載到 memory 中後 bootfs 就被 umount 了 rootfs （root file system）包含的就是典型 Linux 系統中的 `/dev`、 `/proc`、`/bin`、`/etc` 等標準目錄和文件。
- 不同基礎映像檔
![](https://i.imgur.com/Hnx0F3E.png)


- 寫入層
執行 ubuntu 映像檔後，「docker run -ti ubuntu」會新增**寫入層**，操作容器用

![](https://i.imgur.com/VzPDo6g.png)

後續加入所需套件和功能，一層層堆疊使成特定用途的容器映像檔，每個分層都代表著 Dockerfile 中的一個指令

Dockerfile 定義的每一行的資料層都是唯讀。啟動容器時，才會再**疊上寫入層**

執行期間所增加的額外資料，只存於容器中，容器一旦刪除，這些額外資料便會一併刪除，這部分與虛擬化映像檔是有差別的。

典型的 Linux 在啟動後，首先將 rootfs 設置為 readonly，進行一系列檢查, 然後將其切換為 ==readwrite== 供用戶使用。在Docker 中，初始化時也是將 rootfs 以 readonly 方式加載並檢查，然而接下來利用 union mount 的方式將一個 readwrite 文件系統掛載在 readonly 的 rootfs 之上，並且允許再次將下層的FS（file system）設定為 readonly 並且向上疊加, 這樣一組readonly 和一個 writeable 的結構構成一個 container 的運行時態, 每一個 FS 被稱作一個 FS 層。

![](https://i.imgur.com/OB9QOSO.png)

>得益於 AUFS 的特性，每一個對 readonly 層`文件/目錄`的修改都只會==存在於上層的 writeable 層中==。這樣由於不存在競爭，多個container 可以==共享 readonly 的 FS 層==。所以 Docker 將readonly 的 FS 層稱作 ==image== 對於 container 而言整個rootfs 都是 read-write 的，但事實上所有的修改都寫入最上層的writeable 層中，==image 不保存用戶狀態，只用於模板、新建和複製使用==。

- 隔離性
因為容器的隔離性，因此一個 host 上執行多個容器
![](https://i.imgur.com/pZ7Ivw4.png)

>上層的 image 依賴下層的 image，因此 Docker 中把下層的 image 稱作父 image，沒有父 image 的 image 稱作 base image。因此想要從一個 image 啟動一個 container，==Docker 會先加載這個 image 和依賴的父 images 以及 base image==，用戶的進程運行在 writeable 的 layer 中。所有 parent image 中的數據信息以及 ID、網路和 lxc 管理的資源限制等具體 container 的配置，構成一個 Docker 概念上的 container。

![](https://i.imgur.com/IuX3pcT.png)

> 容器是即用即拋，所以可隨時打掉重練。

### Container 為何需要 OS 的基礎映象檔？

OS 基礎映象檔的用途是讓 Container 擁有這 OS 的檔案系統，例如使用ubuntu 基礎映象檔就可以讓 Container 建立 ubuntu 的根目錄架構，而不是用來執行一個 OS 執行實例。

### image 特點
1. 分層儲存
當需要修改 image 內的某個檔案時，只會對上方的讀寫層進行改動，不會覆蓋下層既有檔案系統內容。
![](https://i.imgur.com/ix2XQlW.png)

2. Copy-on-Write
![](https://i.imgur.com/QBHKTL0.png)

3. 內容尋址
4. 聯合掛載

### image 的建構
```shell=
docker build
docker commit
```
### image 倉庫
- 公共
- 私有
### image 的使用
```shell=
docker export
docker import
docker save
```
## 容器儲存
Linux 系統中 Docker 的數據默認存放在 `/var/lib/docker` 中。

### 儲存驅動
Docker 支持 `AUFS`、`BtrFS`、`Device Mapper`、`OverlayFS`、`ZFS` 五種儲存驅動

![](https://i.imgur.com/WnNdluX.png)

### 數據卷（Volume）
有狀態的容器都有數據持久化儲存的需求。檔案的變動都在最上層的可讀寫層。在容器的生命週期內，它是持續的，包括容器被停止後。但是，當容器被刪除後，該數據層也隨之被刪除了。因此可以藉由 `Volume` 提供持久化儲存。

在 Docker 中可以用 `volume`、`bind Mounts` 和 `tmpfs` 方式。Bind Mounts 依賴於主機的目錄結構，以 `volume` 來說優勢有以下
- 更容易輩分和遷移
- 多個容器之間更安全的共享
- 允許程序在遠端主機或雲端儲存 Volume、或加密的內容等
- 不會增加容器的大小
- 不會依賴於 Docker 生命週期

![](https://i.imgur.com/nqDLfnx.png)

### 指令
```shell=
docker volume create
docker volume inspect
docker volume ls
docker volume prune
docker volume rm
```

![](https://i.imgur.com/lnjEz4a.png)

## 容器網路
### 容器網路技術
- Network namespace
- Linux Bridge
- Veth Pair
##### Network namespace
網路隔離技術，創建一個網路命名空間後就有一個包括網路接口、路由、訪問控
制規則（Iptables）等網路資源的獨立網路環境，該命名空間的網路與其它網路隔離。
##### Linux Bridge
可以將不同主機的網路接口連接，從而實現主機間的通訊。Docker 啟動後，會默認創建名為 `docker0` 的 Linux Bridge
##### Veth Pair
為了實現容器與宿主機網路、外部網路之間的通訊，需要透過 `veth pair` 將容器與 Linux Bridge 連接。

### Host Network
以 Docker 來說有四種模式

##### None 模式
容器擁有自己的網路命名空間，但並不為容器進行任何的網路配置。創建的容器只有 loopback 接口，需要用戶為容器添加網卡、配置 IP 等。

![](https://i.imgur.com/7Hi5LR4.png)

##### Bridge 模式
主要是利用 Iptables 進行 NAT 和端口映射，從而提供單主機網路。此模式下同一主機上的容器之間是可以互相通訊的，但是分配給每個容器的 IP 地址從主機外部不能訪問。

![](https://i.imgur.com/3RK6Zgc.png)

##### Host 模式
Docker 服務啟動容器時並不會為容器創建一個隔離的網路環境，容器將會被加入主機所在網路，共享主機的網路命名空間（/var/run/docker/netns/default）。其網路配置（網路地址、路由表
和 Iptables 等）和主機保持一致，容器透過主機的網卡和 IP，實現與外部的通訊。

![](https://i.imgur.com/NsKKUnP.png)

##### container 模式
新創建的容器和已經存在的某個容器共享同一個命名空間。該容器不會有自己的網卡。
這兩個容器只有網路方面共享數據，文件系統、進程列表等其它方面還是隔離的。兩個容器的進程可以通過 loopback 網卡通訊。

![](https://i.imgur.com/MDefWlA.png)

### 指令
```shell=
docker network connect
docker network create
docker network diconnect
docker network inspect
docker network ls
docker network prune
docker network rm
```


[圖來源](https://k2r2bai.com/2016/01/05/container/docker-network/)

# Docker-compose

# Dockerfile

# Dockerfile
Dockerfile 是建構 image 的檔案。

![](https://i.imgur.com/RsXurEd.png)


## 指令
![](https://i.imgur.com/7WsR2E0.png)

### cmd vs ENTRYPOINT
在 Dockerfile 中，只能有一個 ENTRYPOINT 或 CMD 指令，如果有多個ENTRYPOINT 或 CMD 指令則以最後一個為準。
- ENTRYPOINT
    - 往往用於設置容器啟動後的第一個命令，這對一個容器來說往往是固定的。
    - 執行 docker run 如果帶有其他命令參數，不會覆蓋 ENTRYPOINT 指令
    - docker run 的 **--entrypoint** 可以覆蓋 Dockerfile 中ENTRYPOINT 設置的命令。
- CMD 
    - 往往用於設置容器啟動的第一個命令的默認參數，這對一個容器來說可以是變化的。docker run <command> 往往用於給出替換 CMD 的臨時參數。
    - docker run 如果帶有其他命令參數，將會覆蓋 CMD 指令。
    - 如果在 Dockerfile 中，還有 ENTRYPOINT 指令，則 CMD 指令中的命令將作為 ENTRYPOINT 指令中的命令的參數。

## Example
```shell=
/test$ tree
.
└── Dockerfile
```
### Dockerfile to Nginx
```shell=
FROM ubuntu:14.04

LABEL maintainer="s14113242@stu.edu.tw"

RUN apt-get update && apt-get install -y nginx

COPY . /var/www/html/

EXPOSE 80

#ENTRYPOINT ["nginx"]
CMD ["nginx", "-g", "daemon off;"]

```
### 建構
使用 `docker build -t {ImageName}:{tag01} .` 建構

使用 `docker images` 查看建構的 image

```shell=
REPOSITORY                                          TAG                 IMAGE ID            CREATED             SIZE
nginx                                               v0                  55077273116a        20 minutes ago      222MB

```

## multi-stage 


## --cache-from
