Kafka  是一個開源的分散式事件平台(Event Streaming Platform)，數據集成、數據管道、流分析等。

## 應用場景
- 緩衝 : 控制和優化數據經過系統的速度，解決生產和消費訊息處裡不一致情況
- 解偶 : 允許你獨立擴展或修改兩邊的處理過程，並確保能夠遵循相同介面約束
- 異步通訊 : 允許使用者把一個訊息放入隊列，*不立即處理它*，需要時在處理


## 訊息隊列模式
1. 點對點模式
- 消費者主動拉取數據，訊息收到後清除訊息

![image](https://user-images.githubusercontent.com/17800738/172054427-c6f63644-08b2-4327-9e42-30aa471a4850.png)

2. 發布/訂閱模式
- 可以有多個 topic 主題
- 消費者消費後，不刪除數據
- 每個消費者獨立，都可以消費到數據

![image](https://user-images.githubusercontent.com/17800738/172054324-7140ec88-e639-4f12-8f0e-1419fd9b2352.png)

## Kafka 架構

![](https://i.imgur.com/uOo5OlD.png)

1. 為了方便擴展，提高吞吐量，一個 topic 分為多個 partition
2. 配合分區(partition)的設計，提出消費者組概念，每個組內的消費者併行消費
3. 為提高可用性，為每個 partition 增加多個副本

- Producer
    - 消息生產者，發送消息到 kafka 的客戶端
- Consumer
    - 消費者，向 kafka 取消息的客戶端
- Topic
    - 一個隊列
    - 綠色區塊顯示出隊列形式
- Cunsumer Group(CG)
    - 增加消費能力，多個消費者取數據，增加效率，最後只要全部合起來就是全部的數據
    - Kafka 是以消費組概念
    - 一個 topic 可有多個 CG
- Broke
    - kafka 的一台機器
- Partion
    - 實現擴展性，一個大的 topic 可分配到多個 broker 上
    - 每個 partion 是一個有序隊列
- Leader 負責接收讀寫；Follower 則是備份數據
  - Leader 會被 producer、consumer 消費
- Zoopkeeper 
    - 儲存群集訊息
    - 消息隊列訊息，紀錄消費者消費的數據，可以避免重新消費
## Kafka 分區好處
1. 合理使用儲存資源，每個 Partition 在一個 Broker 上儲存，可把大量數據按照分區切割成一塊一塊數據儲存在多台 Broker 上。合理控制分區的任務，可以有*負載均衡*效果。
2. 提高並行度，生產者可以以分區單位發送數據；消費者可以以分區為單位進行消費數據

下圖表示有 100T 資料，切成三塊，每塊都 33GB 並對應每個 broker。每個 Broker 都有自己的儲存空間，適當的分配資源可有。
![image](https://user-images.githubusercontent.com/17800738/177004744-102d01fb-b091-4e8a-8800-c1f88e33cf3c.png)

1. 直接指明 partition 位置寫數據
2. 透過 key 的 hash 值與 topic 的 partiotion 數量取餘數來獲取要存取數據的 partiotion 位置
3. 上述兩者都沒有，會採用 `Sticky Partition` 隨機選分區儲存，並盡可能使用該分區，待該分區 batch 滿(預設 16k)或是 `linger.ms` 時間到，kafka 在隨機一個分區使用(和上次的分區不同)

## 生產者提高吞吐量

![image](https://user-images.githubusercontent.com/17800738/177021013-07307858-4b29-4a33-8a96-dbc872e2d7bf.png)

`linger.ms` 預設下是 0，所以只要倉庫有物件，火車就開始拉，一次拉一個。`batch.size` 在 `linger.ms` 預設下是不起作用。Kafka 預設情況下是一次拉一個。

![image](https://user-images.githubusercontent.com/17800738/177021103-0242dfbe-b7d7-4700-84c9-6a80da6c0d75.png)

如果將 `linger.ms` 設置 5~100 ms，`batch.size` 為 16k。就可以如上圖所示，火車每一批次拉 `batch.size` 設置的上限，這樣就可以提高效率。但是並非 `linger.ms`、`batch.size` 設置越高越好，因為這樣會導致延遲出現，在這場景假設 `linger.ms` 為 1s 那在火車上的物件要等待 1s 才能被送達到目的，相對於 kafka 預設情況下要來的低效。假設我們對數據進行 `compression.type` 也就是壓縮，這樣火車拉走的物件相對又變多了。


- batch.size 預設 16kb
- linger.ms 預設 0
    - 等待時間
- compression.type 壓縮 snappy
- RecordAccumlator 緩衝區大小  

## 數據可靠
當數據發送至 Kafka Cluster 中後，可以透過應答方式來確保數據是否被處理，在 Kafka 中可以透過 `acks` 字段
- 0 生產者發送給 Broker 的數據，不須等待數據寫入硬碟後回覆
- 1 生產者發送給 Broker 的數據，Leader 收到數據後回覆
- -1 生產者發送給 Broker 的數據，Leader+ 和 isr 隊列裡面的所有節點收齊數據後回覆
- all 等價於 `-1`

### acks is 0
生產者發送給 Broker 的數據，不須等待數據寫入硬碟後回覆

![image](https://user-images.githubusercontent.com/17800738/177025990-4f2969c2-77ef-458a-804f-0a8f6347ece2.png)

假設 Leader 死掉後，整個數據都丟了。

**可靠性差，但效率高**

### acks is 1
生產者發送給 Broker 的數據，Leader 收到數據後回覆

![image](https://user-images.githubusercontent.com/17800738/177026066-923ce48a-393c-4edb-ace4-447992061ac4.png)

Follower 尚未同步也沒關係。但如果在 `ack` 完成後，尚未與 Follower 進行同步，此時 Leader 死了。雖然機制會重 Follower 選新的 Leader，但因為尚未同步，新 Leader 不會有上圖的 world 訊息，生產者也因為收到 `ack` 也認為訊息發送成功。

**可靠性中，但效率中**
### acks is -1 or all

生產者發送給 Broker 的數據，Leader+ 和 isr 隊列裡面的所有節點收齊數據後回覆

![image](https://user-images.githubusercontent.com/17800738/177026278-ac762a6e-e54d-4f3e-b201-ffbf92f587ea.png)

在與 Fllower 同步數據時，一個 Follower 突然故障，遲遲不能和 Leader 同步，這要怎解決 ?
Leader 維護一個動態的 in-sync replica set(ISR)，表示和 Leader 保持同步的 Follower 加 Leader 集合(ex. leader:0, isr:0,1,2)。

如果 Follower 長時間未與 Leader 發送通訊請求或同步訊息，則 Follower 將被踢出 ISR。可以由 `replica.lag.time.max.ms` 參數設置時間，預設 30s。

>(ex. leader:0, isr:0,1,2) 對應上圖 0 表示 Leader，1 和 2 各別表示一個 Follower

如果分區副本設置為 1，或 ISR 裡回覆最小副本數量為 1 (min.insync.replicas 預設為 1)，這樣會等同於 ack 為 1 的效果。

**要做到完全可靠 = ACK 設置 -1 + 分區副本大於等於 2 + ISR 裡回覆最小副本數量大於等於 2**
**可靠性高，但效率低**

假設在回覆 ack 時，Leader 死了(數據都已經同步)，此時 Follower 挑選出一個 Leader，因為沒有 ack 回覆生產者在發送一次訊息，此時會產生*數據重複問題*。

## 數據去重
- At Least Once 
    - ack 設置為 -1 + 分區副本大於等於 2 + ISR 裡回覆的最小副本大於等於 2
    - 可以保證數據不丟失，但不能保證數據不重複
- At Most Once 
    - ack 設置為 0
    - 可以保證數據不重複，但不能保證數據不丟失
- Exactly Once
    - 要求數據不重複且不丟失
>透過冪等性和事務的方式來解決數據重複性

### 冪等性
冪等性是指生產者(producer)不論向 Broker 發送多少次重複數據，Broker 只會持久化一次該數據，保證不重複。

Exactly Once = 冪等性 + At Least Once 

**重複數據判斷標準**: 具有相同 `<PID,Partition,SeqNumber>` 相同主鍵訊息提交時，Broker 只會持久化一條。因此*冪等性只能保證在單分區單會話(Kafka 的 PID)內不重複*。下圖為範例，紫框數據是重複的因此，他會在記憶體中被移除

![image](https://user-images.githubusercontent.com/17800738/177030804-387b609f-ae5f-401a-a448-4099d70d28d4.png)

>enable.idempotenc 是設置冪等性參數預設是 true

### Kafka 事務
如果單以冪等性是不夠的，假設 kafka 掛掉在重啟還是會有重複數據的可能。如果不想產生重複數據只能用事務方式。因此**開啟事務，必須開啟冪等性**

![image](https://user-images.githubusercontent.com/17800738/177032150-e967fc27-47d8-44d0-99da-6cccd002d9c2.png)

事務協調器，每個 Broker 都有我們要如何知道誰要處裡 ? 會根據 `__Transaction_state-partition-Leader` 主題，預設有 50 個分區，每個分區負責一部分事務。事務的劃分是根據`transactional.id` 的 hashcode%50，計算該事務屬於哪個分區。該分區 Leader 副本所在的 broker 節點即為這個 `transactional.id` 對應的 `Transaction Coordinator` 節點。

`transactional.id` 是客戶端提供的全域唯一值。Producer 在使用事務功能前必須自定義唯一 `transactional.id`。這樣即使客戶端掛了，他重啟後也能繼續處裡未完成的事務。

>Transaction Coordinator 事務協調器(每個 Broker 都有)；__Transaction_state-partition-Leader 儲存事務訊息的特殊主題

### 數據有序
### 數據亂序

# Kafka Broker
### kafka 副本
提高數據可靠性。預設為 1 個副本，太多副本會增加硬碟空間，增加網路數據傳輸，降低效率。Kafka 副本分為 *Leader*、*Follower*，生產者只會把數據發往 Leader，然後 Follower 找 Leader 同步數據。

Kafka 分區中的所有數據副本稱為**AR(Assigned Replicas)**。
> AR = ISR + OSR

ISR，表示和 Leader 保持同步的 Follower 集合。如果 Follower 長時間未向 Leader 發送通訊請求或同步數據，則該 Followe 將從 ISR 移除，該時間閥值由 `replica.lag.time.max.ms` 參數決定，預設 30 秒。Leader 發生問題，會從 ISR 中選新的 Leader。

OSR，表示 Follower 和 Leader 副本同步時，延遲過多的副本。

### Follower 故障處理細節
**LEO(Log End Offset) 每個副本的最後一個 offset，LEO 就是最新的 offset + 1**
**HW(High Watermark) 所有副本中最小的 LEO**

Leader 因為負責和生產者、消費者進行交互，而其它 Follower 都是和 Leader 進行數據同步。也因為 Leader 先接收數據所以資料比較多。ISR 中表明目前三台服務是正常啟動。而消費者最大能看到的數據是 `HW`。

![image](https://user-images.githubusercontent.com/17800738/178088203-0fa0b592-5142-4c5d-a9ed-91722973abbe.png)

1. Follower 故障
1.1 Follower 發生故障會被臨時踢出 ISR
1.2 該期間 Leader 和 Follower 持續接收數據
1.3 待該故障 Fopllowe 恢復後，Followe 會讀取本地硬碟紀錄的上次的 HW，並將 Log 檔案高於 HW 部分截掉，從 HW 開始向 Leader 同步
1.4 等該 Follower 的 LEO 大於等於該 Partition 的 HW，即 Follower 追上 Leader 後，即可重新加入 ISR

1. Leader 故障
1.1 Leader 發生故障後，從 ISR 中挑選一個新的 Leader
1.2 為保證多個副本之間的數據一致性，其餘的 Follower 會先將各置的 log 檔案高於 HW (新的 Leader)的部分截掉，接著重新的 Leader 同步數據

>在 Leader 故障中的 1.2 這只能保證副本之間數據一致性，並不能保證數據不丟失或不重複

### 分區副本分配
盡量按照均勻分配，以實現合理的附載均衡
### 手動調整分區副本
### Leader Partition 自動平衡
`auto.leader.rebalance.enable` 預設為 true，Leader Partition 自動平衡。
`leader.imbalance.per.broker.percentage` 預設 10%，每個 Broker 允許不平衡的 leader 的比率。如果每個 Broker 超過此值，控制器會觸發 Leader 的平衡。
`leader.imbalance.check.interval.seconds` 預設是 300 秒，檢查 Leader 附載是否均衡的間隔時間。
### 增加副本因子

## 檔案儲存
Topic 是邏輯上的概念，而 Partition 是物理上的概念，*每個 partition 對應於一個 Log 檔案*，該 Log 檔案中儲存的就是 Producer 生產的數據。*Producer 生產的數據不對被追加到該 Log 檔案末端*，為防止 Log 檔案過大導致數據定位效率低下，Kafka 採取了*分片*和*索引*機制，將每個 *partition 分為多個 segment*。每個 segment 包含，`.index` 檔案、`.log` 檔案和 `.timeindex` 等檔案。這些檔案位於一個資料夾下，該資料夾名稱規則是 `topic + 分區號碼`

![image](https://user-images.githubusercontent.com/17800738/178090616-dced250d-4149-4769-b4d2-3ca86073a42f.png)

> index 為稀疏索引，大約每往 log 寫入 4kb 數據，會往 index 檔案寫入一條索引。`log.index.interval.bytes` 預設為 4kb

### 檔案清除策略
Kafka 預設 Log 保存時間為 7 天，可以透過以下調整
- log.retention.hours 最低優先級，預設 7 天
- log.retention.minutes 分鐘
- log.retention.ms 毫秒，最高優先級別
- log.retention.check.interval.ms 檢查週期，預設 5 分鐘

Kafka Log 清除策略有 `delete`、`compact` 兩種

1. delete 刪除，將過期數據刪除
- log.cleanup.policy = delete 所有數據啟用刪除策略
**基於時間，預設是開啟**。以 `segment` 中所有紀錄中的最大時間戳作為該檔案時間戳(timeindex)
**基於大小，預設為關閉**。超過設置的所有 Log 總大小，刪除最早的 segment。`log.retention.bytes` 預設 `-1`。

2. compact 壓縮
- log.cleanup.policy = compact 

## 高校讀寫數據
1. kafka 本身分散式集群，可以採用分區技術，併行度高
2. 讀數據採用稀疏索引，可以快速定位要消費的數據
3. 順序寫硬碟，即讀寫頭不必定位
4. Page Cache 和 Zero-copy 技術

![](https://twitter.com/alexxubyte/status/1506663791961919488)

Zero-copy: Kafka 數據加工處理操作交給 kafka 生產者和消費者處理。**kafka Broker 應用層不關心儲存的數據，所以就不走應用層，相對傳輸效率提升**。
Page Cache: Kafka 依賴 OS 提供的 Page Cache 功能。當上層有讀寫時，OS 只是將數據寫入 Page Cache。當讀操作發生時，先從 Page Cache 查找，如果不存在，再從硬碟讀取。實際上 Page Cache 是把盡可能多的空閒記憶體當作了硬碟緩存來使用。

## Kafka 消費方式
1. pull 模式 consumer 採用從 Broker 中主動拉取數據。
2. push 模式 Kafka 沒有採用此方式，因為 Broker 決定發送訊息速率，很難適應所有消費者的消費速率

## kafak 消費者工作流程

![image](https://user-images.githubusercontent.com/17800738/178096551-67f65920-7e57-44c1-8c68-19287f49ea38.png)

1. 每個消費者的 offset 由消費者提到系統保存
2. 每個分區的數據只能由一個消費者組中一個消費者消費(藍色範圍 Group)
3. 一個消費者可以消費多個分區數據

### 消費者組
Consumer Group(CG)消費者組，由多個 consumer 組成。形成一個消費者組的條件，是所有消費者的 groupid 相同。
消費者組內每個消費者負責消費不同分區的數據，一個分區只能由一個群組內的消費者消費。
消費者組之間相互不影響。所有的消費者都屬於某個消費者組，即消費者組是邏輯上的一個訂閱者。如下圖

![image](https://user-images.githubusercontent.com/17800738/178097091-8a3518e4-9a91-4f86-a779-cb370dee844f.png)

