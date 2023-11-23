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
