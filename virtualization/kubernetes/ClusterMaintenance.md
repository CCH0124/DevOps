## OS Upgrades

##### We need to take node01 out for maintenance. Empty the node of all applications and mark it unschedulable.

- Node node01 Unschedulable
- Pods evicted from node01

```bash
kubectl drain node01 --ignore-daemonsets

```

##### What nodes are the apps on now?
承接上述情境

```bash
kubectl get pods -o wide
```
都被調度到 `controlplane` 上。

##### The maintenance tasks have been completed. Configure the node node01 to be schedulable again.
```bash
kubectl uncordon node01
```

此時之前被調度到 `controlplane` 的資源並不會被調度回來。只有在創建新的 Pod 時，它們才會被調度

##### Why are the pods placed on the controlplane node?
- controlplane node does not have any taints


##### Why did the drain command fail on node01? It worked the first time!
當再次執行 `kubectl drain node01 --ignore-daemonsets` 會失敗，node01 中有一個不屬於 ReplicaSet 的 pod。

##### What would happen to hr-app if node01 is drained forcefully?

強制執行以下的指令，該非 ReplicaSet 管理的 Pod 將會遺失。
```bash
kubectl drain node01 --ignore-daemonsets --force
```

##### hr-app is a critical app and we do not want it to be removed and we do not want to schedule any more pods on node01.
Mark node01 as `unschedulable` so that no new pods are scheduled on this node.
```bash
# kubectl cordon node01
# kubectl get nodes
NAME           STATUS                     ROLES                  AGE   VERSION
controlplane   Ready                      control-plane,master   26m   v1.20.0
node01         Ready,SchedulingDisabled   <none>                 25m   v1.20.0 # 調度機制是關閉
```

## Cluster Upgrade Process
##### What is the current version of the cluster?

```bash
# kubectl get node 
NAME           STATUS   ROLES    AGE    VERSION
controlplane   Ready    master   6m5s   v1.19.0
node01         Ready    <none>   4m     v1.19.0
```

##### How many nodes can host workloads in this cluster?
Inspect the applications and taints set on the nodes.
```bash
# kubectl get pods -o wide
NAME                    READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
blue-746c87566d-2tb8k   1/1     Running   0          2m30s   10.244.1.4   node01         <none>           <none>
blue-746c87566d-7rvjj   1/1     Running   0          2m29s   10.244.0.5   controlplane   <none>           <none>
blue-746c87566d-ftrt5   1/1     Running   0          2m30s   10.244.0.4   controlplane   <none>           <none>
blue-746c87566d-jz9cz   1/1     Running   0          2m29s   10.244.1.5   node01         <none>           <none>
blue-746c87566d-m6vqt   1/1     Running   0          2m30s   10.244.1.3   node01         <none>           <none>
simple-webapp-1         1/1     Running   0          2m31s   10.244.1.2   node01         <none>           <none>
```

##### You are tasked to upgrade the cluster. User's accessing the applications must not be impacted. And you cannot provision new VMs. What strategy would you use to upgrade the cluster?

- Upgrade one node at a time while moving the workloads to the other

##### What is the latest stable version available for upgrade?
使用 `kubeadm` 獲取

```bash
# kubeadm upgrade plan
...
Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT       AVAILABLE
kubelet     2 x v1.19.0   v1.19.12

Upgrade to the latest version in the v1.19 series:

COMPONENT                 CURRENT   AVAILABLE
kube-apiserver            v1.19.0   v1.19.12
kube-controller-manager   v1.19.0   v1.19.12
kube-scheduler            v1.19.0   v1.19.12
kube-proxy                v1.19.0   v1.19.12
CoreDNS                   1.7.0     1.7.0
....
```

##### We will be upgrading the master node first. Drain the master node of workloads and mark it UnSchedulable
- Master Node: SchedulingDisabled

```bash
# kubectl drain controlplane --ignore-daemonsets 
```

##### Upgrade the controlplane components to exact version v1.20.0

>Upgrade kubeadm tool (if not already), then the master components, and finally the kubelet. Practice referring to the kubernetes documentation page. Note: While upgrading kubelet, if you hit dependency issue while running the apt-get upgrade kubelet command, use the apt install kubelet=1.20.0-00 command instead

```bash
# apt update
# apt install kubeadm=1.20.0-00
# kubeadm upgrade apply v1.20.0
# apt install kubelet=1.20.0-00
```


- [官方更新資訊](https://v1-20.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

##### Mark the controlplane node as "Schedulable" again
更新完後 `controlplane` 將其變成可調度

```bash
# kubectl uncordon controlplane
```

##### Next is the worker node. `Drain` the worker node of the workloads and mark it `UnSchedulable`

```bash
# kubectl drain node01 --ignore-daemonsets --force
```

##### Upgrade the worker node to the exact version v1.20.0
先遠端至要更新節點
```bash
# ssh node01
# apt install kubeadm=1.20.0-00
# kubeadm upgrade apply v1.20.0
# kubeadm upgrade node
# apt install kubelet=1.20.0-00
# kubectl uncordon node01
```

## Backup and Restore Methods
待補...