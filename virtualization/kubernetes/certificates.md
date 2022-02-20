1. CA
2. Api Server cert
3. Etcd server cert
4. Api -> Etcd
5. Api -> Kubelet
6. Scheduler -> Api
7. Controller-manager -> Api
8. Kubelet -> Api
9. Kubelet Server cert


```bash
/etc/kubernetes/pki$ ll
total 68
drwxr-xr-x 3 root root 4096 Feb 19 09:03 .
drwxr-xr-x 4 root root 4096 Feb 19 17:22 ..
-rw-r--r-- 1 root root 1294 Feb 19 09:03 apiserver.crt
-rw-r--r-- 1 root root 1155 Feb 19 09:03 apiserver-etcd-client.crt
-rw------- 1 root root 1675 Feb 19 09:03 apiserver-etcd-client.key
-rw------- 1 root root 1675 Feb 19 09:03 apiserver.key
-rw-r--r-- 1 root root 1164 Feb 19 09:03 apiserver-kubelet-client.crt
-rw------- 1 root root 1675 Feb 19 09:03 apiserver-kubelet-client.key
-rw-r--r-- 1 root root 1099 Feb 19 09:03 ca.crt
-rw------- 1 root root 1675 Feb 19 09:03 ca.key
drwxr-xr-x 2 root root 4096 Feb 19 09:03 etcd
-rw-r--r-- 1 root root 1115 Feb 19 09:03 front-proxy-ca.crt
-rw------- 1 root root 1679 Feb 19 09:03 front-proxy-ca.key
-rw-r--r-- 1 root root 1119 Feb 19 09:03 front-proxy-client.crt
-rw------- 1 root root 1675 Feb 19 09:03 front-proxy-client.key
-rw------- 1 root root 1675 Feb 19 09:03 sa.key
-rw------- 1 root root  451 Feb 19 09:03 sa.pub
```

- Api Server cert
  - apiserver.crt
- Api -> Etcd
  - apiserver-etcd-client.crt
- Api -> Kubelet
  - apiserver-kubelet-client.crt


```bash
/etc/kubernetes/pki/etcd$ ll
total 40
drwxr-xr-x 2 root root 4096 Feb 19 09:03 .
drwxr-xr-x 3 root root 4096 Feb 19 09:03 ..
-rw-r--r-- 1 root root 1086 Feb 19 09:03 ca.crt
-rw------- 1 root root 1679 Feb 19 09:03 ca.key
-rw-r--r-- 1 root root 1159 Feb 19 09:03 healthcheck-client.crt
-rw------- 1 root root 1679 Feb 19 09:03 healthcheck-client.key
-rw-r--r-- 1 root root 1212 Feb 19 09:03 peer.crt
-rw------- 1 root root 1675 Feb 19 09:03 peer.key
-rw-r--r-- 1 root root 1212 Feb 19 09:03 server.crt
-rw------- 1 root root 1675 Feb 19 09:03 server.key
```
- Etcd server cert
  - `/etcd` 目錄下  


- Scheduler -> Api
  - /etc/kubernetes/scheduler.conf
- Controller-manager -> Api
  - /etc/kubernetes/controller-manager.conf
- Kubelet -> Api
  - /etc/kubernetes/kubelet.conf
```bash
client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem
client-key: /var/lib/kubelet/pki/kubelet-client-current.pem
```


- Kubelet Server cert
```bash
sudo su -c "ls -l /var/lib/kubelet/pki/"
total 12
-rw------- 1 root root 2830 Feb 19 09:04 kubelet-client-2022-02-19-09-04-00.pem
lrwxrwxrwx 1 root root   59 Feb 19 09:04 kubelet-client-current.pem -> /var/lib/kubelet/pki/kubelet-client-2022-02-19-09-04-00.pem
-rw-r--r-- 1 root root 2287 Feb 19 09:04 kubelet.crt
-rw------- 1 root root 1679 Feb 19 09:04 kubelet.key
```

- https://kubernetes.io/zh/docs/setup/best-practices/certificates/
- https://www.youtube.com/watch?v=gXz4cq3PKdg&ab_channel=CNCF%5BCloudNativeComputingFoundation%5D
