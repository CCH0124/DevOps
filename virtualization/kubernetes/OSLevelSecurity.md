## SecurityContext
- Privileged
  - 表示容器 user 0(root) 直接應射到 host 上的 user 0(root)
- PrivilegeEscalation
  - 該行程可以獲得比其父行程更多的特權

官方範例
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo-2
spec:
  securityContext: # POD 級別，表示所有容器都要遵守
    runAsUser: 1000
  containers:
  - name: sec-ctx-demo-2
    image: gcr.io/google-samples/node-hello:1.0
    securityContext: # 容器級別
      runAsUser: 2000
      allowPrivilegeEscalation: false
```

### Example

創建一個 image 為 nginx:alpine 名為 `prime`  的 Pod，容器應該以 `privileged` 運行。
```bash
kubectl run prime --image=nginx:alpine -oyaml --dry-run=client --command -- sh -c 'sleep 1d' > pod.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: prime
  name: prime
spec:
  containers:
  - command:
    - sh
    - -c
    - sleep 1d
    image: nginx:alpine
    name: prime
    securityContext:
      privileged: true
  dnsPolicy: ClusterFirst
  restartPolicy: Always
```

有一個現有的 `StatefulSet` yaml 檔，它應該以 `privileged` 身份運行，但似乎無法成功。修正該 yaml

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: habanero
spec:
  selector:
    matchLabels:
      app: habanero
  serviceName: habanero
  replicas: 1
  template:
    metadata:
      labels:
        app: habanero
    spec:
 #     securityContext:
 #       privileged: true
      containers:
        - name: habanero
          image: nginx:alpine
          command:
            - sh
            - -c
            - apk add iptables && sleep 1d
          securityContext:
            privileged: true
```
## Pod Security Policy
- Cluster level 資源
- 控制器使用此條件檢查要被運行的 POD

在 *kube-apiserver* 中 `--enable-admission-plugins` 需添加 `PodSecurityPolicy` 字段。
