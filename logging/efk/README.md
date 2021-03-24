# docker-efk
Log collection
## fluent 配置檔範例 

```bash
$ ls fluent/conf/
read  socket
```
read 用於讀容器的日誌檔範例，無法明確知道是哪個容器傳送的 log，閱讀性沒 socket 方式高
socket 用於在 docker-compose 上配置將 log 透過 socket 方式傳至 fluentd
## Docker-compose 
```yaml
    logging:
      driver: fluentd
      options:
        fluentd-address: 192.168.101.129:24224
        tag: web-backend
```

## 注意
1. 配置檔名稱需要是 fluent-bit.conf，否則會出現無法讀取到檔案的問題
