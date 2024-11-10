## public / private networkiing
## Data Protection
## Encryption
## Blob、Files、Queue、Tables
## Access Keys and SAS
## Stored Access Policies
## Redundant Storage
- LRS
- GRS
 - 進行 Failover 時會降為 LRS，有機會有資料遺失
- RA-GRS
 - 兩個端點，一個讀寫、一個讀
## Access Tiers
- Perfoemance
  - Standard
  - Premium
    - low latency
- Blob Storage Access tier
 - Hot
 - Cool
 - Cold
 - Archive
   - Blob inaccessable
  
## Entra ID Access Control for Storage
將 `account key access` 關閉，則 SAS 將會被拒絕使用。此時可以使用 `Entra authorization` 方式，這可基於 Access Control (IAM) 方式設定。

## File Shares Snapshots
Snapshots 沒有過期期限，而軟刪除則有。

## Blob Storage Versioning
- keep all version
 - 儲存的量會較大
 - 檢索相對會有延遲
- Delete version aftet

- Lifecycle management
 - 針對版本
   - move to cool、cold etc
   - delete
