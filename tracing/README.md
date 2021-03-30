此 docker-compose 需與 elasticsearch 做結合，才能做到儲存 span 的效果。基於簡潔，因此這邊不提供 Elasticsearch 架設配置檔，可從 logging 資料夾下的 EFK 來得知如何架設 Elasticsearch。而從 [spring boot](https://github.com/CCH0124/spring-boot-training/tree/main/psql-spring-boot) 範例中 traceing-docker-compose.yaml 得知要如何進行配置以獲得 API 追蹤功能。

## trace 
trace 代表了一個在系統中執行的過程。在 OpenTelemetry 標準下，trace 是一個有向無環圖（DAG）由多個 span 組成，每個 span 代表著 trace 中被命名和計時的連續性執行片段，Span 之間交互的邊被定義為父/子關係。

```
一個 tracer 過程中，每個 span 關係


        [Span A]  ←←←(the root span)
            |
     +------+------+
     |             |
 [Span B]      [Span C] ←←←(Span C 是 Span A 的子節點, ChildOf)
     |             |
 [Span D]      +---+-------+
               |           |
           [Span E]    [Span F] >>> [Span G] >>> [Span H]
                                       ↑
                                       ↑
                                       ↑
                         (Span G 在 Span F 後被調用, FollowsFrom)
```

時間軸的呈現
```
上面 tracer 與 span 時間軸關係

––|–––––––|–––––––|–––––––|–––––––|–––––––|–––––––|–––––––|–> time

 [Span A···················································]
   [Span B··············································]
      [Span D··········································]
    [Span C········································]
         [Span E·······]        [Span F··] [Span G··] [Span H··]

```

## Span
一個 span 代表系統中具有開始時間和執行時長的邏輯運行單元。會有以下資訊：
- 操作名稱
- 開始與完成的時間戳
- 一組鍵值隊的屬性(Attributes)
- 一組零或多個事件，每個事件本身就是一個元組（時間戳、名稱、屬性），名稱必須是字符串
- 父級 Span 標識
- 鏈接(Links)到零個或多個因果相關的 Span
    - 藉由相關 Span 的 SpanContext
- 引用 Span 所需的 SpanContext 訊息
    - 其中包含 Trace ID 和 Span ID 引用關係

## Span Context
可在調用服務之間進行傳送。包含從父 Span 傳播到子 Span 的追蹤標識和選項。

每個 Span 包含如下狀態：
- TraceId 是追蹤的標識符，用於將所有過程中特定追蹤的所有範圍分組在一起
- SpanId 是 Span 的標識符，當傳遞給子 Span 時，此標識符將成為子 Span 的父 Span 標識符
- TraceFlags 表示追踪的選項
    - Sampling bit 表示是否採樣追蹤的 Bit
- Tracestate 在鍵值對列表中包含特定於追蹤系統的上下文
    - 允許不同的供應商傳播其他訊息，並與他們的舊 ID 格式進行交互操作

## Inter-Span References
一個 Span 可以與單一或多個 Span 形成關係。在 Opentracing 定義了 `ChildOf` 和 `FollowsFrom` 關係。這表示子節點和父節點的因果關係。

`ChildOf` 表示一個 Span 可能是一個父級 Span 的孩子，因此父級 Span 在某些情況下取決於子 Span。

```
    [-Parent Span---------]
         [-Child Span----]

    [-Parent Span--------------]
         [-Child Span A----]
          [-Child Span B----]
        [-Child Span C----]
         [-Child Span D---------------]
         [-Child Span E----]
```

`FollowsFrom` 一些父 Span 不以任何方式依賴它們子 Span 執行結果。

```
    [-Parent Span-]  [-Child Span-]


    [-Parent Span--]
     [-Child Span-]


    [-Parent Span-]
                [-Child Span-]
```

詳細內容可參考 opentelemetry 此[鏈接](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/overview.md)

或 opentracing [參考資源](https://makeoptim.com/distributed-tracing/open-tracing)

## Logs
每個 Span 可以進行多次 Logs 操作，每一次 Logs 操作，需要有一個帶時間戳的時間名稱，和其它儲存結構。

詳細內容可參考此[鏈接](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/logs/data-model.md)

## Tags
每個 Tag 可以有多個鍵值對，可用來對 Span 註解或是補充，Tag 不附帶時間。


# jaeger
## 特性
用於監控和診斷基於微服務的分散式系統，包括以下
- 分散式傳播
- 分散式交易監控
- 根本原因分析
- 服務依賴分析
- 性能/延遲優化

在 Jaeger 中工作單元為 Span，該 Span 有觸發時間、持續時間，並利用嵌套方式建立父子因果關係。

![](https://1fykyq3mdn5r21tpna3wkdyi-wpengine.netdna-ssl.com/wp-content/uploads/2019/11/Header-768x329.png "From uber 官網")

一個 Trace 是一個執行路徑，可說是是由一組 Span 定義的有向無環圖(DAG)組合。


## 組件

官方描述可直接將數據寫入 DB 或是使用 Kafka 做一個緩衝在送至 DB。
![https://www.jaegertracing.io/docs/1.22/architecture/](https://www.jaegertracing.io/img/architecture-v1.png "jaeger 官網")

##### Agent
為一個守護程序，監聽 UDP 端口發送的 Span，然後將其分批發送給收集器(jaeger-collector)。他為一個基本組件，將會佈署至每台主機，
##### Collector
從 Jaeger Agent 接收 tracing，並藉由管道運行處裡它們。管道中會驗證 tracing，為其建立索引，執行任何轉換最後儲存它們。
##### Query
是一項從儲存中檢索追蹤並交給 UI 來顯示追蹤的服務

##### Ingester
是一個從 Kafka topic 讀取並寫入儲存後端（Elasticsearch等）的服務。
## 結合 ELK
將數據傳至 Elasticsearch 並使用 Kibana 做客製視覺化

```bash=
docker run -it -d --name=jaeger -e SPAN_STORAGE_TYPE=elasticsearch -e ES_SERVER_URLS=http://192.168.101.129:3001 -e ES_TAGS_AS_FIELDS_ALL=true -p 3006:16686 jaegertracing/opentelemetry-all-in-one
```
測試數據
```shell=
docker run --rm --link jaeger --env JAEGER_AGENT_HOST=jaeger --env JAEGER_AGENT_PORT=6831 -p8080-8083:8080083 jaegertracing/example-hotrod:latest all
```

[參考來源](https://logz.io/blog/jaeger-and-the-elk-stack/)

## UI
![](https://i.imgur.com/xLhjCYH.png)

## 整合 Spring boot
```shell=
 -javaagent:opentelemetry-javaagent-all.jar
```
