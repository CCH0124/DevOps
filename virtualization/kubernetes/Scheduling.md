# Scheduling
## Manual
##### Manually schedule the pod on node01
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  -  image: nginx
     name: nginx
  nodeName: node01
```

##### Now schedule the same pod on the master/controlplane node
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  -  image: nginx
     name: nginx
  nodeName: controlplane
```

## Labels and Selectors

##### We have deployed a number of PODs. They are labelled with tier, env and bu. How many PODs exist in the dev environment?
```shell
kubectl get pods --selector=env=dev | wc -l
```

##### How many PODs are in the finance business unit (bu)?
```shell
kubectl get pods --selector=bu=finance | wc -l
```

##### How many objects are in the prod environment including PODs, ReplicaSets and any other objects?
```shell
kubectl get all --selector=env=prod 
```

##### Identify the POD which is part of the prod environment, the finance BU and of frontend tier?
```shell
kubectl get pod --selector=env=prod,bu=finance,tier=frontend
```

##### A ReplicaSet definition file is given replicaset-definition-1.yaml. Try to create the replicaset. There is an issue with the file. Try to fix it.
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
        tier: nginx
     spec:
       containers:
       - name: nginx
         image: nginx
```
Label 部分無匹配，因此要修正。
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
   name: replicaset-1
spec:
   replicas: 2
   selector:
      matchLabels:
        tier: nginx
   template:
     metadata:
       labels:
        tier: nginx
     spec:
       containers:
       - name: nginx
         image: nginx
```

## Taints and Tolerations
##### Do any taints exist on node01?
```shell
kubectl describe node node01 | grep "Taints"
```

##### Create a taint on node01 with key of spray, value of mortein and effect of NoSchedule
```shell
kubectl taint nodes node01 spray=mortein:NoSchedule
```

此時建立 POD (名稱 Mosquito)會發生 Pending。
##### Why do you think the pod is in a pending state?
- POD Mosquito cannot tolerate taint Mortein

##### Create another pod named bee with the NGINX image, which has a toleration set to the taint Mortein

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: bee
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "spray"
    operator: "Equal"
    value: "mortein"
    effect: "NoSchedule"
```

##### Do you see any taints on master/controlplane node?
在 master 上會是 `Taints:             node-role.kubernetes.io/master:NoSchedule`

##### Remove the taint on master/controlplane, which currently has the taint effect of NoSchedule

```shell
kubectl taint nodes controlplane node-role.kubernetes.io/master:NoSchedule-
```

## Node Affinity

##### How many Labels exist on node node01?

```shell
# kubectl get node node01 --show-labels
```

##### Apply a label color=blue to node node01

```shell
kubectl label nodes node01 color=blue
```

##### Set Node Affinity to the deployment to place the pods on node01 only
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: blue
  name: blue
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: blue
  template:
    metadata:
      labels:
        app: blue
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx
      restartPolicy: Always
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: color
                operator: In
                values:
                - blue
```

佈署時，全部都到 node01 節點上，該節點有 color=blue 的 Label

##### Create a new deployment named red with the nginx image and 2 replicas, and ensure it gets placed on the master/controlplane node only. Use the label - node-role.kubernetes.io/master - set on the master/controlplane node.

```shell
# kubectl get node controlplane --show-labels
NAME           STATUS   ROLES                  AGE   VERSION   LABELS
controlplane   Ready    control-plane,master   29m   v1.20.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=controlplane,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: red
  name: red
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: blue
  template:
    metadata:
      labels:
        app: blue
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx
      restartPolicy: Always
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: node-role.kubernetes.io/master
                operator: Exists
```

### Resource limites

##### A pod called rabbit is deployed. Identify the CPU requirements set on the Pod in the current(default) namespace
```shell
kubectl describe pods rabbit
```

##### Another pod called elephant has been deployed in the default namespace. It fails to get to a running state. Inspect this pod and identify the Reason why it is not running.
OOMKill。The status CrashLoopBackOff indicates that it is failing because the pod is out of memory. Identify the memory limit set on the POD.

##### The elephant pod runs a process that consume 15Mi of memory. Increase the limit of the elephant pod to 20Mi.


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: elephant
  namespace: default
spec:
  containers:
  - args:
    - --vm
    - "1"
    - --vm-bytes
    - 15M
    - --vm-hang
    - "1"
    command:
    - stress
    image: polinux/stress
    imagePullPolicy: Always
    name: mem-stress
    resources:
      limits:
        memory: 20Mi
      requests:
        memory: 15Mi
```

### DaemonSets
##### How many DaemonSets are created in the cluster in all namespaces?
```shell
kubectl get ds --all-namespaces
NAMESPACE     NAME              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   kube-flannel-ds   1         1         1       1            1           <none>                   13m
kube-system   kube-proxy        1         1         1       1            1           kubernetes.io/os=linux   13m
```
預設下 Kube-system 會有此資源。


##### Deploy a DaemonSet for FluentD Logging. Use the given specifications.
- Name: elasticsearch
- Namespace: kube-system
- Image: k8s.gcr.io/fluentd-elasticsearch:1.20

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: elasticsearch
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd-elasticsearch
  template:
    metadata:
      labels:
        name: fluentd-elasticsearch
    spec:
      containers:
      - name: fluentd-elasticsearch
        image: k8s.gcr.io/fluentd-elasticsearch:1.20
```

### Static POD
##### How many static pods exist in this cluster in all namespaces?
```shell
# kubectl get pods --all-namespaces
```

##### Which of the below components is NOT deployed as a static pod?
- CoreDNS
- Kube-proxy

##### On which nodes are the static pods created currently?
Master 節點上

##### What is the path of the directory holding the static pod definition files?
`/etc/kubernetes/manifests`

##### How many pod definition files are present in the manifests folder?
```shell
# ls /etc/kubernetes/manifests/
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml
```

##### What is the docker image used to deploy the kube-api server as a static pod?
```shell
# cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep "image"
    image: k8s.gcr.io/kube-apiserver:v1.20.0
    imagePullPolicy: IfNotPresent
```

##### Create a static pod named static-busybox that uses the busybox image and the command sleep 1000
```shell
kubectl run static-busybox --image=busybox --command sleep 1000 --restart=Never --dry-run=client -o yaml > static-pod.yaml
```

```shell
mv static-pod.yaml /etc/kubernetes/manifests/
```

##### Edit the image on the static pod to use busybox:1.28.4
修改 yaml 檔

##### We just created a new static pod named static-greenbox. Find it and delete it.
```shell
# kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
static-busybox-controlplane   1/1     Running   0          74s
static-greenbox-node01        1/1     Running   0          58s
```

從後墜可以辨別是在 node01 上建立，我們必須遠端至該節點

```shell
# kubectl get node -o wide  # 獲取 node01 IP
# ssh 10.56.126.12
```

透過 ps 查看 kubelete 行程以及配置
```shell
#  ps -aux | grep "kubelet"
root     15871  0.0  0.1 3632384 101036 ?      Ssl  03:12   0:12 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.2
root     19376  0.0  0.0  11468  1088 pts/0    R+   03:18   0:00 grep --color=auto kubelet
```

```shell
# cat /var/lib/kubelet/config.yaml | grep "static"
staticPodPath: /etc/just-to-mess-with-you
```

```shell
rm -rf /etc/just-to-mess-with-you/greenbox.yaml
```

### Multiple Schedulers