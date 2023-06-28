## limit resource

```yaml
...
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 1G
        reservations:
          cpus: '0.2'
          memory: 300M
```

## scaling service

但是這不應該設置 container name 因為會導致名稱相同的衝突，預設上會將其字段忽略
```yaml
...
    deploy:
      replicas: 2
    ports:
      - "8080-8081:80"
```

port 部分這樣使服務可以，自動將兩個實例映射 8080、8081 port 出來


如何在一般的 docker-compose 生效上面的進階用法，如下使用 `--compatibility` 方式

```bash
docker-compose --compatibility up -d 
```
