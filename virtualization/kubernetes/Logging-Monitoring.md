# Logging and Monitoring

## Monitor
##### Let us deploy metrics-server to monitor the PODs and Nodes. Pull the git repository for the deployment files.
`git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git`


```bash
~/kubernetes-metrics-server# kubectl create -f .
```

##### Run the kubectl top node command and wait for a valid output.

```bash
# kubectl top node
NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
controlplane   348m         0%     951Mi           0%        
node01         255m         0%     594Mi           0%
```

```bash
# kubectl top pod # default namespace
NAME       CPU(cores)   MEMORY(bytes)   
elephant   42m          53Mi            
lion       3m           8Mi             
rabbit     114m         37Mi 
```

```bash
# kubectl top pod -A # -A 所有 namsespace
```

## Logging

##### A user - USER5 - has expressed concerns accessing the application. Identify the cause of the issue. Inspect the logs of the POD

```bash
# kubectl logs webapp-1 | grep "USER5" 
```
原因是 Account Locked due to Many Failed Attempts