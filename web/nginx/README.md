介紹可設定的參數。先前在工作時有實現前後端分離，其相關配置可參考此[鏈結](FE-BE.md)

## security headers
```nginx=
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src * data: 'unsafe-eval' 'unsafe-inline'" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
```

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