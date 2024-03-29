1. 登入倉庫，以 gitlab 為例
```bash
docker login ${DOMAIN:PORT}
```

2. 建置 image
```bash
docker build -f Dockerfile.prod -t frontend:c3079333 .
```

3. 打標籤
```bash
docker tag frontend:c3079333 ${DOMAIN:PORT}/{...}/{...}/frontend:c3079333
```

>Tag an image for a private repository
>To push an image to a private registry and not the central Docker registry you must tag it with the registry hostname and port (if needed).


```bash
$ docker images
REPOSITORY                                      TAG             IMAGE ID       CREATED          SIZE
frontend                                        c3079333        f03731910a09   23 minutes ago   54.5MB
${DOMAIN:PORT}/{...}/{...}/frontend:            c3079333        f03731910a09   23 minutes ago   54.5MB
```

4. 推送映像檔

```bash
docker push frontend:c3079333 ${DOMAIN:PORT}/{...}/{...}/frontend --all-tags
```
