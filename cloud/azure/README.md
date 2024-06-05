## Key Vault
- 整合 Kubernete Secret Store CSI
## [logic app](https://learn.microsoft.com/zh-tw/training/modules/intro-to-logic-apps/)
- 實作透過 office365 寄送郵件(Send_an_email_(V2))，整合 Python
- 建置 office365 服務的 Api connections
## [Azure Private Link](https://learn.microsoft.com/zh-tw/training/modules/introduction-azure-private-link/)
- 連線是單向的，這表示只有用戶端可以連線至私人端點介面。 如果某個 Azure 服務對應至私人端點介面，該服務的提供者就無法連線至 (甚至無法感知) 私人端點介面
- Private Link 可將私人端點對應至 Azure 資源的單一執行個體，藉以降低資料遭到外流的風險
- Azure Private Link 包含兩個不同服務
  - Private Endpoints 
  - Private Link Services

**知識檢查**
1. 假設公司想要讓其 Azure 虛擬網路中的用戶端能對特定 Azure 資源進行安全且非公用的存取。 IT 人員應將下列哪一項技術新增至其虛擬網路？`Azure private endpoint`
2. 假設公司想要讓使用者能透過 Azure 虛擬網路對 Azure 資源進行私人存取。 Azure 私人端點如何對應 Azure 資源以提供私人存取？ `藉由使用來自 Azure 虛擬網路之子網路的 IP 位址。`
3. 假設公司想要讓使用者能透過 Azure Private Link 服務對自訂 Azure 服務進行私人存取。 下列何者是實作 Private Link 服務所需的技術？ `Azure Standard Load Balancer`
 
**其它文章**
- [medium | demystifying-azure-private-link-private-endpoints-and-service-endpoints](https://medium.com/@mbnarayn/demystifying-azure-private-link-private-endpoints-and-service-endpoints-7b309ba96fa1)
- [opstergo | private-link](https://www.opstergo.com/blog/azure-private-link-private-link-service-private-endpoint-virtual-network-service-endpoint-what-is-the-difference)
