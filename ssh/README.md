1. 如何使用 AWS Private Key 連線至 EC2，做一個 Key 的替換

```bash
$ ssh-keygen -f PRIVATE_KEY.pem -y | tee -a .ssh/authorized_keys
# PRIVATE_KEY.pem 權限因為 600
```

這邊使用 `-y` 產生相對應的 public key，然後將其資料放置 `.ssh/authorized_keys` 檔案，以便認證
