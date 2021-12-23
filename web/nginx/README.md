介紹可設定的參數。先前在工作時有實現前後端分離，其相關配置可參考此[鏈結](FE-BE.md)

## security headers
```nginx=
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src * data: 'unsafe-eval' 'unsafe-inline'" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header Permissions-Policy "geolocation 'self'; camera 'self'; speaker 'self';";
# Cookie
add_header  Set-Cookie "HttpOnly";
add_header  Set-Cookie "Secure";

#CORS
add_header 'Access-Control-Allow-Origin' '*';
add_header 'Access-Control-Allow-Methods' 'GET,POST,DELETE,PUT,OPTIONS';
add_header 'Access-Control-Allow-Headers' 'X-Requested-With, Content-Type, X-Codingpedia, requesttype, accept, access-control-allow-headers, authorization';
add_header 'Access-Control-Allow-Credentials' 'true';

```

1. X-Frame-Options
禁用網頁上的 `iframe` 來保護網頁免受 *clickjacking attack*。可以約束瀏覽器不要將網頁嵌入到 frame/iframe/embed 中。
- DENY : This will disables iframe features completely.
- SAMEORIGIN : iframe can be used only by someone on the same origin.
- ALLOW-FROM : This will allows pages to be put in iframes only from specific URLs.
2. X-XSS-Protection
防禦 Cross-Site Scripting attacks，當頁面檢測到反射 XSS 攻擊時，此設定標頭會阻止頁面加載。
- X-XSS-Protection: 0 : This will disables the filter entirely.
- X-XSS-Protection: 1 : This will enables the filter but only sanitizes potentially malicious scripts.
- X-XSS-Protection: 1; mode=block : This will enables the filter and completely blocks the page.
3. X-Content-Type-Options
約束瀏覽器遵循標頭中指示的 `MIME` 類型。禁用瀏覽器的 `Content-Type` 猜測行為。瀏覽器通常會根據響應頭 `Content-Type` 來分辨資源類型。有些資源的 `Content-Type` 是錯的或者未定義。這時，瀏覽器會啟用 `MIME-sniffing` 來猜測該資源的類型，解析內容並執行。
- nosniff 
4. Referrer-Policy
用於標識請求當前網頁的網頁地址。用於增加隱私保護。
- no-referrer：不允許被記錄
- origin：只記錄域名
- strict-origin：只有在 HTTPS -> HTTPS 之間才會被記錄下來。
- strict-origin-when-cross-origin：同源請求會發送完整的 URL。只要 `referer` 不同源，在 `cross-origin` 的請求就不會顯示 `referer` 完整的網址。
- no-referrer-when-downgrade(default)：同 strict-origin
- origin-when-cross-origin：對於同源的請求，會發送完整的 URL 作為引用地址，但是對於非同源請求僅發送檔案的來源。
- same-origin：對於同源請求會發送完整 URL，非同源請求則不發送 referer。
- unsafe-url：無論是同源請求還是非同源請求，都發送完整的 URL（移除參數訊息之後）作為引用地址。
5. Content-Security-Policy(CSP)
是 `X-XSS-Protection` 標頭的改進版本，CSP 指示瀏覽器加載允許在網站上加載的內容。詳細可參考此[鏈接](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/CSP)
6. Strict-Transport-Security
它告訴瀏覽器只能用 `HTTPS` 訪問當前資源，而不是 HTTP。
7. Permissions-Policy
允許網站控制可以在瀏覽器中使用哪些 API 或功能。其可限制的資源可參考此[鏈接](https://github.com/w3c/webappsec-permissions-policy/blob/main/features.md)
- `*`：在頁面和 `iframes` 裡面都允許
- self：在頁面上允許，在 `iframes` 內只允許同源資源使用
- src：僅在 `iframe` 內生效的屬性，只允許 `iframe` 內 `src` 屬性與設置頭相同的資源使用
- none：在頁面和內嵌中全部禁止
- <origin(s)>：允許在特定的 `origin` 中使用，多個 `origins` 可以用空格隔開。


## gzip

```nginx=
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml application/json application/javascript application/xml+rss application/atom+xml image/svg+xml;
```

## Nginx config

```nginx=
user www-data;
pid /run/nginx.pid;
worker_processes auto;
worker_rlimit_nofile 65535;

events {
	multi_accept on;
	worker_connections 65535;
}

http {
	charset utf-8;
	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	server_tokens off;
	log_not_found off;
	types_hash_max_size 2048;
	client_max_body_size 16M;

	# MIME
	include mime.types;
	default_type application/octet-stream;
	# log format，可針對需求去設置
        log_format json_combined escape=json 
	'{'
		'"@version": "1", '
		'"@timestamp": "$time_iso8601", '
		'"host": "$hostname", '
		'"type": "access", '
		'"request": {'
			'"method": "$request_method", '
			'"url": "$scheme://$host$request_uri", '
			'"httpVersion": "$server_protocol", '
 			'"query_string": "$query_string", '
#			'"geoip_city": "$geoip_city", '
#			'"geoip_lat": "$geoip_latitude", '
#			'"geoip_long": "$geoip_longitude", '
    			'"headers": {'
				'"accept-encoding": "$http_accept_encoding", '
				'"accept-language": "$http_accept_language", '
 				'"accept": "$http_accept", '
				'"content-type": "$content_type", '
				'"content-length": "$content_length", '
				'"host": "$host", '
				'"x-forwarded-for": "$http_x_forwarded_for", '
				'"user-agent": "$http_user_agent"'
			'},'
			'"remoteAddress": "$remote_addr"'
  		'},'
  		'"response": {'
			'"timestamp": "$time_iso8601", '
			'"statusCode": "$status", '
  			'"size": "$bytes_sent", '
			'"headers": {'
				'"cache-control": "$sent_http_cache_control", '
				'"content-type": "$sent_http_content_type", '
				'"vary": "$sent_http_vary"'
    			'},'
			'"responseTime": "$request_time", '
			'"upstreamTime": "$upstream_response_time"'
  		'}'
	'}';
	# logging
	access_log /var/log/nginx/access.log json_combined;
	error_log /var/log/nginx/error.log warn;

	# limits
	limit_req_log_level warn;
	limit_req_zone $binary_remote_addr zone=login:10m rate=10r/m;

	# SSL
#	ssl_session_timeout 1d;
#	ssl_session_cache shared:SSL:50m;
#	ssl_session_tickets off;

	# modern configuration
#	ssl_protocols TLSv1.2;
#	ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256;
#	ssl_prefer_server_ciphers on;

	# OCSP Stapling
#	ssl_stapling on;
#	ssl_stapling_verify on;
#	resolver 8.8.8.8 8.8.4.4 208.67.222.222 208.67.220.220 valid=60s;
#	resolver_timeout 2s;

	# load configs
	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}
```
