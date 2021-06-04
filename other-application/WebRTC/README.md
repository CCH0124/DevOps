# 環境架設

專案目錄結構
```bash=
/WebRTC$ tree -L 2
WebRTC/
├── README.md
├── coturn
│   └── turnserver.conf
├── docker-compose.yml
├── etc-kurento
│   ├── cert
│   ├── kurento.conf.json
│   ├── modules
│   └── sdp_pattern.txt
├── openvidu
│   ├── cdr
│   ├── cert
│   └── recordings
└── postgresql
    ├── postgresql.env
    └── schema.sql
```

服務的容器配置

```yaml=
version: "3.7"
services:
  kurento-media-server:
    image: kurento/kurento-media-server:latest
    network_mode: "host"
    volumes:
      - ./etc-kurento:/etc/kurento
    environment:
      - KMS_MIN_PORT=5000
      - KMS_MAX_PORT=5050
    pull_policy: always
    restart: unless-stopped
    depends_on:
      - coturn

  openvidu-server:
    image: openvidu/openvidu-server:2.17.1
    network_mode: "host"
    environment:
      - DOMAIN_OR_PUBLIC_IP=wicloudrtc.biotrd.net
      - OPENVIDU_SECRET=openvidu
      - KMS_URIS=["wss://100.100.13.52:8433/kurento"]
      - CERTIFICATE_TYPE=owncert
      - HTTPS_PORT=4443
      - OPENVIDU_RECORDING=true
      - OPENVIDU_RECORDING_PATH=/home/openvidu/recordings
      - OPENVIDU_CDR=true
      - OPENVIDU_CDR_PATH=/home/openvidu/cdr
      - OPENVIDU_RECORDING_PUBLIC_ACCESS=true
      - OPENVIDU_RECORDING_COMPOSED_URL=https://wicloudrtc.biotrd.net:4443
    volumes:
      - ./openvidu/recordings:/home/openvidu/recordings
      - ./openvidu/cdr:/home/openvidu/cdr
      - ./openvidu/cert/:/opt/openvidu/owncert
      - /var/run/docker.sock:/var/run/docker.sock
    pull_policy: always
    restart: unless-stopped
    depends_on:
      - kurento-media-server

  coturn:
    image: coturn/coturn
    network_mode: "host"
    restart: always
    volumes:
      - coturn-data:/var/lib/coturn
      - ./coturn/turnserver.conf:/etc/coturn/turnserver.conf

volumes:
  postgresql-data:
  coturn-data:
networks:
  frontend:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.16.238.0/24
  backend:
    internal: true
```

使用 host 模式，Port 就不必映射。
- kurento-media-server
  - 8888/tcp Client API Port
  - 5000-5050/udp input data port
- openvidu
    - 443 default access
- coturn
    - 3478 UDP and TCP (COTURN listens on port 3478 by default)
    - 40000(min-port) - 65535(max-port) UDP and TCP (WebRTC will randomly exchange media through any of these ports. TCP might be used if client network blocks UDP connections)

>openvidu 是來控制 kurento-media-server

## Kurento Service

Kurento 提供了 WebRTC 和 RTP 發送器和接收器、音頻/視頻混合器、media recording 等基礎。

