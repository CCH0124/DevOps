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
