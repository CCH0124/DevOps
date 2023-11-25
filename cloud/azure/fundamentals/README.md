## Computing Services

**Azure Virtual Machine**

Windows 或是 Linux 的虛擬機。可以選擇 OS、Memory、CPU、Storage 等。硬體是與其它客戶共享，但也可專用。

**Azure Container Instances**

可以運行容器化應用程序，在 Azure 上運行容器化應用程式，而無需配置伺服器或虛擬機器。

**Azure Kubernetes Service (AKS)**

易於部署、管理和擴展容器化應用程式。

**Azure Service Fabric**

- 作為服務、應用程式或雲端服務的一級企業容器。所以它適用於分散式系統平台，它運行在 Azure 雲端或本地。
- 很容易打包、部署和管理可擴展且可靠的微服務。

**Azure Functions**
- 事件驅動的無伺服器計算，只要上傳較小邏輯的程式碼。
- 無需考慮伺服器或配置任何內容，只需為該程式碼運行的時間付費

**Azure Batch**
  
可以規劃時間表，並行執行 100 多個作業的批次計算工作負載，可以搭配 spot VM 來省下一些成本

>spot VM 可以想成是*低優先級虛擬機器*


## Storage Service

**Azure Blob Storage**

可以儲存非常大的文件和大量非結構化文件。只需為儲存的內容付費。它基本上是無限的儲存，不必調整捲(volume)的大小，不必擔心檔案系統協議(filesystem protocol)

**Azure Disk Storage**

虛擬卷，選擇 SSD 或 HDD。可以想像是雲端中的硬碟，預設上是被加密的，並且是附加在 VM 上

**Azure File Storage**

是一個共享卷，可以像檔案伺服器一樣存取和管理。可能是 SMB 協定通訊

**Azure Queue Storage**

是一個訊息佇列。在應用程式之間排隊和可靠地傳遞訊息的資料儲存。所以它只是將兩個應用程式整合在一起，並傳遞訊息。

**Azure Table Storage**

是一個 NoSQL 資料庫。獨立於任何模式的非結構化資料。

**Azure Data Box / Azure Databox Heavy**

旨在移動 TB 或 PB 的資料。

**Azure Archive Storage**

當需要使用最便宜的儲存選項將檔案保留多年時，可以使用 Long term cold storage。

**Azure Data Lake Storage**

是一個*集中式存儲庫*，當處理來自多個不同來源的大數據時，它允許儲存任何規模的所有結構化和非結構化數據。

## Database Services

**Azure Cosmos DB**

完全託管的 *NoSQL* 資料庫。它為*擴展*而設計，保證了 99.999% 的可用性

**Azure SQL Database**

完全託管的 *MS SQL* 資料庫，自動縮放、完整性、可用性等

**Azure Database for MySQL/PSQL/MariaDB**

完全託管且可擴展，有高可用和安全性等特性。

**SQL Server on VMs**

可以在虛擬機器上安裝 SQL Server。

**Azure Synapse Analytics(Azure SQL Data Warehouse)**

一個完全託管的資料倉庫，在各個規模層級上都具有整體安全性，無需額外成本

**Azure Database Migration Service**

無需更改應用程式程式碼即可將資料庫遷移到雲端。 

**Azure Cache for Redis**

需要記憶體緩存，即使用開源 Redis，則可以使用它。快取通常和靜態資料使用減少應用程式獲取資料的延遲

**Azure Table Storage**

是一個 NoSQL 資料庫。獨立於任何模式的非結構化資料。


## Application Integration Services

**Azure Notification Hub**

使用 pub/sub 模式，用於從任何後端向任何平台發送推播通知

**Azure API Apps**

API Gateway，可以在雲端中快速建立且使用 API，路由 API 到 Azure 服務像是 functions 或是 containers。

**Azure Service Bus**

可靠的雲端訊息傳遞即服務，可實現簡單的混合整合

**Azure Stream Analytics**

無伺服器的即時分析，從雲端到邊緣的服務。

**Azure Logic Apps**

排程、自動化編排任務、業務流程和工作流程，並與企業、SaaS、和應用程式整合。

**Azure API Management**

這是一個適用於 API 的混合多雲管理平台，適用於所有環境。將其放在現有 API 前面以添加額外功能，基本上是你的 API 的代理。

## Developer and Mobile Tools

**Azure SignalR Service**

*Real-Time Messaging* 在應用程式中添加即時 Web 功能。它就像 Pusher 一樣。


**Azure App Service**

簡易的部署和擴充 Web 應用程式，有 .Net、Node、Java、Python 等。開發者專注於建置他們的應用程式，不用關心底層，有點像是 Heroku 這樣。

**Visual Studio(Microsoft-owned)**

*code edit*，基本上是一個 IDE

**Xamarin**

*行動應用程式框架*，用於建立強大且可擴展的行動應用程式使用 .net。

## Azure DevOps Servicers

**Azure DevOps**

計劃更明確、協作並更快地交付。

- Azure Boards
  - 敏捷工具更快的用戶提供價值以規劃、追蹤和討論整個團隊的工作
- Azure Pipelines
  - 建置、測試和部署適用於任何語言、平台和雲平台的 CI/CD
  - 連接到 GitHub 或任何其他供應商並持續部署
- Azure Repo
  - 取得無限的、雲端託管的私人 Git 儲存庫，並透過拉取請求和進階檔案管理協作來建立更好的程式碼維護
- Azure Test Plans
  - 使用手動和探索性測試工具充滿信心地進行測試和交付
- Azure Artifacts
  - 建立、託管並與團隊共用套件，只需按一下即可將工件(Artifacts)新增至 CI/CD 管線
- Azure DevTest Labs
  - 為開發人員創建開發測試環境的簡單方法
 
## Azure Resource Manager(ARM) 
