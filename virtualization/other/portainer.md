# PORTAINER

[portainer install 和一些介紹](https://documentation.portainer.io/quickstart/)

針對 Docker 1.20 以上
```bash=
$ sudo systemctl status docker.service
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: failed (Result: exit-code) since Wed 2021-06-02 09:19:54 UTC; 8s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
    Process: 63837 ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock (code=exited, status=1/FAILURE)
   Main PID: 63837 (code=exited, status=1/FAILURE)

Jun 02 09:19:54 ip-100-100-7-147 systemd[1]: docker.service: Scheduled restart job, restart counter is at 3.
Jun 02 09:19:54 ip-100-100-7-147 systemd[1]: Stopped Docker Application Container Engine.
Jun 02 09:19:54 ip-100-100-7-147 systemd[1]: docker.service: Start request repeated too quickly.
Jun 02 09:19:54 ip-100-100-7-147 systemd[1]: docker.service: Failed with result 'exit-code'.
Jun 02 09:19:54 ip-100-100-7-147 systemd[1]: Failed to start Docker Application Container Engine.
```


因為在 `/etc/docker/daemon.json` 新增 `hosts` 字段導致無法啟動，只需將此檔案刪除重啟 docker 服務即可。


```bash=
$ sudo vim /etv/docker/daemon.json
 {"hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"]}
$ sudo vim /etc/systemd/system/docker.service.d/override.conf
 [Service]
 ExecStart=
 ExecStart=/usr/bin/dockerd
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

```bash=
# vim /usr/lib/systemd/system/docker.service
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

測試
```bash=
docker -H tcp://IP:2375 images
```


[ref](https://deepzz.com/post/dockerd-and-docker-remote-api.html)


![](https://i.imgur.com/nCeQw9b.png)

註冊部分，因為沒有使用集群在運行，選擇 `Directly connect to the Docker API`。



