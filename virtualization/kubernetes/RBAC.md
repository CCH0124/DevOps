- Roles/ClusterRoles
- RoleBinding/ClusterRoleBinding
- combining Roles and Binding
- `can-i` Test
- created user certificate
- used CSR K8s api signing

[doc](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

```
create Key -> create CSR -> API（Kubernetes）->download CRT from api -> use CRT+KEY
```


- 如果要授予對特定 namespace 中資源（如 service、pod）的訪問權限，可使用 *Role* 和 *RoleBinding*
- 如果想在幾個 namespace 中使用同一個 Role，請定義一個 *ClusterRole* 並使用 *RoleBinding* 將其綁定到 *subject*（User、ServiceAccount）
- 如果要授予對集群級別資源（node）或跨所有 namespace 的資源的訪問權限，可使用具有 *ClusterRoleBinding* 的 *ClusterRole*

定義的 verbe 差別是在可讀還是可寫單純的 RBAC 無法做到不能觀看其資源的限制
- get, list (read-only)
- create, update, patch, delete, deletecollection (read-write)

在一個 namespace 下可以包含多個 Role 和 RoleBinding 對象，集群級別也是可存在多個 ClusterRole 和 ClusterRoleBinding。一個使用者可以經由 RoleBinding 或 ClusterRoleBinding 關連至多個角色，並實現多重授權。

## ServiceAccount Permissions

有兩個存在的 namespace 分別是 `ns1` 和 `ns2`。建立一個 *ServiceAccount* `pipeline` 在那兩個 namespace 上，這些 SA 可查看整個集群幾乎所有內容。可以為此使用默認的 ClusterRole *view*。允許這些 SA 在 ns1 和 ns2 中創建和刪除 *Deployments* 資源。

```bash
# 使用預設提供的 view 來查看所有集群資訊
$ kubectl create clusterrolebinding pipeline-view --clusterrole=view --serviceaccount=ns1:pipeline --serviceaccount=ns2:pipeline
$ kubectl get clusterrolebindings.rbac.authorization.k8s.io pipeline-view -oyaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: "2022-03-27T11:23:13Z"
  name: pipeline-view
  resourceVersion: "6258"
  uid: d79a59af-ea36-4135-b81b-34ef43f767e4
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- kind: ServiceAccount
  name: pipeline
  namespace: ns1
- kind: ServiceAccount
  name: pipeline
  namespace: ns2
```

```bash
$ kubectl create clusterrole deploy-pipeline-manage --verb="create,delete" --resource=deployments
clusterrole.rbac.authorization.k8s.io/deploy-pipeline-manage created
$ kubectl get clusterrole deploy-pipeline-manage -oyaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  creationTimestamp: "2022-03-27T11:29:20Z"
  name: deploy-pipeline-manage
  resourceVersion: "6695"
  uid: 3de05f41-80ae-4cda-bb0c-bf722dfe3004
rules:
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - create
  - delete
```
  
```bash
  $ kubectl -n ns1 create rolebinding pipeline-deploy-manage --clusterrole=deploy-pipeline-manage --serviceaccount=ns1:pipeline
  $ kubectl -n ns2 create rolebinding pipeline-deploy-manage --clusterrole=deploy-pipeline-manage --serviceaccount=ns2:pipeline
  $ kubectl -n ns1 get rolebindings.rbac.authorization.k8s.io pipeline-deploy-manage -oyaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: "2022-03-27T11:32:23Z"
  name: pipeline-deploy-manage
  namespace: ns1
  resourceVersion: "6918"
  uid: 304a13fb-0e84-47ea-bd6e-71a80746d938
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: deploy-pipeline-manage
subjects:
- kind: ServiceAccount
  name: pipeline
  namespace: ns1
```
  
##  User Permissions
有一個存在的 namespace `applications`
1. 使用者 `smoke` 可以 `create`、`delete` *PODs*、*Deployments* 和 *StatefulSets* 在 `applications` namespace 上
2. 使用者 `smoke` 有 `view` 權限(在 K8s 預設 ClusterRole) 除了 `kube-system`
3. 使用者 `smoke` 可以在 `applications` namespace 上檢視 *secret*(不能檢視數據)
4. 使用 `kubectl auth can-i` 確認

```bash
# 建立 Pod、Deployment、statefulSet的權限，並將使用者綁定至該角色
$ kubectl -n applications create role smoke-resource-manage --verb="create,delete" --resource="pods,deployments,StatefulSets"
$ kubectl -n applications get role smoke-resource-manage -oyaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: "2022-03-27T11:50:18Z"
  name: smoke-resource-manage
  namespace: applications
  resourceVersion: "3069"
  uid: 373b684b-b992-47a1-8765-a3604a9ea44b
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - create
  - delete
- apiGroups:
  - apps
  resources:
  - deployments
  - statefulsets
  verbs:
  - create
  - delete
$ kubectl -n applications create rolebinding smoke-manage --role=smoke-resource-manage --user=smoke
$ kubectl -n applications get rolebindings.rbac.authorization.k8s.io smoke-manage -oyaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: "2022-03-27T11:52:52Z"
  name: smoke-manage
  namespace: applications
  resourceVersion: "3254"
  uid: 7597fc20-8b84-449b-b034-aaffa5bf89be
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: smoke-resource-manage
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: smoke
```

因為要壤 smoke 觀看所有的 ns (除了 kube-system 外)，因為使用 cluster 級別表示可以所有 ns 存取，因此使用 ns 級別進行定義
```bash
# kubectl get ns # 查看當前的 ns，並為每個 ns 設置一個權限讓 smoke 可存取(除了 kube-system 外)
$ kubectl -n applications create rolebinding smoke-view --clusterrole=view --user=smoke
$ kubectl -n default create rolebinding smoke-view --clusterrole=view --user=smoke
...
$ kubectl -n default get rolebindings.rbac.authorization.k8s.io smoke-view -oyaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: "2022-03-27T11:59:40Z"
  name: smoke-view
  namespace: default
  resourceVersion: "3741"
  uid: 09a86cf0-1b94-4ccc-9afd-f8b93b3fd944
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: smoke
```
實現只能列出 Secret 資源 names 並且不能觀看其內容的權限，但是用以下方式是沒辦法的

```bash
$ kubectl -n applications create role list-secret-smoke --verb=list --resource=secrets
role.rbac.authorization.k8s.io/list-secret-smoke created
$ kubectl -n applications create rolebinding list-secret-smoke --role=list-secret-smoke --user=smoke
```

## CertificateSigningRequests sign manually
K8s 中的使用者透過 CRT 和其中的 CN/CommonName 進行管理。集群 CA 需要簽署這些 CRT。
1. Create a KEY (Private Key) file
2. Create a CSR (CertificateSigningRequest) file for that KEY
3. Create a CRT (Certificate) by signing the CSR. Done using the CA (Certificate Authority) of the cluster

```bash
$ openssl genrsa -out /root/60099.key 2048
$ openssl req -new -key 60099.key -out 60099.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:
State or Province Name (full name) [Some-State]:
Locality Name (eg, city) []:
Organization Name (eg, company) [Internet Widgits Pty Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:60099@internal.users
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

上一步已簽發 CSR，接著簽發 60099.crt 生成 CRT。

Create a new context for kubectl named 60099@internal.users which uses this CRT to connect to K8s.

```bash
$ openssl x509 -req -in 60099.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out 60099.crt -days 365
Signature ok
subject=C = AU, ST = Some-State, O = Internet Widgits Pty Ltd, CN = 60099@internal.users
Getting CA Private Key
```
context 設定
```bash
$ kubectl config set-credentials 60099@internal.users --client-key=60099.key --client-certificate=60099.crt
User "60099@internal.users" set.
controlplane $ kubectl config set-context 60099@internal.users --cluster=kubernetes --user=60099@internal.users
Context "60099@internal.users" created.
$ kubectl --context=60099@internal.users get ns 
Error from server (Forbidden): namespaces is forbidden: User "60099@internal.users" cannot list resource "namespaces" in API group "" at the cluster scope
```
