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
