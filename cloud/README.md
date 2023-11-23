## Cloud Computing
**Dedicated Server**

一個實體機器，服務一個業務，可能運行一個網站或是其它應用程式。

*昂貴*、*維護成本高*、*高安全性*

**Virtual Private Server**

一個實體機器，服務一個業務。其實體機器可以虛擬化多個子機器，這表示可以運行多個網站或是其它應用程式。

**Shared Hosting**

一個實體機器，共享給數個企業。多個租戶共享這些資源。

*便宜*、*有限制*

**Cloud Hosting**

多個實體機充當一個系統。該系統被抽象化多個雲服務。

*靈活性*、*可擴展*、*安全*、*成本效益*、*高度可配置*

## Cloud Services

雲提供數個不同類型的服務，但主要有四種類型：

- Compute
  - 虛擬電腦，可以運行應用程式、程式等
- Storage
  - 儲存檔案的虛擬硬碟的地方
- Networking
  - 虛擬網路能夠定義網路連線或網路隔離
- Databases
  - 儲存網頁應用程式資料的地方

> Cloud Computing 所泛指的意涵是可以包含上述所提到的概念

## Benefits of Cloud Computing

**Cost-effective(成本效益)** 

為你消費的東西付費，沒有前期上的成本，隨付隨用。這成本會與很多的使用者共同分享。

**Global(全球化)**

在世界任何地方都可啟動工作負載，只需選擇所在的區域

**Secure(安全)**

雲供應商負責硬體上的安全。或者可以設定細粒度的存取權限。

**Reliable(可靠)**

資料備份、災難復原、資料副本與容錯

**Scalable(擴展)**

根據需求增加或減少資源和服務

**Elastic(彈性)**

高峰期間自動進行縮放

**Current(最新的)**

硬體底層和軟體由雲供應商進行修補與更換


## Type of Cloud Computing

**Saas software as a Service**

這是一個由服務提供者運作和管理的產品。不用在意服務如何維護，且它可以正常工作並保持可用。像是 Gmail、Office 365 等

**PaaS Platform as a Service**

專注於應用程式的開發和管理。無須擔心配置、如何供應或了解硬體等問題。像是 Beanstalk、Heroku 等。

>開發人員可以輕鬆在雲端上建立應用程式，而無需擔心底層的所有內容

**IaaS Infrastructure as a Service**

雲端 IT 的基本構建模組。提供對網路功能、運算和資料儲存空間的存取。無需擔心 IT 人員、資料中心和硬體。像是 Azure、AWS、GCP

## Types of Cloud Computing Responsibilities

**On-Premise**

| Customer/ Cloud Service Provider (CSP) | Level |
|---|---|
|Customer|Application|
|Customer|Data|
|Customer|Runtime|
|Customer|Middleware|
|Customer|OS|
|Customer|Virtualization|
|Customer|Servers|
|Customer|Storage|
|Customer|Networking|


**Infrastructure as a Service**

| Customer/ Cloud Service Provider (CSP) | Level |
|---|---|
|Customer|Application|
|Customer|Data|
|Customer|Runtime|
|Customer|Middleware|
|Customer|OS|
|CSP|Virtualization|
|CSP|Servers|
|CSP|Storage|
|CSP|Networking|

**Platform as a Service**

| Customer/ Cloud Service Provider (CSP) | Level |
|---|---|
|Customer|Application|
|Customer|Data|
|CSP|Runtime|
|CSP|Middleware|
|CSP|OS|
|CSP|Virtualization|
|CSP|Servers|
|CSP|Storage|
|CSP|Networking|

**Software as a Service**

| Customer/ Cloud Service Provider (CSP) | Level |
|---|---|
|CSP|Application|
|CSP|Data|
|CSP|Runtime|
|CSP|Middleware|
|CSP|OS|
|CSP|Virtualization|
|CSP|Servers|
|CSP|Storage|
|CSP|Networking|

## Deployment Models

**Public Cloud**

所有東西都是使用雲供應商所提供的服務

**Private Cloud**

服務都是來自地端，像是使用 *OpenStack*，這屬於 *On-premise*

**Hybrid**

公有雲與私有雲整合

**Cross-Cloud**

使用多個雲供應商，混合雲。
像是透過 Azure ACR 將其容器部署至 EKS 或是 GKE

## Cloud Architecture Terminologies

**Availability**

確保服務保持可用的能力，通常稱為 *Highly Available(HA)*

**Scalability**

能夠快速或不受阻礙的擴張

**Elasticity**

收縮和成長以滿足需求的能力

