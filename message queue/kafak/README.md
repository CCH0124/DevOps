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
