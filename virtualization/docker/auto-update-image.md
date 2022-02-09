## watchtower
```bash
docker run -d --name watchtower --restart always -v /home/ubuntu/.docker/config.json:/config.json -v /var/run/docker.sock:/var/run/docker.sock containnrrr/watchtower -c fe be --interval 3600
```

`--interval` 每 3600 秒檢查，image 是否有被更新
`-c（-- cleanup）` 自動清除舊的 image ，避免占空間
`fe` 和 `be` 是指定要被監控的 *容器名稱*
