# 1.19 版本
## Pod
yaml 定義

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: postgres
  labels:
    tier: db
spec:
  containers:
    - name: postgres
      image: postgres
      env:
        - name: POSTGRES_PASSWORD
          value: password
```
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
yaml 定義

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: mywebsite
    tier: frontend
spec:
  replicas: 4
  selector:
    matchLabels:
      app: myapp
  template: # 定義 POD
    metadata:
      name: myapp-pod
      labels:
        app: myapp
    spec:
      containers:
        - name: nginx
          image: nginx
```

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

## Deployments
yaml 定義

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: mywebsite
    tier: frontend
spec:
  replicas: 4
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      name: myapp-pod
      labels:
        app: myapp
    spec:
      containers:
        - name: nginx
          image: nginx
```

##### How many Deployments exist on the system? In the current(default) namespace.
```shell
# kubectl get deployment
```

##### Create a new Deployment using the deployment-definition-1.yaml file. There is an issue with the file, so try to fix it.
```yaml
---
apiVersion: apps/v1
kind: Deployment # 不是 deployment
metadata:
  name: deployment-1
spec:
  replicas: 2
  selector:
    matchLabels:
      name: busybox-pod
  template:
    metadata:
      labels:
        name: busybox-pod
    spec:
      containers:
      - name: busybox-container
        image: busybox888
        command:
        - sh
        - "-c"
        - echo Hello Kubernetes! && sleep 3600
```

##### Create a new Deployment with the below attributes using your own deployment definition file.
- Name: httpd-frontend;
- Replicas: 3;
- Image: httpd:2.4-alpine

```shell
# kubectl create deployment --image=httpd:2.4-alpine --replicas=3 httpd-frontend
```

## Namespace

yaml 定義

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

##### How many Namespaces exist on the system?
```shell
# kubectl get ns
```

##### How many pods exist in the research namespace?
```shell
# kubectl get pods -n research
```

##### Create a POD in the finance namespace. Use the spec given below.
```shell
#  kubectl run nginx --image=nginx --namespace=finance
```

##### Which namespace has the blue pod in it?
```shell
# kubectl get pods --all-namespaces
```
##### What DNS name should the Blue application use to access the database 'db-service' in the 'dev' namespace You can try it in the web application UI. 

- `db-service.dev.svc.cluster.local`

## Service

yaml 定義

```yaml
apiVersion: v1
kind: Service
metadata:
  name: image-processing
  labels:
    app: myapp
spec:
  selector:
    tier: backend
  type: ClusterIP # or NodePort etc.
  ports:
    - port: 80
      targetPort: 8080
  
```

##### How many Services exist on the system? in the current(default) namespace
系統預設會建立一個
```shell
# kubectl get svc
```

##### What is the type of the default kubernetes service?
- clusterIP

##### What is the targetPort configured on the kubernetes service?
- 6443 (API Server)

```shell
# kubectl describe svc kubernetes 
Name:              kubernetes
Namespace:         default
Labels:            component=apiserver
                   provider=kubernetes
Annotations:       <none>
Selector:          <none>
Type:              ClusterIP
IP Families:       <none>
IP:                10.96.0.1
IPs:               10.96.0.1
Port:              https  443/TCP
TargetPort:        6443/TCP
Endpoints:         10.178.29.6:6443
Session Affinity:  None
Events:            <none>
```
##### Create a new service to access the web application using the service-definition-1.yaml file
- Name: webapp-service
- Type: NodePort
- targetPort: 8080
- port: 8080
- nodePort: 30080
- selector: simple-webapp

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  type: NodePort
  ports:
    - targetPort: 8080
      port: 8080
      nodePort: 30080
  selector:
    name: simple-webapp
```

## Imperative Commands

##### Deploy a pod named nginx-pod using the nginx:alpine image
```shell
kubectl run nginx-pod --image=nginx:alpine
```

##### Deploy a redis pod using the redis:alpine image with the labels set to tier=db
```shell
kubectl run redis --image=redis:alpine --labels=tier=db
```

驗證
```shell
kubectl get pods -o wide --show-labels
```

##### Create a service redis-service to expose the redis application within the cluster on port 6379
```shell
kubectl expose pod redis --name=redis-service --type=ClusterIP --port=6379 --target-port=6379
```

##### Create a deployment named webapp using the image kodekloud/webapp-color with 3 replicas
```shell
kubectl create deployment --image=kodekloud/webapp-color --replicas=3 webapp
```

##### Create a new pod called custom-nginx using the nginx image and expose it on container port 8080
```shell
kubectl run custom-nginx --image=nginx --port=8080
```

##### Create a new namespace called dev-ns
```shell
kubectl create namespace dev-ns
```

##### Create a new deployment called redis-deploy in the dev-ns namespace with the redis image. It should have 2 replicas
```shell
kubectl create deployment --image=redis --namespace=dev-ns --replicas=2 redis-deploy
```

##### Create a pod called httpd using the image httpd:alpine in the default namespace. Next, create a service of type ClusterIP by the same name (httpd). The target port for the service should be 80

```shell
kubectl run httpd --image=httpd:alpine --port=80
kubectl expose pod httpd --type=ClusterIP --name=httpd --target-port=80 --port=80
```

Or

```shell
kubectl run httpd --image=httpd:alpine --port=80 --expose
```