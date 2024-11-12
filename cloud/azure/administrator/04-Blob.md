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
  
## Log Analytics
- 設定 Alert (用量大於 10 GB) 等
- 延遲
- 將 Blob write/Read/Delete/Transaction 等紀錄，並發送至 Log Analytics、Storage Account Archive、event hub 等

## Manage data in Azure storage
- import/export jobs
- azCopy
- storage browser

## Azure files
- Azure file sync
 - 地端可以下載該服務並與雲端 azure file sync 資源同步
- Premium Storage
 - Block blobs
 - PAge blobs
   - 比 Blocl blobs 大
   - 用於儲存不須頻繁訪問或修改的檔案
  - File share
  - 會沒有 GRS 等級的冗於 
