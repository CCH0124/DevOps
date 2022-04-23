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
