# Application Lifecycle Management
## Rolling updates and Rollbacks

###### Inspect the deployment and identify the current strategy
```bash
# kubectl describe deploy frontend
...
StrategyType:           RollingUpdate
...
```

- PODs are upgraded few at a time

當變換 Image 時，有時會訪問到舊的 POD
```
Hello, Application Version: v2 ; Color: green OK

Hello, Application Version: v1 ; Color: blue OK

Hello, Application Version: v1 ; Color: blue OK

Hello, Application Version: v2 ; Color: green OK

Hello, Application Version: v1 ; Color: blue OK

Hello, Application Version: v2 ; Color: green OK

Hello, Application Version: v2 ; Color: green OK

Hello, Application Version: v2 ; Color: green O
```

##### Up to how many PODs can be down for upgrade at a time
Consider the current strategy settings and number of PODs - 4

- 1


##### Change the deployment strategy to `Recreate`
Do not delete and re-create the deployment. Only update the strategy type for the existing deployment.

```yml
...
strategy:
    type: Recreate
...
```

一次刪除所有 POD，再建立新的 POD

## Test Commands and Arguments

Create a pod with the ubuntu image to run a container to sleep for 5000 seconds. Modify the file ubuntu-sleeper-2.yaml.
Note: Only make the necessary changes. Do not modify the name.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper-2
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command:
    - sleep
    - "5000"
```


##### What command is run at container startup?
Assume the image was created from the Dockerfile in this folder

```bash
FROM python:3.6-alpine

RUN pip install flask

COPY . /opt/

EXPOSE 8080

WORKDIR /opt

ENTRYPOINT ["python", "app.py"]

CMD ["--color", "red"]

# python app.py --color red
```

##### Create a pod with the given specifications. By default it displays a blue background. Set the given command line arguments to change it to green

```bash
kubectl run webapp-green --image=kodekloud/webapp-color --restart=Never --dry-run=client o yaml  pod.yml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: webapp-green
  name: webapp-green
spec:
  containers:
  - image: kodekloud/webapp-color
    name: webapp-green
    args: [ "--color=green" ]
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

|Description | Docker field name |Kubernetes field name|
|---|---|---|
|The command run by the container | Entrypoint | command|
|The arguments passed to the command | Cmd | args|


如果要覆蓋默認的 `Entrypoint` 與 `Cmd`，需要遵循如下規則：

- 如果在容器配置中沒有設置 `command` 或者 `args`，那麼將使用 `Docker` 鏡像自帶的命令及其參數。

- 如果在容器配置中只設置了 `command` 但是沒有設置 `args`，那麼容器啟動時只會執行該命令， `Docker` 鏡像中自帶的命令及其參數會被忽略。

- 如果在容器配置中只設置了 `args`，那麼 `Docker` 鏡像中自帶的命令會使用該新參數作為其執行時的參數。

- 如果在容器配置中同時設置了 `command` 與 `args`，那麼 `Docker` 鏡像中自帶的命令及其參數會被忽略。容器啟動時只會執行配置中設置的命令，並使用配置中設置的參數作為命令的參數。


Example

|Image Entrypoint|Image Cmd|Container command|Container args|Command run|
|---|---|---|---|---|
|[/ep-1]|[foo bar]|not set|not set|[ep-1 foo bar]|
|[/ep-1]|[foo bar]|[/ep-2]|not set|[ep-2]|
|[/ep-1]|[foo bar]|not set|[zoo boo]|[ep-1 zoo boo]|
|[/ep-1] |[foo bar]|[/ep-2]|[zoo boo]|[ep-2 zoo boo]|

[官方資訊](https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/)

## Test Env Variables
##### Update the environment variable on the POD to display a green background

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-color
  namespace: default
spec:
  containers:
  - env: # this
    - name: APP_COLOR
      value: green 
    image: kodekloud/webapp-color
    imagePullPolicy: Always
    name: webapp-color
  dnsPolicy: ClusterFirst
```
##### How many ConfigMaps exist in the environment?
```bash
# kubectl get cm
```
##### Identify the database host from the config map db-config
查資訊

```bash
kubectl describe cm db-config
```

##### Create a new ConfigMap for the webapp-color POD. Use the spec given below.

- ConfigName Name: webapp-config-map
- Data: APP_COLOR=darkblue

```bash
# kubectl create configmap webapp-config-map --from-literal=APP_COLOR=darkblue
```

##### Update the environment variable on the POD to use the newly created ConfigMap

- Pod Name: webapp-color
- EnvFrom: webapp-config-map

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: webapp-color
  name: webapp-color
  namespace: default
spec:
  containers:
  - image: kodekloud/webapp-color
    imagePullPolicy: Always
    name: webapp-color
    envFrom:
      - configMapRef:
          name: webapp-config-map
```

