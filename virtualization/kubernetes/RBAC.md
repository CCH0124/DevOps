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
