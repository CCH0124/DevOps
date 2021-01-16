# Jenkins
### SDLC
- 需求分析
- 設計
    - 樣子
    - 功能
- 實現
    - 編碼
- 測試
    - 功能測試
    - 代碼測試
    - 壓力測試
- 維護
    - 功能修改
    - 臭蟲修改

### 軟體開發瀑布模型
無法回頭。

![](https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Waterfall_model.svg/1200px-Waterfall_model.svg.png)

##### 缺點
- 每個階段劃分完全固定，階段之間產生大量檔案，工作量相對也增加
- 直到整個過程後期，才能看見結果，風險較高
- 無法適應客戶需求

##### 優點
- 簡單易用
- 前一個階段完成，只須關注後段
- 為專案提供按階段劃分的檢查節點

### 敏捷開發模型
核心是迭代開發(iterative Development)與增量開發(Incremental Development)

##### 迭代開發
將開發過程拆分多個小周期，每次小開發都是同一流程。也因此會產生許多版本。
##### 增量開發
軟體的每個版本，都會新增一個用戶可以知道的完整功能，以功能來劃分迭代。

##### 如何迭代
每次迭代都是一個完整的軟體開發周期，須按照軟體工程的方法論進行流程管理。
![](https://nullsweep.com/content/images/2019/04/security_with_agile_development.png)

##### 敏捷開發好處
- 早期交付
    - 每一次的迭代都會進行交付
- 降低風險
    - 即時了解需求，降低產品的不適應

### 持續集成(Continuous integration)

頻繁的將程式碼集成到主分支。其目的是讓產品可以快速迭代，同時保持品質。在集成到主分支時會進行測試，只要失敗就無法集成。

這整個過程可以讓團隊快速從一個功能到另一個功能，這是敏捷開發的其中部分。



##### 流程

![](https://i.imgur.com/95X4hPC.png)


- 提交
開發者向倉庫提交

- 測試
對 commit 配置，只要提交代碼或合併至主分支，就會觸發自動化測試

- 構建 
透過上面測試，代碼就可以合併至主分支，基本上就是可以交付。該交付會進行 build，再進行測試。構建是指將原碼轉換為可運行的實際代碼，像是安裝依賴、配置各種資源等。

- 測試
第二輪測試，如果第一次很完整，可省略此第二輪

- 部署
如果測試都通過，當前程式碼就是一個可直接部署的版本(artfact)。此版本的所有檔案將打包儲存，並送往生產服務器（Docker）。

- 回滾
目前版本有問題，可回到上一版

### CI 組成元素
- 自動化過程
    - 從代碼、編譯、測試等
- 一個程式碼儲存倉庫
    - git 等
- 持續集成的服務器
    - jenkins 等

### CI 優點
- 降低風險
- 對系統健康狀態持續關注
- 減少重複工作
- 持續部署
- 持續交付可使用版本
- 增加團隊信心

### Jenkins 介紹

持續集成的工具，目前主流。

##### 特徵
- 分散式構建
- 豐富的套件
- 訊息通知和測試報告
- 等

## Jenkins 安裝與持續集成

環境有一台 gitlab 服務器，另一台是安裝 Jenkins 服務和 tomcat 服務。服務皆以 Docker 構建。


## GitLab 安裝

```shell=
version: '3.2'
services:
  gitlab:
    image: gitlab/gitlab-ce:latest
    hostname: gitlab.cch.com
    container_name: gitlab
    restart: always
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://192.168.134.143'
        gitlab_rails['gitlab_shell_ssh_port'] = 2222
        #nginx['redirect_http_to_https'] = true
        #nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.cch.com.crt"
        #nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.cch.com.key"
    volumes:
      - '${GITLAB_HOME}/config:/etc/gitlab'
      - '${GITLAB_HOME}/logs:/var/log/gitlab'
      - '${GITLAB_HOME}/data:/var/opt/gitlab'
     #- '${GITLAB_HOME}/config/ssl:/etc/gitlab/ssl'
    ports:
     #- 443:443
      - 80:80
      - "2222:22"
    networks:
      - gitlab-net
networks:
  gitlab-net:
```

.env 檔案
```shell=
GITLAB_HOME=/srv/gitlab
```

### GitLab 添加群組、用戶、建立專案

##### 建立群組
使用管理員創建，一個組裡面可以有多個專案分之，可將開發添加到群組裡面進行設置權限，不同的群組就是不同開發的專案，這可實現權限管理。

點擊 New group 
![](https://i.imgur.com/ePoQhJ2.png) 

![](https://i.imgur.com/V4R82cG.png)


從 dev 群組建立專案
點擊 New Project
![](https://i.imgur.com/3yRvWUt.png)

點擊 Create Project 即可建立
![](https://i.imgur.com/0d50Nek.png)


管理使用者介面

![](https://i.imgur.com/F91JooB.png)

點擊 New User 即可建立用戶

![](https://i.imgur.com/aOhZp8C.png)


將使用者添加至 dev 群組中

![](https://i.imgur.com/irWQBCJ.png)


GitLab使用者在群組中有 5 種不同權限

- Guest
    - 可創建 issue、發表評論、不能讀寫版本庫
- Reporter
    - 可以 clone
    - 無法提交
    - QA、PM 可賦予此權限
- Developer
    - 可以 clone、開發、提交
    - 普通開發適合此權限
- Maintainer
    - 可以建立專案
    - 添加 tag
    - 保護分支
    - 添加專案成員
    - 編輯專案
    - 核心開發適合此權限
- Owner
    - 可以設置專案訪問權限
        - 刪除專案
        - 遷移專案
        - 管理成員

使用創建的使用者登入，這邊為 itachi

可以看到它加入的群組

![](https://i.imgur.com/Law0iwH.png)


建立一個 spring boot 專案並以 itachi 使用者將其上傳至 dev 群組上

![](https://i.imgur.com/SEkgurh.png)


## Jenkins Install

```shell=
version: '3.7'
services:
  jenkins:
    image: jenkins/jenkins:lts
    privileged: true
    user: root
    restart: always
    ports:
      - 8080:8080
      - 50000:50000 # 用於主從通訊
    container_name: jenkins
    volumes:
      - ./jenkins:/var/jenkins_home
      - /opt/maven:/usr/local/maven
      - /opt/java8:/usr/local/jdk
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/local/bin/docker:/usr/local/bin/docker
```

創建一個管理員
![](https://i.imgur.com/dQY8Jnf.png)

>cch，123456

Jenkin 介面
![](https://i.imgur.com/OgNUxoR.png)


### 套件管理

至 管理 Jenkins -> 管理外掛程式，英文介面為 Manage Jenkins -> Manage Pluging

![](https://i.imgur.com/zk8C6kv.png)

在 Advanced 選項中可以更改 Update Site 來加速套件安裝

![](https://i.imgur.com/HYtu3Qn.png)

### Jenkins 使用者權限管理
安裝 Role based Authorization Strategy 套件，Jenkins 域設下沒有較細膩的權限分配

![](https://i.imgur.com/E7ekpOA.png)


從管理 Jenkins 點擊設定全域安全性(configure Security)

![](https://i.imgur.com/PsQ0Dsu.png)


其權限設置的非常不細膩，將其更該成安裝的套件 Role-Based Strategy
![](https://i.imgur.com/Onihn12.png)


接著再到 Mamage and Assign Roles
![](https://i.imgur.com/02bDjmf.png)

在 Manage Roles 中有三個角色
- Global roles
    - 管理 Jenkins 所分派的角色
    - 我們所建立的管理員即為此角色
- Item roles
    - 針對專案
- Node roles
    - 應用於主從機制


這邊設置一個 baseRole 的角色，用於用戶創建後所擁有的基本動作

![](https://i.imgur.com/gnC0WjY.png)



建立兩個 Item roles 的角色

![](https://i.imgur.com/vKFMnso.png)

Pattern 是填寫專案名稱，可用正規化去設計


baseRole 將會給予 role1、role2 基本的權限


在至 Manage User 建立使用者

![](https://i.imgur.com/PKkvgg7.png)


![](https://i.imgur.com/Sh01OR8.png)


建立完之後，是沒有權限可以操作任何事情。因此我們需要給予權限。至  Manage and Assign Roles 中的 Assign Roles。

![](https://i.imgur.com/pjcPxrE.png)

使用 naruto 登入後其權限是無法管理專案的，因此要給予專案權限
![](https://i.imgur.com/p8edcd1.png)

![](https://i.imgur.com/XzVSID0.png)

最後新增結果，也把 madara 用戶授予權限
![](https://i.imgur.com/2ubn8mf.png)



這邊在透過 New Item 建立專案，分別是 cch01、cchweb01

![](https://i.imgur.com/0b8SFq5.png)

至首頁後可以看到兩個項目

![](https://i.imgur.com/019D6Kq.png)

### 憑證管理
安裝 Credentials Binding 套件，套件中沒搜尋到，因此使用 upload plugin 方式

[Credentials Binding 檔案下載](https://updates.jenkins.io/download/plugins/credentials-binding/)

![](https://i.imgur.com/lYOA8O5.png)

設至為之後再到 installed 選項中下載 Credentials Binding。

從 Manage Jenkins 點擊 Credentials
![](https://i.imgur.com/wdr7Q32.png)

點擊 (global) 再點擊 Add Credentials

![](https://i.imgur.com/JM4KNH9.png)

有五種類型
- Username with password
    - 帳號相關訊息
- SSH Username with private key
    - SSH Key 登入
- Secret file
    - 需要受保密的檔案，使用時 Jenkins 會複製到臨時目錄下，再將該路徑設置到環境變數，建構完成後並將其刪除
- Secret text
    - 需要受保存一個加密的字串檔案，像是 api tokens 等
- Certificate


這邊以 gitlab 為範例，再 jenkins 將其添加至憑證。這邊需要安裝 Git 套件

裝了 git 套件後，專案就可用 Git 套件功能
![](https://i.imgur.com/wcbKeJN.png)

創建憑證，輸入 gitlan 所建立的使用者帳號與密碼

![](https://i.imgur.com/NNMbsk0.png)

![](https://i.imgur.com/AcrP6u6.png)


進入 cch01 專案項目點擊 configure，進行 gitlab 上專案的設定，最後保存。

![](https://i.imgur.com/JybFwVG.png)

透過 Build Now 來進行驗證，之後至控制台進行查看，該項目會被拉到 `/var/jenkins_home/workspace/cch01` 中。

![](https://i.imgur.com/5ZN95wM.png)


##### SSH Key 方式

使用 `ssh-keygen -t rsa`，產生以下檔案

```shell=
cch@node01:~$ ls .ssh/
id_rsa  id_rsa.pub  
```

gitlab 上使用管理員進行登入並配置，點擊 settings

![](https://i.imgur.com/D7jpxYt.png)

將產生的 .pub 公鑰張貼上去，我們再利用 jenkins 憑證管理私鑰，Private Key 張貼 `id_rsa` 私鑰。

![](https://i.imgur.com/RVYQIs1.png)

>cch 為產生該金鑰的使用者

建立一個項目進行測試

![](https://i.imgur.com/KAhKMVs.png)

## 建立 MAVEN 環境
這邊不演示安裝部分

### Jenkins 配置 Maven

Manage Jenkins -> Global Tool Configuration

    
![](https://i.imgur.com/om53oYo.png)

![](https://i.imgur.com/4JwdUlF.png)

![](https://i.imgur.com/weJMmrK.png)



使用一個專案進行測試

![](https://i.imgur.com/ycJA1lF.png)


## Jenkins 建構 Maven 專案
### Jenkins 建構專案類型
- FreeStyle Project
- Maven Project
- Pipeline Project

上面都可以完成一樣的建構過程和結果，只是靈活度和操作有所不同。

### FreeStyle Project

建立專案
![](https://i.imgur.com/zCut9Jc.png)

獲取 gitlab 上專案

![](https://i.imgur.com/FcWftVu.png)

##### 編譯打包使用 Maven
至 Build 的標籤進行設置

![](https://i.imgur.com/mxABMdB.png)


點擊 Build Now 構建

![](https://i.imgur.com/mkj2GNs.png)


其 war 輸出會在 workspace 中，這部分是從容器中掛載至本地
```shell=
cch@node01:~/jenkins/workspace/web_demo_freestyle/target$ ls
classes                      democicd-0.0.1-SNAPSHOT.jar.original  generated-test-sources  maven-status      test-classes
democicd-0.0.1-SNAPSHOT.jar  generated-sources                     maven-archiver          surefire-reports
```

##### 佈署
我們將使用 Deploy to container 套件完成。在 `Post-build  Actions` 這標籤下選擇如下圖選項

![](https://i.imgur.com/Z430mlH.png)


![](https://i.imgur.com/AacRUX0.png)

### Pipeline 
##### 概念
工作留框架，將原來獨立運行於單個或多個節點的任務連接起來，實現單個任務難以完成的複雜工作。
與 freestyle 方式相比，freestyle 是一步一步構建不好管理。Pipeline 則是會統一維護。

##### 優勢
- 代碼
    - 可被版控，使團隊能夠編輯、審查害迭代
- 持久
    - 無論為計劃內或計劃外，Pipeline 都是可恢復的
- 可停止
    - Pipeline 可接收交互式輸入，以確定是否繼續執行 Pipeline
- 多功能
    - Pipeline 支持複雜的持續交付要求，支援了 fork/join、循環等
- 可擴展
    - Pipeline 支援其 DSL 的自定義擴展
##### 創建 Piepline
- 由 Groovy 實現
- 支援兩種寫法，Declarative 和 Scripted Pipeline
- 創建方式可在 Web UI 操作或是使用 jenkinsfile 腳本放入專案中

##### 安裝套件
搜尋 Pipeline

## 學習中，未完...
