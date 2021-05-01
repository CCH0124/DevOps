# 1.19 版本
## Pod
##### How many pods ?
```shell
kubectl get pods
kubectl get pods --all-namespaces
```
##### Create a new pod with the nginx image.

```shell
kubectl run nginx --image=nginx
```

##### look details

```shell
kubectl describe pods newpods-l2kjk
```

##### Which nodes are these pods placed on ?

```shell
kubectl get pods -o wide
```

#####  How many containers are part of the pod webapp?
- What images are used in the new webapp pod?
- What is the state of the container agentx in the pod webapp ?

```shell
kubectl describe pods newpods-l2kjk
```

#####  Why do you think the container agentx in pod webapp is in error?
```shell
kubectl get pods -o wide 
webapp          1/2     ImagePullBackOff   0          3m3s    10.244.0.8   controlplane   <none>           <none>
```
```shell
kubectl describe pods webapp
```



##### kubectl get pods -o wide 的 Ready 欄位是什麼 ?

- Running Containers in POD/Total Containers in POD

##### Delete the webapp Pod.
```shell
kubectl delete pods webapp
```

##### Create a new pod with the name redis and with the image redis123. Use yaml file.
```shell
kubectl run redis --image=redis123 --dry-run=client -o yaml > redis.yml # 產生 yaml
kubectl apply -f redis.yml # 佈署
```
佈署會失敗，因為沒有該 image

##### Now change the image on this pod to redis. 
```shell
kubectl edit pods redis
```

## ReplicaSet

##### How many ReplicaSets exist on the system?
```shell
kubectl get rs
```
##### How many PODs are DESIRED ?
```shell
kubectl get rs
NAME              DESIRED   CURRENT   READY   AGE
new-replica-set   4         4         0       51s
```

##### What is the image used to create the pods in the new-replica-set ?
new-replica-set 這是一個已經啟動的 replicaSet。

```shell
# kubectl get rs -o wide
NAME              DESIRED   CURRENT   READY   AGE    CONTAINERS          IMAGES       SELECTOR
new-replica-set   4         4         0       106s   busybox-container   busybox777   name=busybox-pod
```

##### How many PODs are READY in the new-replica-set ?
```shell
kubectl get rs new-replica-set -o wide
kubectl get rs new-replica-set
```
##### Why do you think the PODs are not ready?
```shell
kubectl describe pods new-replica-set-xxxx -o wide
```

##### Why are there still 4 PODs, even after you deleted one?
設定 4 個副本，但刪除一個 POD 為何還是 4 個 ?
- ReplicaSet ensures that desired number of PODs always run


##### Create a ReplicaSet using the replicaset-definition-1.yaml file. There is an issue with the file, so try to fix it.
```yaml
# cat replicaset-definition-1.yaml 
apiVersion: v1
kind: ReplicaSet
metadata:
  name: replicaset-1
spec:
  replicas: 2
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx
```

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replicaset-1
spec:
  replicas: 2
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx

```

##### Fix the issue in the replicaset-definition-2.yaml file and create a ReplicaSet using it.

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replicaset-2
spec:
  replicas: 2
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
```

Label 不匹配

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replicaset-2
spec:
  replicas: 2
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx
```
##### Delete the two newly created ReplicaSets - replicaset-1 and replicaset-2
```shell
# kubectl delete rs replicaset-1
replicaset.apps "replicaset-1" deleted
# kubectl delete -f replicaset-definition-2.yaml 
replicaset.apps "replicaset-2" deleted
```

##### Fix the original replica set new-replica-set to use the correct busybox image.
Either delete and recreate the ReplicaSet or Update the existing ReplicaSet and then delete all PODs, so new ones with the correct image will be created.

```shell
# kubectl get rs new-replica-set -o yaml > rs.yaml # 獲取 yaml 檔
```
編輯 rs.yaml 將不必要的資訊移除，會剩下如下字段

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: new-replica-set
  namespace: default
spec:
  replicas: 4
  selector:
    matchLabels:
      name: busybox-pod
  template:
    metadata:
      creationTimestamp: null
      labels:
        name: busybox-pod
    spec:
      containers:
      - command:
        - sh
        - -c
        - echo Hello Kubernetes! && sleep 3600
        image: busybox
        imagePullPolicy: Always
        name: busybox-container
```

```shell
# kubectl delete rs new-replica-set
# kubectl apply -f rs.yaml
```

##### Scale the ReplicaSet to 5 PODs.
```shell
# kubectl scale replicaset --replicas=5 new-replica-set
# kubectl get rs new-replica-set # 驗證
```
Or

使用 `edit`，並修改 `replicas` 字段數量
```shell
# kubectl edit rs new-replica-set
```

##### Now scale the ReplicaSet down to 2 PODs.

擴展數量減少，如上一個擴展方式一樣，使用 `scale` 或是 `edit` 方式