**Fault Tolerance**

防止故障的能力

**Disater Recovery**

可以進行災難復原，從不可用的環境中恢復的能力，也可稱為 *Highly Durable(DR)*


## High Availability

運行的應用程式跨多個 *Availability Zones*，確保某個 AZ 發生問題時，還能保持運作。

透過 **Azure Load Balancer** 可以幫我們對多個 AZ 進行附載均衡，其可以將流量均勻分配到一個或多個資料中心的多台伺服器，資料中心或伺服器變得不可用且運作狀況不佳，負載平衡器僅將流量路由到具有伺服器的可用資料中心


## High Scalability

根據記憶體和運算能力不斷增長的需求來增加硬體資源容量的能力。調高記憶體或是 CPU 等。主要有兩種擴展方式

- Vertical Scaling (Scaling Up)
  - 更新更大的伺服器
- Horizonal Scaling (Scaling Out)
  - 增加相同規格機器
 
## High Elasticity

根據記憶體和運算能力的需求自動增加或減少資源的能力，與 *Scalability* 不同的是這是*自動化*的。

- Horizonal Scaling
  - Scaling Out
  - Scaling In
 
## High Durability

避免資料遺失，且可以進行復原。

- 有進行備份 ?
- 能多快復原
- 備份都是持續在運作 ?
- 如何確保目前的即時資料不會被損壞 ?

## The Evolution of Computin

dedicated -> VM -> Containers -> Functions

**dedicated**

- 實體機器，完全由單一客戶使用
- 要規劃資源，避免超出預算對於浪費資源
- 更新是昂貴的
- 被作業系統限制
- 多個服務被安裝至同一個服務器上，在資源共享上可能會有衝突

**VM**

- 可以從一台伺服器上運行多個虛擬機器，用於實際運行虛擬機的技術被稱為 *Hypervisor*
- 共享實體機具有多個客戶的伺服器，這通常是一件好事，只需支付伺服器成本的一小部分
- 仍然會為未充分利用的伺服器資源而支付過高的費用
- 將受到 *Guest Operating System* 的限制
- 多個服務被安裝至同一個虛擬機上，在資源共享上可能會有衝突

**Containers**

- 虛擬機運行多個容器
- 容器運行使用 Docker Deamon 等軟體實現
- 可以最大限度的使用資源
- 容器共享底層作業系統，因此比虛擬機更有效率

**Functions**
- 一個託管虛擬機器管理運行容器
- *Serverless Compute(無伺服器運算)*
- 上傳程式碼並選擇運行的記憶體和時間
- 只對程式碼和資料負責
- 冷啟動，當它們不運行時，就沒有運行


## Regions and Geographies
- 一個區域(region)是多個資料中心的分組 (Availability Zones)
- 地理位置(Geographies)，是一個由兩個或多個區域(region)組成的，這些區域保留資料駐留(data residency)和合規性(compliance boundaries)

Geographies 位置
- United States
- Canada
- etc.

## Paired Regions

每個 Azure 區域都與同一地理位置內的另一個區域配對，共同構成區域對。某些 Azure 服務會依賴配對區域進行災難復原。

|Country| Region |Paired Region|
|---|---|---|
|Canada|East US|West US|
|North America|East US|West US|
|Germany|Germany Central|Germany Northeast|

Azure Geo-redundant Storage(GRS) 是一個例子，可以自動將資料複製到次要區域確保資料足夠可用。

## Availability Zone

- *Availability Zone(AZ)* 由一個或多個資料中心組成的實體位置
- 一個區域(Region) 通常有 3 個 AZ

## Fault and Update Domains

Azure 區域中 *Availability Zone(AZ)* 是 *fault domain* 和 *update domain* 的組合。

**Fault Domain**
fault domain 是硬體的邏輯分組，以避免可用區內出現單點故障。基本上，它是一組共享公共電源和網路交換器的虛擬機器。

這樣做的原因是，如果資料中心的一部分發生故障，那麼其他伺服器將被關閉，比方說，資料中心和一個特定區域內發生火災，它不會影響其他硬體正在運行，那麼就可以 *update domain* 。

**Update Domain**

指 Azure 需要將更新套用到底層硬體和軟體時。問題是，由於 Azure 正在更新它們，它會使這些電腦離線。


**Availability Set**

所以，*fault domain* 和 *update domain* 的工作方式是使用 *Availability Set*。*Availability Set* 是一個邏輯分組，可以在 Azure 中使用它來確保放置在 *Availability Set* 中的 VM 位於不同的故障 *Update Domain*，以避免停機。