![](https://doc-kurento.readthedocs.io/en/latest/_images/example-pipeline-browser-recorder.png "Simple Example of a Media Pipeline")

開發人員使用 Kurento 用所需的 Media Elements 控制 Media Pipeline，有效的完全定制結構，以符合需求。同時提供了一些內置模組，group communications、媒體格式的代碼轉換(transcoding)以及視/聽流的路由(routing)。

可以同時實現 Selective Forwarding Unit（SFU）和 Multipoint Conferencing Unit（MCU）應用程序體系結構。


![](https://doc-kurento.readthedocs.io/en/latest/_images/kurento-toolbox-basic.png "Some Media Elements provided out of the box by Kurento")

- WebRtcEndpoint
    - 能夠發送和接收 WebRTC 媒體流
- PlayerEndpoint
    - 可用於消費來自 RTSP、HTTP 或本地來源的媒體
- RecorderEndpoint
    - 可以將媒體流儲存到本地或遠端檔案系統中
- FaceOverlayFilter
    - 是一個簡單的 Computer Vision 示例，它可以檢測視頻流中人的面孔，並在其上方添加覆蓋圖像

![](https://doc-kurento.readthedocs.io/en/latest/_images/kurento-clients-connection.png "Connection of Kurento Java and JavaScript SDKs to Kurento Media Server")

使用 JSON-RPC 與 websocket 溝通。

### WebRTC
WebRTC 是一組協定和 API，透過對等連接為瀏覽器和行動應用程式提供及時通訊（RTC）功能。

![](https://doc-kurento.readthedocs.io/en/latest/_images/media-server-intro.png)

單純以對等方式連接，會有很多缺陷，因此需要一個中間組件進行像是Transcoding、Recording等操作，如下圖。從概念上講，WebRTC Media Server 是一種多媒體中間組件，當從來源到目的地移動時，媒體流量會經過該中間組件。

![](https://doc-kurento.readthedocs.io/en/latest/_images/media-server-capabilities.png)


- Group Communications
    - 在多個接收方之間分配一個對等方生成的媒體流，即充當 Multi-Conference Unit（MCU）。
- Mixing
    - 將多個傳入流轉換為一個複合流
- Transcoding
    - 在不兼容的客戶端之間即時調整編解碼器和格式
- Recording
    - 以持久的方式儲存媒體在對等連接之間交換

### Kurento Media Server
WebRTC Media Server 模型中可使用 Kurento Media Server（KMS）實現媒體傳輸、處理、記錄和回放。KMS 建立在 GStreamer 多媒體庫之上，並提供以下功能：
- Networked streaming protocols, including HTTP, RTP and WebRTC.
- Group communications (both MCU and SFU functionality) supporting media mixing and media routing/dispatching.
- Support Computer Vision and Augmented Reality algorithms
- Media storage that supports writing operations for WebM and MP4 and playing in all formats supported by [GStreamer](https://gstreamer.freedesktop.org/).
- Automatic media transcoding between any of the codecs supported by GStreamer, including VP8, H.264, H.263, AMR, OPUS, Speex, G.711, and more.

![](https://doc-kurento.readthedocs.io/en/latest/_images/kurento-media-server-intro.png)


### 配置檔
- /etc/kurento/kurento.conf.json
    - 主配置檔案。提供 Kurento Media Server 本身行為的設置
- /etc/kurento/modules/kurento/MediaElement.conf.ini
    - 各種 MediaElement 的通用參數
- /etc/kurento/modules/kurento/SdpEndpoint.conf.ini
    - SdpEndpoint 的音頻/視頻參數 (即 WebRtcEndpoint 和 RtpEndpoint)
- /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini
    - WebRtcEndpoint 的具體參數
- /etc/kurento/modules/kurento/HttpEndpoint.conf.ini
    - HttpEndpoint 的具體參數
- /etc/default/kurento-media-server
    - 該檔案由系統服務初始化檔案加載。定義一些環境變數，該變數會對發生崩潰時生成的日誌貨核心轉儲檔案等功能產生影響。

- WebRtcEndpoint 
    - 是通過 web 進行流媒體實時通訊(RTC)的輸入/輸出端。它基於瀏覽器實現了 WebRTC 技術
![](https://doc-kurento-zh.readthedocs.io/zh/latest/_images/PlayerEndpoint.png)
- RecorderEndpoint 
    - 是一個輸出端點，提供以可靠模式存儲內容的功能（不丟棄數據）。它包含用於音頻和視頻的媒體接收器
![](https://doc-kurento-zh.readthedocs.io/zh/latest/_images/RecorderEndpoint.png)

在 `kurento.conf.json` 中 `certificate` 是指定配至 WSS 的憑證位置。
```json=
    "secure": {
          "//": "Secure WebSocket port where API clients connect to control KMS",
          "//": "Set to 0 or comment out the line to disable Secure WebSocket access",
          "port": 8433,
          "//": "Path (absolute or relative to this config file) to the",
          "//": "concatenated certificate (chain) file(s) + private key, in PEM format",
          "certificate": "/etc/kurento/cert/cert+key.pem",
          "//": "Password for the private key, if one was set when the key was created",
          "//password": ""
        }
```

在路徑 `modules/kurento/WebRtcEndpoint.conf.ini` 下配置 `coturn` 位置
```bash=
stunServerAddress=10.31.48.193
stunServerPort=3478
```

- KMS_MIN_PORT 和 KMS_MAX_PORT 限制傳入數據的 RTP Port 數量。
- KMS_STUN_IP 和 KMS_STUN_PORT 分別對自行架設的 coturn 進行連線設置
    - 相當於在 `WebRtcEndpoint.conf.ini` 進行設置


詳細的[kurento 配置](https://doc-kurento.readthedocs.io/en/stable/user/configuration.html)可點擊該鏈結。

關於 WSS 的憑證使用 `mkcert` 這個工具其產生方式如下，詳細可參考此[鏈結](https://doc-kurento.readthedocs.io/en/latest/knowledge/selfsigned_certs.html#self-signed-certificates)
```bash=
# Generate new untrusted self-signed certificate files.
CAROOT="$PWD" mkcert -cert-file cert.pem -key-file key.pem \
    "127.0.0.1" \
    "::1"       \
    "localhost" \
    "*.test.local"

# Make a single file to be used with Kurento Media Server.
cat cert.pem key.pem > cert+key.pem

# Protect against writes.
chmod 440 *.pem
```

>Packet loss correction in Recorder，可參考 `/etc/kurento/modules/kurento/
RecorderEndpoint.conf.ini` 配置

## Openvidu Service
OpenVidu 是創建 Kurento 的同一團隊的一個新項目。它充當 Kurento Media Server 安裝的包裝，並封裝了其大多數功能，以大大簡化 WebRTC 的某些最典型用例，例如會議室。

- DOMAIN_OR_PUBLIC_IP 
    - 不設置會是 localhost，在開發時最好使用本機 IP，或是域名。
- OPENVIDU_SECRET
    - 連接　OpenVidu Server　時的密鑰
- KMS_URIS 
    - 用來設置 kurento-media-server 端點位置。
- OPENVIDU_RECORDING
    - 是否啟用[recording 模組](https://docs.openvidu.io/en/2.17.0/advanced-features/recording/)
    - 啟用的話會下載 openvidu/openvidu-recording 映像檔
- OPENVIDU_RECORDING_PATH
    - 將錄製的視頻檔案儲存在主機上的位置(預設 /home/openvidu/recordings)
- OPENVIDU_CDR=true
    - 是否要紀錄[詳細訊息](https://docs.openvidu.io/en/2.17.0/reference-docs/openvidu-server-cdr)
- OPENVIDU_CDR_PATH
    - 紀錄儲存位置(預設 /home/openvidu/cdr)
- CERTIFICATE_TYPE
    - 證書類型
    - 簽證方式可參考此[官方鏈結](https://docs.openvidu.io/en/2.17.0/deployment/deploying-on-premises/#1-self-signed-certificate)

更多詳細[openvidu 配置](https://docs.openvidu.io/en/2.17.0/reference-docs/openvidu-config/)可點擊該鏈結


## coturn Service


## Turn Server 分配流程
```bash=
TURN                                 TURN           Peer          Peer
  client                               server          A             B
    |-- Allocate request --------------->|             |             |
    |                                    |             |             |
    |<--------------- Allocate failure --|             |             |
    |                 (401 Unauthorized) |             |             |
    |                                    |             |             |
    |-- Allocate request --------------->|             |             |
    |                                    |             |             |
    |<---------- Allocate success resp --|             |             |
    |            (192.0.2.15:50000)      |             |             |
    //                                   //            //            //
    |                                    |             |             |
    |-- Refresh request ---------------->|             |             |
    |                                    |             |             |
    |<----------- Refresh success resp --|             |             |
    |                                    |             |             |

————————————————
```

```bash=
incoming packet message processed, error 401: Unauthorized
```
上述的 401 在第一次請求發生是正常的，不須做特別處裡。
當設置靜態使用者和密碼錯誤時也有可能發生 401

```bash=
4539: : session 001000000000000126: realm <xxxx.com> user <>: incoming packet message processed, error 4│ Keep-Alive for session '83427f63-ec8b-4171-8b72-8dc408cc0f7c'
01: Unauthorized
4540: : ERROR: check_stun_auth: Cannot find credentials of user <xxxxxx>                               │ Keep-Alive for session '83427f63-ec8b-4171-8b72-8dc408cc0f7c'
4540: : session 001000000000000126: realm <xxxx.com> user <wistron123>: incoming packet message processe│1:16:07.268041115     1 0x7fa040002e30 INFO    KurentoServerMethods ServerMethods.cpp:814:ping: WebSocket Ping/Pong wi
d, error 401: Unauthorized 
```
### 配置
如果要以資料庫儲存資訊可以新增以下
```yaml=
postgresql:
    image: postgres
    restart: unless-stopped
    volumes:
      - ./postgresql/schema.sql:/docker-entrypoint-initdb.d/schema.sql:ro
      - postgresql-data:/var/lib/postgresql/data
    env_file: 
      - postgresql/postgresql.env
    networks:
      - backend
volumes:
  postgresql-data:
networks:
  backend:
    internal: true
```

注意：在 coturn 服務中使用 `env_file` 引入  `postgresql/postgresql.env` 讓 coturn 知道該資料庫連線資訊。


目前沒有針對 coturn 進行配置，都以預設值進行建置，官方提供的[配置檔](https://github.com/coturn/coturn/blob/master/docker/coturn/turnserver.conf)

域設下配置的配置檔內容如下

```bash=
listening-port=3478
listening-ip=10.31.48.251
alt-listening-port=0
relay-ip=10.31.48.251
external-ip=10.31.48.251


min-port=49152
max-port=49155

no-tls
no-dtls
mobility
no-cli
verbose
fingerprint

#userdb=/var/db/turndb

#psql-userdb="host=postgresql dbname=coturn user=coturn password= connect_timeout=30"


log-file=/var/log/turn.log

syslog
```
