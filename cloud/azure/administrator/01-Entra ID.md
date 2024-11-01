Microsoft Entra ID（前稱 Azure Active Directory）是 Microsoft 提供的雲端身分識別和存取管理服務。它協助組織管理並保護員工、合作夥伴和客戶的身分識別，確保他們能安全地存取所需的應用程式和服務。 
微軟

主要功能包括：

單一登入（SSO）：使用者可透過單一帳戶存取多個應用程式，提升使用體驗並減少密碼管理的負擔。

多重要素驗證（MFA）：在登入過程中要求額外的驗證步驟，增強安全性。

條件式存取：根據使用者、位置、裝置等條件設定存取原則，控制對資源的存取權限。

身分識別保護：偵測並回應可疑的登入活動，保護組織的安全。

自助式密碼重設：允許使用者自行重設密碼，減少對技術支援的依賴。

此外，Microsoft Entra ID 還提供應用程式整合、裝置管理、身分識別治理等功能，協助組織在混合和多雲環境中有效管理和保護身分識別。

![microsoft | 什麼是 Microsoft Entra ID](https://learn.microsoft.com/zh-tw/entra/fundamentals/whatis)

![microsoft | microsoft-entra-id](https://www.microsoft.com/zh-tw/security/business/identity-access/microsoft-entra-id)


Microsoft Entra ID 提供三種版本：Free、Premium P1 和 Premium P2。各版本的功能差異如下：

1. Microsoft Entra ID Free

使用者和群組管理：基本的使用者和群組管理功能。
內部部署目錄同步：可與內部部署的 Active Directory 進行同步。
基本報告：提供基本的使用者登入和活動報告。
自助式密碼變更：雲端使用者可自行變更密碼。
單一登入（SSO）：跨 Azure、Microsoft 365 和許多熱門 SaaS 應用程式提供單一登入功能。

2. Microsoft Entra ID Premium P1

除了 Free 版的功能外，P1 版還提供：

混合式使用者存取：允許混合式使用者同時存取內部部署和雲端資源。
進階管理功能：包括動態群組成員資格、自助群組管理和 Microsoft Identity Manager。
自助式密碼重設：內部部署使用者可自行重設密碼，並支援雲端回寫功能。

3. Microsoft Entra ID Premium P2

在 P1 的基礎上，P2 版進一步提供：

身分識別保護：透過 Microsoft Entra ID Protection，協助偵測和回應身分識別相關的風險。
特殊權限身分識別管理：透過 Privileged Identity Management，協助發現、限制和監控系統管理員的存取權，並提供即時存取功能。
這些版本的功能差異旨在滿足不同組織的需求，從基本的身分識別管理到進階的安全性和治理功能。

![microsoft | microsoft-entra-pricing](https://www.microsoft.com/zh-tw/security/business/microsoft-entra-pricing)

## Managing Multiplle Directories

- Account
  - Person (User name、Password、multi-factor)
  - App - Managed Identity (program or service)
- Tenant
  - organization 概念。是 Azure Active Directory (Azure AD) 的實例，代表一個組織或公司，並且以獨立的目錄形式存在，用於管理該組織內的所有使用者和應用程式。
  - 表是一個公開域名 (example.com)
  - 一個 Account 至少是一個 tenant 下一部分  
- Subscription
  - 與 Microsoft 簽訂的使用 Azure 服務的協議，以及如何支付費用。用來管理、組織和計費 Azure 資源的容器。它包含特定配額的 Azure 資源並綁定計費機制。
    - Free
    - Pay as you go
    - Enterprise agreements
  - 並非每個 Tenant 都需要一個訂閱
  - 一個 Tenant 可以有多個訂閱(建立資源時將會選擇哪個訂閱)
  - 一個 Tenant 中可以有多個 Account 的擁有者
- Resource Group
