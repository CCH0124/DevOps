- docker-compose-stack.yml  針對於 swarm 環境
- docker-compose.yml 建立基礎組件
- other-export-docker-compose.yml 其他非選監控組件
# Moniter
### 監控系統組件
- 指標數據採集
- 指標數據儲存
    - 儲存性能
- 指標分析與視覺化
- 告警

### 監控體系
- 系統層
    - 系同層監控
        - CPU
        - Load
        - Mempry
        - Swap
        - Disk IO
        - Process
    - 網路層監控
        - 設備
        - 負載
        - 延遲
        - 速率
- 基礎設施監控
    - 消息類
        - Kafka ...
    - Web 服務
        - Nginx ...
    - 資料庫或緩存
        - PostgreSQL ...
    - 儲存系統
        - Ceph ...
- 應用層監控
    -  代碼狀態
    -  性能
- 業務層
### 可觀測性
- 指標監控
    - 隨時間推移產生的一些可聚合數據
    - Prometheus...
- 日誌監控
    - 離散式的日誌或事件
    - ELK、EFK、PLG ...
- 鏈路追蹤
    - 分散式應用調用請求追蹤
    - Zipkin、Jaeger、SkyWalking ...
### 監控方法論
- Google
    - 衡量終端用戶體驗、服務中斷等層面問題
- Netfix USE 方法
    - 系統性能問題，可讓用戶快速識別資源瓶頸問題
### 黃金指標
Google SRE 中提到
- Latency
    - 服務請求所需的時間
- Traffic
    - 衡量服務容量需求
        - 每秒處理的 HTTP 請求數或資料庫的事物數量
- Errors
    - 衡量錯誤發生的情況
- Saturation
    - 衡量資源使用情況，應用層續有多滿
        - Memory、CPU、I/O 等
