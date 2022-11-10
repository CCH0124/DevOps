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
```
