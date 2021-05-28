使用 host 模式，Port 就不必映射。
- kurento-media-server
  - 8888/tcp Client API Port
  - 5000-5050/udp input data port

透過 KMS_MIN_PORT 和 KMS_MAX_PORT 限制傳入數據的 RTP Port 數量。
KMS_STUN_IP 和 KMS_STUN_PORT 分別對自行架設的 coturn 進行連線設置。
[kurento 配置](https://doc-kurento.readthedocs.io/en/stable/user/configuration.html)

openvidu
- 4443 是預設存取
DOMAIN_OR_PUBLIC_IP 不設置會是 localhost，在開發時最好使用本機 IP。
KMS_URIS 用來設置 kurento-media-server 端點位置

[openvidu 配置](https://docs.openvidu.io/en/2.17.0/reference-docs/openvidu-config/)