# Promethues
![](https://camo.githubusercontent.com/f14ac82eda765733a5f2b5200d78b4ca84b62559d17c9835068423b223588939/68747470733a2f2f63646e2e6a7364656c6976722e6e65742f67682f70726f6d6574686575732f70726f6d65746865757340633334323537643036396336333036383564613335626365663038343633326666643564363230392f646f63756d656e746174696f6e2f696d616765732f6172636869746563747572652e737667)

- 多為度資料模型
- 靈活的查詢語言(PromQL)
- 基於 HTTP 的 Pull 方式收集時序資料
- 可以透過 Push Gateway 進行資料推送
- 可與 Grafana 等儀錶板進行視覺化呈現
- 能透過服務發現(Service discovery)或靜態組態去獲取監控的 Targets

>PromQL：允許進行多種操作，包括 aggregation, slicing and dicing, prediction and joins

## 元件
- Prometheus Server
    - 收集與儲存時間序列資料，並提供 PromQL 查詢語言支援。
- Client Library
    - 客戶端函式庫，提供語言開發來開發產生 Metrics 並曝露 Prometheus Server。當 Prometheus Server 來 Pull 時，直接返回即時狀態的 Metrics。
- Pushgateway
    - 主要用於臨時性 Job 推送。這類 Job 存在期間較短，有可能 Prometheus 來 Pull 時就消失，因此透過一個閘道來推送。適合用於服務層面的 Metrics。
- Exporter
    - 用來曝露已有第三方服務的 Metrics 給 Prometheus Server，即以 Client Library 開發的 HTTP server。
- AlertManager
    - 接收來至 Prometheus Server 的 Alert event，並依據定義的 Notification 組態發送警報，ex: E-mail、Pagerduty、OpenGenie 與 Webhook 等等。

Prometheus 支持三種類型的抓取(scraping)
- Exporters
    - 服務無提供，需另外提供規格
- Instrumentation
    - 自身服務提供
- Pushgateway
    - 短期任務或批次性其身命週期難以預估，很難透過 export 方式獲取

## 概念
### Data Model
Prometheus 儲存的資料數據為時間序列，以指標的名稱(Metrics Name)和鍵值對(labels稱標籤)的集合組成，在每一個時間序列都是唯一標識，不同標籤表示不同時間序列。
- Metrics Name
    - 表示該指標(Metrics)的功能
    - 以 ASCII 字元、數字、英文、底線與冒號組成，並且要滿足`[a-zA-Z_:][a-zA-Z0-9_:]*` 正規表示法
    - 範例 `http_requests_total`，表接收到的 HTTP 請求總數。
- 標籤
    - 用來識別同一個時間序列不同維度
    - 以 ASCII 字元、數字、英文、底線與冒號組成，並且要滿足`[a-zA-Z_:][a-zA-Z0-9_:]*` 正規表示法
    - 範例 `http_request_total{method="Get"}` 表示蒐集 HTTP 的 Method 為 Get 的請求數量，當 Get 為 Post 時又是另一個新的 Metric
- 樣本
    - 實際的時間序列
        - 每個序列包含一個 float64 值與一個毫秒的時間戳
- 格式
    - 給定一個指標名稱和標籤組合，時間序列通常使用此標記來標識 `<metric name>{<label name>=<label value>, ...}`
    - 範例 `http_requests_total{method="POST",endpoint="/api/tracks"}`
### metric types
Prometheus Client 函式庫提供了四種主要核心 Metric 類型：

- Counter
    - 可被累加的 Metric，值只能增加或重新啟動時重置為零
    - 範例 HTTP 500 的出現次數等
- Gauge
    - 屬於瞬時且與時間無關的任意更動 Metric
    - 範例記憶體、硬碟使用率、行程數量
- Histogram
    - 主要用在表一段持續時間範圍內的資料採樣
    - 累積直方圖
    - 範例請求持續時間或響應大小
- Summary
    - 相似 Histogram，用來表示一端時間範圍內資料取樣總結
### jobs and instance
Prometheus 將任意可被 Prometheus 抓取獨立資料來源(Target)端點稱為 Instance，其為`<host>:<port>`組成。包含多個相同 Instance 的集合稱為 Job。

```
job: api-server
    instance 1: 1.2.3.4:5670 # TARGET
    instance 2: 1.2.3.4:5671
    instance 3: 5.6.7.8:5670
    instance 4: 5.6.7.8:5671
```
可參閱 [scrape_config 配置](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config)

## Storage
### TSDB(Time Series Database)
用來儲存與管理時間序列資料(Time Series Data)的資料庫系統。以時間做為索引。

特點有以下等
- 都是寫入數據
    - 寫入時間非常短，約幾秒內完成
- 寫入是依序新增
- 不大會更新資料
- 資料以區塊為單位進行刪除

[參考資源 http://liubin.org/blog/2016/02/18/tsdb-intro/](http://liubin.org/blog/2016/02/18/tsdb-intro/)

#### Local Storage
Prometheus 以本地時間序列以自定義、高效的格式在本地儲存數據。

##### On-disk Layout
以兩小時(預設)為一個區塊被儲存，每個區塊會包含Chunks、meta.json、index(which indexes metric names and labels to time series in the chunk files)等。透過 API 刪除時間序列資料時，刪除紀錄將被儲存在單獨的邏輯檔案(tombstone)中，非立即從 chunk 中刪除資料。

Prometheus 剛抓取的資料會保存在記憶體中，會藉由 write-ahead-log(WAL) 機制來防止當前區塊在收集樣本資料時，發生伺服器錯誤或重啟等問題。一但，觸發錯誤等問題，將會依據 WAL 進行恢復。


目錄結構如下，取自官方：
```bash=
./data
├── 01BKGV7JBM69T2G1BGBGM6KB12
│   └── meta.json
├── 01BKGTZQ1SYQJTR4PB43C8PD98
│   ├── chunks
│   │   └── 000001
│   ├── tombstones
│   ├── index
│   └── meta.json
├── 01BKGTZQ1HHWHV8FBJXW1Y3W0K
│   └── meta.json
├── 01BKGV7JC0RY8A6MACW02A2PJD
│   ├── chunks
│   │   └── 000001
│   ├── tombstones
│   ├── index
│   └── meta.json
├── chunks_head
│   └── 000001
└── wal
    ├── 000000002
    └── checkpoint.00000001
        └── 00000000
```

官方建議使用 RAID、[snapshots](https://prometheus.io/docs/prometheus/latest/querying/api/#snapshot)、[remote read/write APIs](https://prometheus.io/docs/operating/integrations/#remote-endpoints-and-storage) 方式保護數據。

Prometheus 每個樣本平均只儲存1至2位元組(byte)。因此，要計劃Prometheus 服務器的容量，可以使用以下粗略公式：
```bash=
needed_disk_space = retention_time_seconds * ingested_samples_per_second * bytes_per_sample
```

過期的區塊清除動作將在後台進行。刪除過期的數據區塊可能最多需要兩個小時。且，區塊必須完全過期後才能刪除。

- [官方 storage 介紹](https://prometheus.io/docs/prometheus/latest/storage/)

##### Remote storage integrations

![](https://prometheus.io/docs/prometheus/latest/images/remote_integrations.png "from prometheus.io")

##### Prometheus Storage Flags

|Args|default|description|
|---|---|---|
|–storage.tsdb.path	|data/|Metrics 儲存路徑|
|–storage.tsdb.retention|15d|儲存的資料樣本會保留多長的時間|
|–storage.tsdb.min-block-duration|2h|一個資料區塊的最小持續時間|
|–storage.tsdb.max-block-duration|36h|壓縮區塊的最大持續時間(預設為 retention period 的 10% 時間)|
|–storage.tsdb.no-lockfile|false|設定是否建立 lockfile 在資料目錄下|
|–storage.remote.flush-deadline|1m|在關機或者組態重新讀取時，清除樣本的等待時間

## 高可用
### Federation 
Prometheus 是進行擴展的服務，實現高可用性(High Availability)與切片(Sharding)。可使用 `Cross-service federation` 與 `Hierarchical federation` 方式。
##### Hierarchical federation
此方式讓 Prometheus 可擴展到具有數十個數據中心和數百萬個節點的環境。該環境，可以想像成一棵樹，高級別的 Prometheus 服務器從大量從屬(subordinated)服務器收集聚合的時間序列數據。

![](https://i.imgur.com/dOinJCq.png "from https://k2r2bai.com/")

##### Cross-service federation
一個 Prometheus Server 設定成從另一個 Prometheus Server 中獲取選中的時間序列資料，使得這個 Prometheus 能夠對兩個資料來源進行查詢與告警。

![](https://i.imgur.com/ism3t0M.png "from https://k2r2bai.com/")

- [官方](https://prometheus.io/docs/prometheus/latest/federation/#hierarchical-federation)


## PromQL

內建，支持兩種向量，同時內建一組用於數據處理的函示
- 即時向量
    - 最近一次時間戳上跟蹤的數據指標
- 時間範圍向量
    - 指定時間範圍內的所有時間戳上的數據指標
    - 通常與聚合函數共用
- 標量
    - 一個浮點數的數據值
- 字串
    - 可使用單引號或雙引號、反引號(不會轉義)

![](https://i.imgur.com/bzt8qv7.png)

範圍向量可寫成 `http_request_total{method="Get"} offset 5m` 獲取過去 5 分鐘的資料；`http_request_total{method="Get"}[5m] offset 1d` 獲取一天之前的5分鐘內資料

##### 匹配器
- 操作符
    - `=`
    - `!=`
    - `=~`
    - `!~`

##### 範例
- 每台主機 CPU 在 5 分鐘內的平均使用率
`(1-avg(irate(node_cpu_seconds_total{mode='idle'}[5m]))  by  (instance)) * 100`
![](https://i.imgur.com/sQI3qah.png)

## 服務發現
Prom 是基於 pull 方式抓取數據，因此需要事先知道各個 Target 的位置，因此才需要服務發現方式來動態偵測 Target。
- [基於檔案](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#file_sd_config)
    - 撰寫額外的檔案，並定義下面 yml 的內容至 prom 中
    - 變動可讓 prom 定期詢問更新
```yaml=
- job_name: "xxxx"
    file_sd_configs:
    - file:
      - target/*.yml # 檔案路徑
      refresh_interval: 2m # 每兩分鐘重新加載

```
- [基於 DNS](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#dns_sd_config)
    - [可結合 Consul](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#consul_sd_config)
    - [swarm](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#dns_sd_config)
- 基於 API
    - 公有雲
    - K8s API
### 指標抓取生命週期

1. 服務發現
- 發現 Target
2. 配置
3. 重新標籤(relabe_configs)
- 儲存在 Prom 之前做的動作
4. 抓取
5. 重新標記(metric_relable_configs)
- 抓取的指標在保存之前，允許用戶端重新打標和過濾
    - 定義在 job 配置中的 `metric_relabel_configs`，通常用來刪除不必要指標或著添加、刪除、修改指標的標籤值或格式

而每個 Target 都有標籤。通常會有 
- `__address__`
    - 連接位置
- `__metrics_path__`
    - 抓取 target 上指標時使用的 URL 路徑，默認為 `metrics`
- `__scheme__`
    - target 所使用的協定

![](https://i.imgur.com/aPTGw7Q.png)

##### 重新打標
- [relabel_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config)
    - 替換標籤值
        - replace
        - hashmod
    - 刪除指標
        - keep
        - drop
    - 創建或刪除標籤
        - labelmap
            - 找現有標籤能夠符合正則表示的標籤
        - labeldrop
            - 匹配到的刪除
        - labelkeep
            - 不能匹配到的刪除
- [metric_relabel_configs](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs)
    - 針對 Metric Name
# Alert

使用 alertmanager 進行實現。
Alert 會有以下狀態
- inactive
    - 沒有觸發
- pending
    - 告警的狀態少於已配置的閾值持續時間
- firing
    - 告警的狀態已超過配置的閾值持續時間

![](https://i.imgur.com/IMi3qsY.png)

除了告警外還有去重、分組、抑制等功能。

- Grouping
    - 將相似警告合併為一個通知，避免訊息淹沒
- Inhibition
    - 避免級聯警告，系統 A 故障，導致系統 B 無法運作，進而連續發出警告
- Silent
    - 在一個特定時間內，即便有警告通知也不向用戶發送通知，常用於系統維護
- Route
    - 處裡傳入類型的告警通知，決定後續行為

警報僅在評估週期(evaluation_interval)內才從一種狀態轉換到另一種狀態。轉換的發生方式取決於是否設置了警報的 `FOR` 子句。
- 沒有 FOR 子句（或設置為0）的告警將立即轉換成 `firing`
- 帶有 FOR 子句的告警先轉換為 `pending` 接著在 `firing`
    - 至少需要兩個評估週期

### Alert 生命週期

```yaml=
global:
  scrape_interval: 20s
  evaluation_interval: 1m
```
在 Prom 中我們設置每 20s 獲取一次指標。評估間格(evaluation interval)為 1 分鐘。我們觸發一個告警會是：
指標監控時間+scrape_interval+evaluation_interval+FOR

[更詳細內容可參考此鏈接](https://pracucci.com/prometheus-understanding-the-delays-on-alerting.html)

### 配置
告警規則配置如下：
```yaml=
groups:

- name: host
  rules:
# Memory
# Node memory is filling up (< 10% left)
  - alert: HostOutOfMemory
    expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100 < 10
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: Host out of memory (instance {{ $labels.instance }})
      description: Node memory is filling up (< 10% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}
```

同時 prom 也進行配置，以用來觸發告警
```yaml=
rule_files: # 規則的路徑
  - alerts/*.yml

alerting: # 與 alertmanagers 配置
  alertmanagers:
    - static_configs:
      - targets:
        # Alertmanager's default port is 9093
        - alertmanager:9093
```

通知的配置可參考此[鏈接](https://grafana.com/blog/2020/02/25/step-by-step-guide-to-setting-up-prometheus-alertmanager-with-slack-pagerduty-and-gmail/)

# Grafana
## 設置 datasource
簡單來說就是數據來源。

![](https://i.imgur.com/mMs9iEB.png)

新增一個儀表板來實驗

![](https://i.imgur.com/RkJZFWR.png)

使用 promQL 進行獲取數據指標
![](https://i.imgur.com/XoKAEyl.png)

## 儀錶板設計
- 匯入來至 grafana 官方社群友人提供的儀表板
    - 透過 ID 或是 Json 格式匯入
- 自訂義
##### Default paths

|Setting Default |value|
|---|---|
|GF_PATHS_CONFIG | /etc/grafana/grafana.ini|
|GF_PATHS_DATA | /var/lib/grafana|
|GF_PATHS_HOME | /usr/share/grafana|
|GF_PATHS_LOGS | /var/log/grafana|
|GF_PATHS_PLUGINS | /var/lib/grafana/plugins|
|GF_PATHS_PROVISIONING	| /etc/grafana/provisioning|

[官方鏈接](https://grafana.com/docs/grafana/latest/administration/configure-docker/)

## 監控目標設定
### 主機資源 
- [node_exporter](https://github.com/prometheus/node_exporter)

```shell=
$ vi prometheus.yml
scrape_configs:
  - job_name: "node"
    static_configs:
      - targets: ["192.168.101.129:9100"]
```

### 容器資源
- [cadvisor](https://github.com/google/cadvisor)
```shell=
    $ vi prometheus.yml
    scrape_configs:
      - job_name: "cadvisor"
        static_configs:
          - targets: ["cadvisor:8080"] # 服務發現方式
```
    
- [docker 官方提供的方式](https://docs.docker.com/config/daemon/prometheus/)
```shell=
$ sudo vi /etc/docker/daemon.json
{
  "metrics-addr" : "192.168.0.1:9100",
  "experimental" : true
}
```
```shell=
$ vi prometheus.yml
scrape_configs:
- job_name: 'docker'

    static_configs:
    - targets: ['192.168.200.134:9100']
```
### SpringBoot 監控
- [Actuator](https://medium.com/aeturnuminc/configure-prometheus-and-grafana-in-dockers-ff2a2b51aa1d) 

```xml=
 <dependency>
                        <groupId>org.springframework.boot</groupId>
                        <artifactId>spring-boot-starter-actuator</artifactId>
                </dependency>
                <dependency>
                        <groupId>io.micrometer</groupId>
                        <artifactId>micrometer-registry-prometheus</artifactId>
                </dependency>
                <dependency>
                        <groupId>io.prometheus</groupId>
                        <artifactId>simpleclient_pushgateway</artifactId>
                </dependency>
```
屬性配置
```yaml=
management.endpoints.web.exposure.include=prometheus # 可暴露的端點
management.metrics.export.prometheus=true
management.metrics.export.prometheus.pushgateway.base-url=${PUSHGATEWAYS_URI} # 推送 pushgateway，promethues 在 pull
management.metrics.export.prometheus.pushgateway.enabled=true
management.metrics.export.prometheus.pushgateway.push-rate=1m
management.metrics.export.prometheus.pushgateway.shutdown-operation=push
```
