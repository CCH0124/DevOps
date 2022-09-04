KEDA 全名是 `Kubernetes Event Driven Autoscaling`。本實驗會透過 Kubernetes 呈現，向 Kafka 主題發送事件，第二個是接收它們。

## Architecture
producer(生產者) 和 consumer(消費者) 會使用同一個 topic 來交換事件。該 topic 有 10 個分區(partitions)。有一個生產者定期發送事件。我們將縮小和擴大消費者服務的 pod 數量。消費者服務的所有實例都分配給同一個 Kafka 消費者組，該組中只有一個實例可以接收特定事件。

![image](https://user-images.githubusercontent.com/17800738/188296568-64cd8194-ea96-4c24-8fb3-a1f67081e556.png)

實驗目的簡單，根據生產者服務產生的流量來調整消費者數量。偏移滯後(offset lag)的值不能超過所需的閾值，如果我們增加生產者端的流量，KEDA 應該增加消費的數量；反之，如果我們降低生產者流量，它應該減少消費者的數量。

![image](https://user-images.githubusercontent.com/17800738/188297166-649d28e6-136f-4b06-8117-08a6b1939cb2.png)

## Install Kafka

參照[quarkus-demo](https://github.com/CCH0124/quarkus-demo/blob/main/kafka/README.md)內容。


## Install KEDA

使用 Helm 方式

```bash
$ helm repo add kedacore https://kedacore.github.io/charts
$ helm search repo kedacore
$ helm install keda kedacore/keda --version 2.8.2 --namespace keda --create-namespace
```
## Integrate  KEDA with Kafka
`default` 命名空間(namespace)中運行這兩個範例應用程式，在該命名空間中還創建一個 KEDA 物件。內容如下

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name:  kafka-consumer
spec:
  scaleTargetRef:
    name: consumer-deployment # 1
  cooldownPeriod: 30 # 2
  maxReplicaCount:  10 # 3
  advanced:
    horizontalPodAutoscalerConfig: # 4
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 30
          policies:
            - type: Percent
              value: 50
              periodSeconds: 30
  triggers: # 5
    - type: kafka
      metadata:
        bootstrapServers: one-node-cluster.redpanda:9092
        consumerGroup: a
        topic: test-topic
        lagThreshold: '5'
```

1. 為消費者應用程式設定 autoscaler，該 name 會參照消費者應用程式的 Deployment 物件名稱
2. 將 `cooldownPeriod` 參數的默認值從 `300` 秒減少到 `30`，以測試歸零機制
3. 最大運行 Pod 數為 `10` 非預設 `100`
4. 可以自定義 Kubernetes HPA 的行為。讓我們為縮小操作執行此操作。我們也可以為放大操作配置它。這邊允許縮小當前運行的副本的 50%。
5. 最後是最重要的部分*觸發器配置*。應該設置 Kafka 的位置、topic 的名稱以及應用程式使用的消費者組(consumer group)。lagThreshold 值為 5，它設置偏移滯後的平均目標值以觸發縮放操作。

Kafka Consumer yaml :

```yaml
apiVersion: apps/v1 kafka-consumer
kind: Deployment
metadata:
  labels:
    app: kafka-consumer
  name: kafka-consumer
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kafka-consumer
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: kafka-consumer
    spec:
      securityContext:
        runAsUser: 1000
        runAsNonRoot: true
      imagePullSecrets:
      - name: registry-credentials
      containers:
      - image: cch0124/kafka-consumer:1.0.0-SNAPSHOT
        name: kafka-consumer
        imagePullPolicy: Always # IfNotPresent
        securityContext:
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: false
        env:
          - name: kafka.topics
            value: event
          - name: kafka.brokers
            value: my-cluster-kafka-bootstrap.default.svc.cluster.local:9092
          - name: kafka.groupId
            value: event
        resources:
          requests:
            memory: '256Mi'
            cpu: '500m'
          limits:
            memory: '1Gi'
            cpu: '1'
      restartPolicy: Always
```

Kafka producer yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: kafka-producer-callback
  name: kafka-producer-callback
spec:
  replicas: u5
  selector:
    matchLabels:
      app: kafka-producer
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: kafka-producer
    spec:
      securityContext:
        runAsUser: 1000
        runAsNonRoot: true
      imagePullSecrets:
      - name: registry-credentials
      containers:
      - image: cch0124/kafka-producer-callback:1.0.0-SNAPSHOT
        name: kafka-producer-callback
        imagePullPolicy: Always # IfNotPresent
        securityContext:
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: false
        env:
          - name: kafka.topic
            value: event
          - name: kafka.brokers.host
            value: my-cluster-kafka-bootstrap.default.svc.cluster.local:9092
          - name: kafka.time.period
            value: "1000"
        ports:
        - containerPort: 8080
          protocol: TCP
          name: callback
        resources:
          requests:
            memory: '256Mi'
            cpu: '500m'
          limits:
            memory: '1Gi'
            cpu: '1'
      restartPolicy: Always
```


上述 YAML 檔準備好後就開始吧
1. 把生產者佈署 1 個副本
```bash
$ kubectl get pods -l app=kafka-producer -w
NAME                                       READY   STATUS    RESTARTS   AGE
kafka-producer-callback-69c4447559-p58vk   1/1     Running   0          21s
```
2. 佈署 keda 

```bash
$ kubectl get scaledobjects.keda.sh -w
NAME              SCALETARGETKIND   SCALETARGETNAME   MIN   MAX   TRIGGERS   AUTHENTICATION   READY   ACTIVE    FALLBACK   AGE
consumer-scaled                     kafka-consumer          10    kafka                       False   Unknown   Unknown    2s
consumer-scaled   apps/v1.Deployment   kafka-consumer          10    kafka                       False   Unknown   Unknown    10s
consumer-scaled   apps/v1.Deployment   kafka-consumer          10    kafka                       False   Unknown   Unknown    10s
consumer-scaled   apps/v1.Deployment   kafka-consumer          10    kafka                       False   Unknown   Unknown    10s
consumer-scaled   apps/v1.Deployment   kafka-consumer          10    kafka                       True    Unknown   Unknown    10s
consumer-scaled   apps/v1.Deployment   kafka-consumer          10    kafka                       True    Unknown   Unknown    10s
consumer-scaled   apps/v1.Deployment   kafka-consumer          10    kafka                       True    True      Unknown    10s
consumer-scaled   apps/v1.Deployment   kafka-consumer          10    kafka                       True    True      False      25s
consumer-scaled   apps/v1.Deployment   kafka-consumer          10    kafka                       True    True      False      40s
consumer-scaled   apps/v1.Deployment   kafka-consumer          10    kafka                       True    True      False      70s
```

3. 佈署 consumer

```bash
$ kubectl get pod -l app=kafka-consumer -w
NAME                             READY   STATUS    RESTARTS   AGE
kafka-consumer-749cd6cb9-lk8hc   1/1     Running   0          37s
```
注意此時 KEDA 的 scaledobjects 物件會偵測到此 Deployment 因此 READY 會從 False 變成 True
4.  Producer 發送速率修改

刪除 producer
```bash
$ kubectl delete -f ../producer/producer-event.yaml
deployment.apps "kafka-producer-callback" deleted
```
consumer 從 1 被變成 0
```bash
$ kubectl get deployments.apps
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
my-cluster-entity-operator   1/1     1            1           77d
kafka-consumer               0/0     0            0           5m56s
strimzi-cluster-operator     1/1     1            1           77d
```

修改 yaml 中 `kafka.time.period` 環境變數改成 100 毫秒，並重新 apply，consumer 變成 3 個在消費
```bash
$ kubectl get deployments.apps
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
my-cluster-entity-operator   1/1     1            1           77d
strimzi-cluster-operator     1/1     1            1           77d
kafka-producer-callback      1/1     1            1           34s
kafka-consumer               3/3     3            3           7m59s # consumer 變成 3 個在消費
```

透過 `kubectl edit`  將 producer 速率調成整 10 秒發送一次數據，在觀察 consumer 會從 3 變成 1
```bash
$ kubectl get deployments.apps
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
...
kafka-producer-callback      1/1     1            1           3m53s
kafka-consumer               1/1     1            1           11m
```

consumer 變成是透過 kafa 更細微的粒度來擴展而非單純 CPU 等指標。

不僅可以將 KEDA 與 Kafka 一起使用。在應用還有很多其他可用的選項，包括資料庫、不同的消息代理，甚至是 cron。完整資訊可以從[官方](https://keda.sh/docs/2.5/scalers/)獲取。範例展示如何使用 Kafka 消費者偏移(offset)和滯後(lag)作為 KEDA 自動縮放的標準。
