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

允許透過 JSON 模板以程式設計方式建立 Azure 資源。

## vNet and Subnet

**Virtual Network(vNet)** 是一個 Azure 網路中邏輯上隔離的部分，可以在其中啟動 Azure 資源。建立時需定義要使用的一定數量 IP 和 CIDR 範圍。如下圖

![](https://www.oreilly.com/api/v2/epubs/9781788991735/files/assets/5c3360aa-ebf1-45ef-9bbd-3a52ded71f39.png) From oreilly

`10.2.0.0/16` 是 vNet，再從該 vNet 切分網路給下面的資源。`10.2.0.0/16` 的 CIDR 範圍可有 65536(256*256) 個 IP 位址。

**Subnets** 它是將 IP 網路邏輯劃分為更小的網段，分成更小的 IP 範圍。當建立子網路時，它們必須更小。以上圖來說 `10.2.0.0/24` 和 `10.2.1.0/24` 這都是 vNet 下的 Subnet。

Subnet 需要比 vNet 更小的 CIDR 範圍切割， `10.2.0.0/24` 為例其只有 256 個 IP 位置可用。

**Public Subnet** 可以存取互聯網。

**Private Subnet**  無法存取互聯網。

## Cloud-Native Networking Services

**Azure DNS**

提供了超快的 DNS 回應和超高的網域可用性

**Azure Virtual Network (vNET)**

是一個 Azure 網路中邏輯上隔離的部分，可以在其中啟動 Azure 資源。

**Azure Load Balancer**

OSI 第四層的附載均衡

**Azure Application Gateway**

OSI 第七層的附載均衡，能夠整合 Web Application Firewll

**Network Security Group**

保護子網路(subnet) 層級的虛擬防火牆。限制 IP 連接或是 Port 連接等

## Enterprise/Hybrid Networking Services

**Azure Front Door**

這是一個可擴展且安全的入口點，用於快速交付你的全域應用程式，例如:確保你有一個從外部進入 Azure 的安全入口點

**Azure Express Route**

本機(on-premise)與 Azure 雲端之間的連線。它可以在每秒 50 Mbps 到每秒 10 Gbps。*如果從地端資料到 Azure 要有很快速的連接，可以使用此服務*。

**Virtual WAN**

網路服務將許多網路、安全、路由等功能結合在一起，以提供單一的操作介面。

**Azure Connection**

VPN 連線透過 IPsec 安全連線到 Azure 上網路。這只是與 Azure 建立安全連線的一種方法。

**Virtual Network Gateway**

Azure 虛擬網路和地端網路之間的站對站 VPN 連線。

## Azure Traffic Manager

*Azure Traffic Manager* 運作在 DNS 層級，*可根據選擇的路由方法*快速有效地引導傳入的 DNS 請求。重新路由流量，以便可以將流量路由到地理位置附近的伺服器，以減少故障轉移到冗餘系統的延遲，以防主系統變得不健康。

- 將流量路由到地理位置附近的伺服器以減少延遲
- 如果主系統故障，故障轉移到冗餘系統
- 模擬 A/B 測試，隨機路由到 VM

**Azure DNS**
 
DNS 允許在 Azure 上託管域名，因此可以建立 DNS 區域並*管理 DNS 記錄*。

>不允許購買域名

**Azure Load Balancer**

- 用於在一組後端資源或伺服器之間均勻分配傳入網路流量
- *運作在 OSI Layer 4*，因此對 HTTP 請求不了解

可建立在，
- **public Load Balancer** 從互聯網到具有公用 IP 位址的伺服器傳入流量
- **private Load Balancer** 傳入面向私有伺服器的內部網路流量

## Scale Sets

可以將虛擬機器分組，並根據 CPU、Mempry、disk 或網路效能預先定義的計劃自動增加或減少伺服器數量。

## IoT Services

IoT 是互聯網連接的物件（通常是硬體）所組成的網路能夠連接和交換資料。智慧冰箱、智慧燈泡等

**IoT Central**

IoT 裝置連接到雲端

**IoT Hub**

可以在 IoT 應用程式和管理設備之間實現高度安全和可靠的通訊

**IoT Edge**

基於Azure IoT Hub 構建的完全託管服務。允許讓數據處理分析人員靠近 IoT 設備。算是邊緣運算，將運算從雲端卸載到地端運算硬體，例如物聯網設備、手機或家用電腦。

**Windows 10 IOT Core Services**

這是一個雲端服務訂閱，提供在 Windows IoT 或 10 IoT Core 上商業化設備所需的基本服務。長期管理設備更新和評估設備運行狀況的支援和服務。

## Big Data and Analytics Services

*Big Data* 是用於描述大量結構化和非結構化數據，這些數據非常大，很難使用傳統資料庫和軟體技術進行移動和處理。

**Azure Synapse Analytics(以前稱為 SQL Data Warehouse)**

企業資料倉儲和大數據分析，目的是對大型資料庫*執行 SQL 查詢*，以產生報告等內容。

**HDInsight**

運行開源分析軟體，例如 Hadoop、Kafka 和 Spark。

>HD 是 Hadoop 縮寫

**Azure Databricks**

基於 Apache Spark 的分析平台，針對 Microsoft Azure 雲端服務平台進行了最佳化。

**Data Lake Analytics**

一種可簡化大數據的按需分析工作服務。資料湖(data lake)是一個儲存庫，以原始格式保存大量原始數據，直到需要為止

## AI/ML Services

**Azure Machine Learning Service**

一項可以簡化運行 AI、機器學習相關工作負載的服務，讓我們可以建立靈活的管道來自動化工作流程。

**Personalizer**  為每個使用人工智慧的用戶提供豐富的個人化體驗

**Translator** 將即時多語言文字翻譯添加至應用程式、網站和工具中

**Anomaly detector**  檢測異常和數據，以快速識別問題並排除故障

**Azure Bot Service**  可依需求擴充的智慧無伺服器機器人服務

**Form Recogniser** 自動從文件中提取文字鍵值對和表格

**Computer Vision** 針對獨特用例的輕鬆客製化電腦視覺模型

**Language Understanding** 將自然語言理解建置到應用程式、機器人和物聯網設備中

**QnA Maker** 根據現有的內容創建一個對話式問答機器人

**Text Analytics**  文字分析，從文字、內容審核器中提取情緒、關鍵字詞、命名實體和語言等訊息

**Content moderator**  文字和圖像進行審核，以提供更安全、更積極的使用者體驗

**Face** 人臉辨識和辨識影像中的人和情感

**Ink Recogniser** 辨識器會辨識數位墨水內容，例如手寫形狀和文件格式

## Serverless Services

伺服器是大規模*事件驅動*的。可以觸發服務功能，或觸發其他事件，使得可以編寫複雜的應用程式並進行擴充。

*Abstraction of Servers* 程式碼被描述為函數。這些函數可以在不同的計算實例上運行。

*Micro-Billing* 會按小時至少按秒計費



**Azure Functions**

用於運行稱為無伺服器的小程式碼。

**Blob Storage**

**Logic Apps**

允許構建由 Azure Functions 組成的無伺服器工作流程，為無伺服器計算構建一個狀態機。

**Event Grid**

 Pub/Sub 訊息傳遞系統可對事件做出反應並觸發其他 Azure 雲端服務，例如 Azure Functions。

## Azure Trust Center

只是一個面向公眾的網站門戶，提供對隱私、安全和監管合規資訊的輕鬆存取。

## Compliance Programs

企業不會購買你的軟體解決方案，除非它們是安全的。

如何滿足他們的安全合規性要求 ? 這就是 Compliance Programs 發揮作用的地方。

## Azure Active Directory

Azure Active Directory(Azure AD) 是 Microsoft 基於雲端的*身分識別和存取管理服務*，可協助員工登入和存取資源。

*External Resource(外部資源)* 可與 AD 整合，像是 Office 365、Azure Portal

*Internal Resource(內部資源)* 可與 AD 整合，如果網路中執行有應用程式或者可能正在使用 Azure Active Directory 來存取地端的工作站，可以實作單一登入。

Azure Active Directory 有四個版本
- Free
- Office 365 APP
- Premium 1
- Premium 2

## Multi-factor Authentication(MFA)

MFA 是一種安全控制，在填寫使用者名稱/電子郵件和密碼後，必須使用第二個裝置（手機等）來確認登入。MFA 可以防止有人竊取密碼，因為他們可能擁有你的密碼，但沒有你的手機或用於 MFA 的裝置。

## Azure Security Center

是一個統一的基礎設施安全管理系統。 它可以增強資料中心的安全狀況，並為雲端中的混合工作負載提供進階威脅防護。

## Key Vault

**Azure Key Vault** 可協助你保護雲端應用程式和服務所使用的加密金鑰和其他隱密資料。其具有許多功能，
- **Secrets Management** 儲存並嚴格控制像令牌、密碼、憑證、API 金鑰等
- **Key Management** 它可以創建和控制用於加密資料的加密金鑰
- **Certificate Management** 可以輕鬆地設定、管理和部署公用和私人 SSL 證書，以便與 Azure 和內部連接的資源一起使用
- **hardware security module** 隱密資料和金鑰可以透過軟體或 FIPS 140-2 Level2 驗證 HSM 進行保護

> HSM 是 Hardware Security Module，是一個設計用來儲存你加密金鑰的硬體

## Azure DDoS Protection

Azure 提供兩層 DDoS 保護

**DDoS Protection Basic**
- Free
- 它已經開啟了。 它保護所有 azures 全球網路

**DDoS Protection Standard**
- 一個月可能要 $2994
- Metrics, Alert, Reporting
- DDoS 專家支援
- 應用程式和成本保護 SLAs

## Azure Firewall

一種基於雲端的託管網路安全服務，可以保護你的 Azure 虛擬網路資源。

**Azure Firewall Features**
- 跨訂閱和虛擬網路集中建立、實施和記錄應用程式和網路連接策略
- 訂閱（多個帳戶）對虛擬網路資源使用靜態*公有 IP 位址*，允許外部防火牆識別源自虛擬網路的流量
- 內建高可用性，*無需額外費用*，不必建立負載平衡器並自行完成所有工作
- 可以在部署時配置它跨多個 AZ，這樣就具有高可用性
- 部署在可用區域(availability zone)中的防火牆無需額外費用
- 入站和出站資料傳輸會產生額外成本，與 AZ 關聯
  
## Azure Information Protection (AIP)

其作用是保護敏感訊息，例如加密的電子郵件或文件。它根據權限限制存取，它直接整合到 Office 應用程式中。

## Application Gateway

他是一個應用程式負載平衡器，由於它處理的是 HTTP 請求，可以建立規則將流量路由至其他地方。並且可以與 WAF(Web Application Firewall) 整合保護第七層資源。

我們可以設定規則，就像設定網路路由規則一樣，可以設定有關哪些內容應該能夠流入和流出此負載平衡器的安全規則。

## Azure Advanced Threat Protection (ATP)

**IDS/IPS** 它是一項監視網路或系統是否存在惡意活動或政策違規的技術。

ATP 是一種基於雲端的安全解決方案，它利用本機 Active Directory 訊號來識別、偵測和調查針對組織的進階威脅、受損身分和惡意洞察操作。

##  Microsoft Security Development Lifecycle (SDL)
- an industry-leading software security assurance process.

將安全性建置到開發生命週期的每個 SDL 階段可以幫助更早發現問題。它可以幫助降低開發成本。

## Azure Policies

- 是一種可用於建立、指派和管理策略的服務。策略允許強制執行或控制資源的屬性
- 透過將資源的屬性與業務規則進行比較來評估 Azure 中的資源。這些以業務規則 JSON 格式描述的業務規則稱為*策略定義*。


## [Role Based Access Control RBAC](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview)

幫助管理誰有權存取資源，可以使用這些資源做什麼以及他們有權存取哪些區域。

**Role Assignments(角色分配)** 控制資源存取的方式。角色分配由三個要素組成
1. 安全原則(Security Principal)
2. 角色定義(Role definition)
3. 範圍(scope)

**安全原則(Security Principal)** 代表請求存取 Azure 資源的身份。這就是想要存取權限的人，可以擁有一個

- 用戶(User)
  - Azure Active Directory 中的個人設定文件
- 群組(Group)
  - Azure Active Directory 中擁有一組用戶
- 服務主體(Service Principal)
  - 這是應用程式或服務使用的安全性身分來存取特定的 Azure 資源
- 託管身分(Managed identity)
  - Azure Active Directory 中由 Azure 自動管理的身份
 
**範圍(Scope)** 這是角色分配將被授予存取權限的資源集。範圍界定實際上是在管理、訂閱或資源群組層級進行的。

![](https://learn.microsoft.com/en-us/azure/role-based-access-control/media/overview/rbac-overview.png) 

**角色定義(Role definition)** 

是權限的集合，策略(可以想成是 Azure Policies)就是權限。其列出了可以執行的操作，例如讀取(read)、寫入(write)和刪除(delete)。角色可以是高層級的（如擁有者），也可以是特定的（如虛擬機器讀取者）

## Lock resources

作為管理者，你可能需要鎖定某個訂閱資源群組或資源，以防止其他使用者不小心讓*其他使用者刪除或修改關鍵資源*。

**canNotDelete(Delete)**  這種授權這將允許授權用戶仍然可以讀取和修改資源，但不能刪除資源。

**ReadOnly** 使用者可以讀取資源，但不能刪除或更新資源。

## [Management Groups](https://learn.microsoft.com/zh-tw/azure/governance/management-groups/overview)

是一種管理多個訂閱的方法。 

每個 directory 都有一個稱為 Root 管理群組的頂層管理群組。管理群組內的所有訂閱都會自動繼承套用於該管理群組的條件。

![](https://learn.microsoft.com/zh-tw/azure/governance/media/mg-org.png)

## Azure Monitor

一個全面的解決方案，用於從雲端和本地環境收集、分析遙測資料並採取行動。

## Service Health

有關當前即將出現的問題的信息

- 影響服務的事件
- 計劃維護
- 可能影響可用性的其他更改

1. **Azure Status**，通知你 Azure 中的服務中斷
2. **Azure service health**  正在使用的 Azure 服務和區域的運作狀況的個人化視圖
3. **Azure resource health** 有關單一雲端資源（例如 VM）運作狀況的資訊


## Azure Advisor

個人化的雲端顧問，可協助遵循最佳實務來最佳化 Azure 部署。其儀表板顯示
- 高可用性
- 安全性
- 效能
- 成本
- 卓越營運

## Service Level Agreements

Service Level Agreements(SLA) 代表服務等級，體現了 Azure 對正常運作時間和連結性的承諾。舉例，如果有一個 Web 伺服器，Azure 會說，是的，我們保證 99.9% 的時間它會全年保持運行，不會出現故障。

Azure SLA 背後的想法：每個 Azure 服務都單獨自訂 SLA。正常運作時間和連接性被描述為效能目標，目標只是以百分比形式表示。

## Service Credits

客戶的 Azure 帳單可能會享有折扣，作為基於 SLA 表現不佳的 Azure 產品或服務的補償。

## Composite SLAs

服務有不同的 SLA。Composite SLAs(複合 SLA) 是指將不同服務產品的 SLA 組合起來。

## TCO Calculator

估算可以透過將工作負載遷移到 Azure 來實現的成本節省。產生詳細的報告並將其匯出為 PDF 發送給決策者。


## Azure Marketplace

是第三方發布商提供的應用程式和服務供快速開始使用在 Azure 上。可用的應用程式和服務中的可用應用程式可以是免費的、免費試用版、付費，或者許可證。 

## [Azure Support](https://azure.microsoft.com/en-us/support/plans)

## Azure Licensing (Azure Hybrid Benefit)

## Azure Subscriptions

Azure 訂閱描述為相當於 Azure 帳戶，有 4 個等級
- Free Subscription
- Pay-As-You-Go Subscription
- Enterprise Subscription
- Student Subscription

## [Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)

估算Azure產品的成本，無需登入即可使用此工具。可以做的就是下載 Excel 並與老闆分享這些費用。

## Azure Cost Management

允許執行成本分析，可以視覺化 Azure 雲端資源的支出，但也可以在服務下建立預算，當設定預算時，將定義一個閾值當接近或超過該閾值時，將收到警報。 
