`app` 有一些 pod，對於這些 Pod 的所有傳出流量，我們需要一個名為 `deny-out` 的默認拒絕 NetworkPolicy。它仍應允許 TCP 和 UDP 端口 53 上的 DNS 流量。

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-out
  namespace: app
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP
```

在不同 namespace 下依舊可以存取。

兩個 namespace (space1、space2)。
- space1
  - 所有 Pod 限制為只有 Namespace space2 中的 Pod 的傳出流量
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np
  namespace: space1
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: space2 
  - ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP
```
- space2
  - space2 中所有 Pod 限制為只接收來自 Namespace space1 中 Pod 的傳入流量
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np
  namespace: space2
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: space1
  - ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP
```