## Test Secrets

##### How many Secrets exist on the system?

```bash
kubectl get secrets
```

##### How many secrets are defined in the default-token secret?

```bash
# kubectl describe secrets default-token-spjv8
Name:         default-token-spjv8
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: default
              kubernetes.io/service-account.uid: 4b55fcf6-8152-44ad-9099-6df288e9c26a

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1066 bytes
namespace:  7 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IndoMlpNWUdUdWM4SUZhNERHSEozbG9mcVgxX0FlN3pMS3M1TXhJX0FvcUkifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlZmF1bHQtdG9rZW4tc3BqdjgiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjRiNTVmY2Y2LTgxNTItNDRhZC05MDk5LTZkZjI4OGU5YzI2YSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlZmF1bHQifQ.W6B9l424gw1p3_Pp-e9clX2hzrnjzyMCU0Htz_As9Bxfu-FPntSFbIws_1vpElwqQqUgJd8bH6ecRKYhqo6Klx_v-QP_SZRAE8Nta2mlHLqEL-RTy87Js4UAer4a9Oyps0mdIzCSN9KgvbwzoaU57eS45o6qwsdJJ6GF-VaZwRr44vCzwT2wKygCu1kFmZthDdFnnxqi5pUf7LeyKxrGVYblRKAc5nOQPOnkWTUSGC_OWfsSEeTgs5MV9FaaBrfh61PaXgNWOi4WJuvjqf7drmMUKDW1gkQXnGZZ3UsW3hY35HUXJfs_IJxGGPX4JucWz53dJ6FKzQq6ZYRLkJnq6Q
```

##### What is the type of the default-token secret?
- kubernetes.io/service-account-token

##### Which of the following is not a secret data defined in default-token secret?
- Type


##### We are going to deploy an application with the below architecture We have already deployed the required pods and services. Check out the pods and services created. Check out the web application using the Webapp MySQL link above your terminal, next to the Quiz Portal Link.

![](https://3e86fa8f76f34b9e.labs.kodekloud.com/images/kubernetes-ckad-secrets-webapp.png)

##### The reason the application is failed is because we have not created the secrets yet. Create a new secret named db-secret with the data given below.

官方提供很多的類型（Type）指定數據內容

|Builtin Type	|Usage|
|---|---|
|Opaque	arbitrary user-defined data
|kubernetes.io/service-account-token	|service account token|
|kubernetes.io/dockercfg	|serialized ~/.dockercfg file|
|kubernetes.io/dockerconfigjson|	serialized ~/.docker/config.json file|
|kubernetes.io/basic-auth	|credentials for basic authentication|
|kubernetes.io/ssh-auth	|credentials for SSH authentication|
|kubernetes.io/tls	|data for a TLS client or server|
|bootstrap.kubernetes.io/token|	bootstrap token data|

```bash
kubectl create secret generic db-secret --from-literal=DB_Host=sql01 --from-literal=DB_User=root --from-literal=DB_Password=password123
```



[官方資訊](https://kubernetes.io/docs/concepts/configuration/secret/)

##### Configure webapp-pod to load environment variables from the newly created secret.

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: webapp-pod
  name: webapp-pod
  namespace: default
spec:
  containers:
  - image: kodekloud/simple-webapp-mysql
    imagePullPolicy: Always
    name: webapp
    envFrom: # this
      - secretRef:
          name: db-secret
```


## Multi Container PODS

##### Identify the number of containers running in the 'red' pod.
透過 READY 欄位知道

```bash
kubectl get pods -o wide
NAME   READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
red    3/3     Running   0          37s   10.244.1.5   node01   <none>           <none>
```

##### Create a multi-container pod with 2 containers.
- Name: yellow
- Container 1 Name: lemon
- Container 1 Image: busybox
- Container 2 Name: gold
- Container 2 Image: redis

```yaml
piVersion: v1
kind: Pod
metadata:
  name: yellow
spec:
  containers:
  - name: lemon
    image: busybox

  - name: gold
    image: redis
```
## Init Container 

##### Why is the initContainer terminated? What is the reason?
- The process completed successfully

##### How long after the creation of the POD will the application come up and be available to users?
- 30 min

##### Update the pod red to use an initContainer that uses the busybox image and sleeps for 20 seconds

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: red
  namespace: default
spec:
  containers:
  - command:
    - sh
    - -c
    - echo The app is running! && sleep 3600
    image: busybox:1.28
    imagePullPolicy: IfNotPresent
    name: red-container
  initContainers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', "sleep 20"]
```

[官方資源](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)