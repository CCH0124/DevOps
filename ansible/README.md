# Ansible

**特性**

- 模組化
- 支援自定義模組
- 基於 OpenSSH 的安全

![](https://i1.kknews.cc/SIG=2lsg1pn/432s0000r289o0375po0.jpg)

![](https://i.imgur.com/uP12RK3.png)

**主要組成**

- playbooks
    - 任務劇本，編排定義 Ansible 任務集合的配置檔案，由 Ansible 順序一次執行，通常是 JSON 或 YAML 檔案
- inventory
    - Ansible 管理主機清單 `/etc/ansible/hosts`
- modules
    - Ansible 執行指令功能模組，多數為內建核心模組，也可自定義
- plugin
    - 模組擴充功能
- API
    - 第三方程序調用的程式編碼接口
- Ansible
    - 是 ansible 命令工具，核心執行工具

- Ansible 命令執行來源
    - USER，普通用戶或管理員
        - USER -> Ansible Playbook -> Ansible
    - CMDB
    - Cloud
- 利用 Ansible 實現管理方式
    - Ad-Hoc 即 Ansible 命令，臨時場景
    - Ansible-Playbook 長期規劃好的，大型專案
- Ansible-Playbook 執行過程
    - 任務集合都會寫在裡面
    - 逐條執行，可以撰寫迴圈或分支
- Ansible 操作對象
    - 主機
    - 網路設備

## 相關檔案

- `/etc/ansible/ansible.cfg` 主配置檔案，配置 ansible 
- `/etc/ansible/hosts` 要被管理的主機清單
- `/etc/ansible/roles/` 存放角色的目錄

```bash=
$ ls -al /etc/ansible/
total 32
drwxr-xr-x  2 root root  4096 Oct 27 14:46 .
drwxr-xr-x 93 root root  4096 Oct 27 14:45 ..
-rw-r--r--  1 root root 19985 Mar  5  2020 ansible.cfg # 主配置檔案，配置 ansible 工作特性
-rw-r--r--  1 root root   982 Dec 18  2018 hosts # 主機清單
```

`/etc/ansible/ansible.cfg` 中大多內容無須修改
```bash=
# /etc/ansible/ansible.cfg
[defaults]
#inventory       = /etc/ansible/hosts # 主機清單位置
#library         = ~/.ansible/plugins/modules:/usr/share/ansible/plugins/modules 模組存放
#module_utils    = ~/.ansible/plugins/module_utils:/usr/share/ansible/plugins/module_utils
#remote_tmp      = ~/.ansible/tmp # 臨時命令檔案存放在遠端主機目錄
#local_tmp       = ~/.ansible/tmp # 本機臨時命令檔案存放位置
#forks           = 5 # 預設併發數量
#poll_interval   = 0.001
#ask_pass        = False
#transport       = smart
```

## 主機清單 inventory
ansible 主要任務是批量主機操做，為了方便使用其中部分的主機，可以再 inventory file 終將其分組命名。

預設的 inventory file 為 `/etc/ansible/hosts`，inventory file 可以有很多個，也可以透過 Dynamic Inventory 來動態生成。

如果當前主機並非以預設 SSH Port，則可以在主機的 IP 或域名加上 Port 號進行識別。

## 主配置檔案
可依照環境做更改。`local_tmp` 為執行 ansible 動作時產生腳本的存放位置，當然其也會傳送到被控制端主機上位置為 `remote_tmp`。`forks` 是併行運行的數量設置。`remote_port` 預設遠端端口。 `host_key_checking` 可以註銷該註解，因為再執行 ansible 相關控制操作時，其會根據 SSH key 做動作    

```shell=
$ vi /etc/ansible/ansible.cfg
...
[defaults]

# some basic default values...

#inventory      = /etc/ansible/hosts
#library        = /usr/share/my_modules/
#module_utils   = /usr/share/my_module_utils/
#remote_tmp     = ~/.ansible/tmp
#local_tmp      = ~/.ansible/tmp
#forks          = 5
#poll_interval  = 15
#sudo_user      = root 
#ask_sudo_pass = True
#ask_pass      = True
#transport      = smart
#remote_port    = 22 
#module_lang    = C
#module_set_locale = False
...
# uncomment this to disable SSH key host checking
#host_key_checking = False
...
```

## Ansible 命令執行過程
1. 加載自己的配置檔案，預設是 `/etc/ansible/ansible.cfg`
2. 加載自己對應的模組
3. 透過 ansible 將模組或指令生成對應的臨時 py 檔案，並將其傳送至遠端服務器的對應執行用戶 `$HONE/.ansible/tmp/ansible-temp-[0-9]/xxx.py`
4. 給檔案 `+x` 執行
5. 執行返回結果
6. 刪除臨時 py 檔案
## ansible 相關工具
```shell=
$ ls -l /usr/bin/ans*
lrwxrwxrwx 1 root root 68 Mar 16  2020 /usr/bin/ansible -> ../lib/python3/dist-packages/ansible/cli/scripts/ansible_cli_stub.py # 主程式
lrwxrwxrwx 1 root root  7 Mar 16  2020 /usr/bin/ansible-config -> ansible 
lrwxrwxrwx 1 root root 79 Mar 16  2020 /usr/bin/ansible-connection -> ../lib/python3/dist-packages/ansible/cli/scripts/ansible_connection_cli_stub.py
lrwxrwxrwx 1 root root  7 Mar 16  2020 /usr/bin/ansible-console -> ansible # 與用戶交互執行工具
lrwxrwxrwx 1 root root  7 Mar 16  2020 /usr/bin/ansible-doc -> ansible # 配置檔案
lrwxrwxrwx 1 root root  7 Mar 16  2020 /usr/bin/ansible-galaxy -> ansible 
lrwxrwxrwx 1 root root  7 Mar 16  2020 /usr/bin/ansible-inventory -> ansible
lrwxrwxrwx 1 root root  7 Mar 16  2020 /usr/bin/ansible-playbook -> ansible# 訂製自動化任務
lrwxrwxrwx 1 root root  7 Mar 16  2020 /usr/bin/ansible-pull -> ansible # 遠端執行命令
lrwxrwxrwx 1 root root  7 Mar 16  2020 /usr/bin/ansible-vault -> ansible # 檔案加密工具
```

Ad-Hoc 就是利用 ansible 指令，通常用於臨時使用場景；Ansible-playbook 主要適用於長期規劃好的大型專案場景。


### ansible-doc

```bash=
$ ansible-doc -s ping
- name: Try to connect to host, verify a usable python and return `pong' on success
  ping:
      data:                  # Data to return for the `ping' return value. If this parameter is set to `crash', the module will cause an exception.
```

### ansible
ansible 透過 SSH 時限配置管理、應用部署、任務執行等功能。建議配置 ansible 端能基於密要認證方式連接各個貝管理節點

```bash
ansible <host-pattern> [-m module_name] [-a args]
# <host-pattern> 會對應 /etc/ansible/hosts 建立的資訊，指定為 all 時表示所有
```
**範例**

使用模組 ping
```shell=
$ ansible 192.168.134.145 -m ping
[WARNING]: provided hosts list is empty, only localhost is available. Note thatthe implicit localhost does not match 'all'
[WARNING]: Could not match supplied host pattern, ignoring: 192.168.134.145
```
因為不再清單中嘗試加入 inventory file 中

```shell=
cch@cch:~$ vim /etc/ansible/hosts
cch@cch:~$ sudo vim /etc/ansible/hosts
[sudo] password for cch:
cch@cch:~$ tail -f /etc/ansible/hosts
#db01.intranet.mydomain.net
#db02.intranet.mydomain.net
#10.25.1.56
#10.25.1.57

# Here's another example of host ranges, this time there are no
# leading 0s:

#db-[99:101]-node.example.com
192.168.134.145
```

在試一次，這次可以發現似乎可以做遠端的動作，但是還是有錯誤，因為這邊沒辦法說我要管理你就管理。


```shell=
$ sudo ansible 192.168.134.145 -m ping
The authenticity of host '192.168.134.145 (192.168.134.145)' can't be established.
ECDSA key fingerprint is SHA256:ox1k4rBtnefd1Hu3cwVYctcNWRThjt7PNNKKt2JEEeA.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
192.168.134.145 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Warning: Permanently added '192.168.134.145' (ECDSA) to the list of known hosts.\r\nroot@192.168.134.145: Permission denied (publickey,password).",
    "unreachab
```

使用 `-k` 參數帶 key 驗證，但如果指定的 host-pattern 有多個主機則不適用。透過  `ssh-keygen` 產生金鑰並使用 `ssh-copy-id` 至每台被管理主機。這樣可以節省打密碼的步驟。

```shell=
cch@cch:~$ ansible 192.168.134.145 -m ping -k
SSH password:
192.168.134.145 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```
```shell
$ ansible all -m ping -k # all 表示主機清單中所有
```
**分組**
```shell=
cch@cch:~$ sudo vim /etc/ansible/hosts
cch@cch:~$ tail -f /etc/ansible/hosts
#10.25.1.57

# Here's another example of host ranges, this time there are no
# leading 0s:

#db-[99:101]-node.example.com
[webserver]
192.168.134.145 # 如果 SSH 的 Port 非預設可帶 Port
[dbserver]
192.168.134.144
```

其中分組可以針對連續 IP 做簡易表示 `192.168.134.14[4:5]`，如果針對 DNS 的話也可以實現 `db-[a:c].example.com`。

```shell=
$ ansible dbserver -m ping -k
SSH password:
192.168.134.144 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

```shell=
$ ansible dbserver -m command -u cch -k -a 'ls -al'
SSH password:
192.168.134.144 | CHANGED | rc=0 >>
total 32
drwxr-xr-x 4 cch  cch  4096 Oct 27 15:31 .
drwxr-xr-x 3 root root 4096 Oct 27 09:07 ..
drwx------ 3 cch  cch  4096 Oct 27 15:31 .ansible
-rw------- 1 cch  cch   138 Oct 27 09:34 .bash_history
-rw-r--r-- 1 cch  cch   220 Feb 25  2020 .bash_logout
-rw-r--r-- 1 cch  cch  3771 Feb 25  2020 .bashrc
drwx------ 2 cch  cch  4096 Oct 27 09:32 .cache
-rw-r--r-- 1 cch  cch   807 Feb 25  2020 .profile
-rw-r--r-- 1 cch  cch     0 Oct 27 09:32 .sudo_as_admin_successful
```

**host-pattern**
- all 
    - 表示所有
- \*
    - 通配符
    - 192.168.134.*
- :
    - OR 的關係
- :&
    - AND 關係
    - 交集
- :!
    - 反向
- 正規表達式

### ansible-galaxy
- 連接 ansible 官網下載相對應的 roles
roles 可以是把 playbook 再整合的一個名詞
```shell=
ansible-galaxy list # 列出以安裝的 galaxy
ansible-galaxy instll ... # 安裝
ansible-galaxy remove ... # 移除
```

嘗試下載 nginx

```shell
$ cd .ansible/
cch@LAPTOP-J7ES249S:~/.ansible$ ls
cp  galaxy_token  roles  tmp
cch@LAPTOP-J7ES249S:~/.ansible$ tree roles/
roles/
└── geerlingguy.nginx
    ├── LICENSE
    ├── README.md
...
$ ansible-galaxy remove geerlingguy.nginx # 刪除
- successfully removed geerlingguy.nginx
```

### ansible-pull
推送命令至遠端，效率提升，維運要求高

### Ansible-vault
管理加密解密 yml 檔案

```shell
$ ansible-vault encrypt hello.yml 
New Vault password: 
Confirm New Vault password: 
Encryption successful
cch@LAPTOP-J7ES249S:/mnt/c/Users/ASUS/Desktop/ansible$ cat hello.yml 
$ANSIBLE_VAULT;1.1;AES256
66383231303264626562363439326239336137366536623731646138613834336665653665643233
663...162
$ ansible-vault view hello.yml # 查看
$ ansible-vault edit hello.yml # 編輯
$ ansible-vault rekey hello.yml # 重新設置密碼
```
這樣無法直接執行 playbook，需要透過解密

```shell
$ ansible-vault decrypt hello.yml        
```

### Ansible-console
```shell
$ ansible-console 
Welcome to the ansible console.
Type help or ? to list commands.

cch@all (3)[f:5]$ # all 表示所有清單，(3) 表示清單中主機數，[f:5] 表示可以同時執行主機數量
cch@all (3)[f:5]$ cd webserver # 切換清單
cch@webserver (2)[f:5]$
cch@webserver (2)[f:5]$ command hostname # 執行 command 模組
192.168.134.145 | CHANGED | rc=0 >>
node01
192.168.134.143 | CHANGED | rc=0 >>
cch
```
相似於前面 ansible 指令的做法，只是環境不同而以


## 常用模組

預設使用 `command` 可以藉由配置看要切換成 shell 或是 script 等
```bash
# Default module to use when running ad-hoc commands
#module_name = command
```
### command
- 對於管道或重定向、變量等是不支援的
- 預設
```shell=
cch@cch:~$ ansible all -a 'mkdir ansible-test'
[WARNING]: Consider using the file module with state=directory rather than
running 'mkdir'.  If you need to use command because file is insufficient you
can add 'warn: false' to this command task or set 'command_warnings=False' in
ansible.cfg to get rid of this message.
192.168.134.145 | CHANGED | rc=0 >>

192.168.134.144 | CHANGED | rc=0 >>
cch@cch:~$ ansible all -a 'ls -l '
192.168.134.145 | CHANGED | rc=0 >>
total 4
drwxrwxr-x 2 cch cch 4096 Oct 28 07:45 ansible-test
192.168.134.144 | CHANGED | rc=0 >>
total 4
drwxrwxr-x 2 cch cch 4096 Oct 28 07:45 ansible-test
```

### shell
```shell=
cch@cch:~$ ansible all -m shell -a 'ls | wc -l'
192.168.134.144 | CHANGED | rc=0 >>
1
192.168.134.145 | CHANGED | rc=0 >>
1
```
### script
在遠端主機上執行 ansible 主機上的 script
```shell=
cch@cch:~$ cat host.sh
#!/bin/bash
hostname
cch@cch:~$ ansible all -m script -a './host.sh'
192.168.134.144 | CHANGED => {
    "changed": true,
    "rc": 0,
    "stderr": "Shared connection to 192.168.134.144 closed.\r\n",
    "stderr_lines": [
        "Shared connection to 192.168.134.144 closed."
    ],
    "stdout": "node02\r\n",
    "stdout_lines": [
        "node02"
    ]
}
192.168.134.145 | CHANGED => {
    "changed": true,
    "rc": 0,
    "stderr": "Shared connection to 192.168.134.145 closed.\r\n",
    "stderr_lines": [
        "Shared connection to 192.168.134.145 closed."
    ],
    "stdout": "node01\r\n",
    "stdout_lines": [
        "node01"
    ]
}
```

### Copy
- 主控端傳送資料到被控端，可解由 `owner` 和 `mode` 設定權限
```shell=
cch@cch:~$ echo "test copy module" > test.txt
cch@cch:~$ ansible all -m copy -a 'src=./test.txt dest=./ backup=yes' # backup 用於相同檔案時可備份
192.168.134.144 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": true,
    "checksum": "0fea61d731a0182405504ce46b3a0e5ebc417b11",
    "dest": "./test.txt",
    "gid": 1000,
    "group": "cch",
    "md5sum": "14b06cffb761c9a1e38f04d9eeb3fad7",
    "mode": "0664",
    "owner": "cch",
    "size": 17,
    "src": "/home/cch/.ansible/tmp/ansible-tmp-1603872081.4961643-87744486105125/source",
    "state": "file",
    "uid": 1000
}
...
cch@cch:~$ ansible all -a 'ls '
192.168.134.145 | CHANGED | rc=0 >>
ansible-test
test.txt
192.168.134.144 | CHANGED | rc=0 >>
ansible-test
test.txt
```
### fetch
- 從被控端抓資料到主控端

上述模組的參數可藉由 `ansible-doc -s module_name` 查看

```shell=
$ ansible all -m copy -a 'content="Hello" dest=./content.txt' # 為每個被控端產生 content.txt 檔案內容從 content 定義
...
cch@cch:~$ ansible all -m shell -a 'cat ./content.txt'
192.168.134.144 | CHANGED | rc=0 >>
Hello
192.168.134.145 | CHANGED | rc=0 >>
Hello
cch@cch:~$ ansible all -m fetch -a 'src=./content.txt dest=./data' # src 是被控端；dest 是控制端
...
cch@cch:~$ ls data/
192.168.134.144  192.168.134.145
```
似乎無法使用通配符
### File
- 設置檔案、屬性
- `state` 參數
    - touch 建立檔案
    - absent 刪除操作
    - directory 建立目錄
    - link 建立連接
```shell=
cch@cch:~$ ansible all -m file -a 'name=./ansible-test/file.txt state=touch' # 建立
192.168.134.144 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": true,
    "dest": "./ansible-test/file.txt",
    "gid": 1000,
    "group": "cch",
    "mode": "0664",
    "owner": "cch",
    "size": 0,
    "state": "file",
    "uid": 1000
}
...
cch@cch:~$ ansible all  -a 'ls ./ansible-test/'
192.168.134.144 | CHANGED | rc=0 >>
file.txt
192.168.134.145 | CHANGED | rc=0 >>
file.txt
cch@cch:~$ ansible all -m file -a 'name=./ansible-test/file.txt state=absent' # 刪除
cch@cch:~$ ansible all  -a 'ls ./ansible-test/'
192.168.134.144 | CHANGED | rc=0 >>

192.168.134.145 | CHANGED | rc=0 >>

```
### unarchive
可實現解壓縮。
- 將 ansible 主機上的壓縮包傳到被控端主機後解壓縮至特定目錄，copy 設置為 yes
- 將被控端上的某壓縮包解壓至特定指定路徑，copy 設置為 no

```bash
ansible srv -m unarchive -a 'src=壓縮檔路徑 dest=被控端目標位置'
```

而 `archive` 則是壓縮模組。

### Hostname
```bash
ansible ${IP} -m hostname -a 'name=local.com'
```
### Cron
用於排程，期支援時間有 minute、hour、day、month、weekday
### Service
- 管理服務
```bash=
ansible all -m service -a "name=nginx state=stared"
```
### User
- 管理使用者

```bash
ansible dev -m user -a 'name=user1 comment="dev user" uid=3000 home=/app/user1 group=root'
```
### Group
- 管理群組

```bash
ansible dev -m group -a 'name=nginx gid=100 system=yes'
ansible dev -m group -a 'name=nginx state=absent'
```
## Ansible-playbook
嘗試定義任務，[hello.yml 範例](hello.yml)

```shell
$ ansible-playbook hello.yml 

PLAY [webserver] *****************************************************************************
TASK [Gathering Facts] ***********************************************************************ok: [192.168.134.143]
ok: [192.168.134.145]

TASK [hello] *********************************************************************************changed: [192.168.134.143]
changed: [192.168.134.145]

PLAY RECAP ***********************************************************************************192.168.134.143            : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
192.168.134.145            : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
主要功能就是定義 task 也就是調用模組做動作。

![](https://i.imgur.com/hS0s2T7.png)

### 核心元素
- Hosts 執行主機的列表
- Tasks 任務集合
- Variables 內置變量或自定義變量在 playbook 中調用
- Templates 模板，可替換模板檔案中的變量並實現一些簡單邏輯檔案
- Handlers 和 notify 結合使用，由特定條件觸發的操作，滿足才能執行，否則不執行
- tags 跳過某些執行片段，ansible 具有冪等性，因此會跳過沒有變動的地方


ansible-playbook 操作
```shell
$ ansible-playbook hello.yml --list-task

playbook: hello.yml

  play #1 (webserver): webserver        TAGS: []
    tasks:
      hello     TAGS: []
```
### Hosts
Playbook 中的每一個 play 的目的都是為了讓特定主機以某個指定的使用者身分執行任務。hosts 用於指定要執行指定任務的主機

主機清單
```bash
cch.example.com
172.10.10.12
172.10.10.*
webservers:dbserver
webservers:&dbserver # 兩個群組的交集
webservers:!stage # 在 webservers 群組，但不在 stage 
```

```yaml
- hosts: webservers:dbserver
```

### remote_user 
可使用用於 *host* 和 *task* 中。可指定使用 root 權限在被控端執行任務。也可在 sudo 時使用 sudo_user 指定 sudo 時切換使用者

```yaml
- hosts: webservers
  remote_user: root

  tasks:
    - name: test connect
      ping:
      remote_user: naruto
      sudo: yes
      sudo_user: madara
```

### task 清單和 action 組件
play 的主體是 *task list*，當中有一或多個 *task*，每個 task 都按順序在 hosts 中指定的所有被控端執行，會在所有被控端執行完第一個 task 後，才會接續執行第二個。

*task* 的目的是使用指定參數執行模組。

其寫法有兩種
- action: module args
- module: args

```yaml
---
- hosts: webservers
  remote_user: root
  tasks:
    - name: install httpd
      yum: name:httpd # this
    - name: start httpd
      service: name:httpd state=started enabled=yes # this
```
### Handlers 和 notify
- Handlers 是 task 列表，當前關注的資源發生變化時，會才取一定的操作
- Notify 此 action 可用於每個 play 的最後被觸發。在 notify 中列出的操作稱為 handler，也即 notify 中調用 handler 中定義的操作

以下為範例，以下說明當配置檔進行修正後傳輸，需要重啟服務才會生效，假設沒定義 notify 時，只要修改配置檔，其執行過的 task 不會有對應動作。`handlers` 就像 `tasks` 一樣定義多個任務，而 `notify` 可以引用多個 `handlers` 任務。 
```yaml
---
- hosts: webserver
  remote_user: root

  tasks:
    - name: install httpd package
      yum: name=httpd
    - name: copy conf file
      copy: src=./file/httpd.conf dest=/etc/httpd/conf/ backup=yes
      notify: restart service
    - name: start service
      service: name=httpd state=started enable=yes
  handlers:
    - name: restart service
      service:  name=httpd state=restart
```

- tags 可以多個 task 組成，在執行時可透過指定 tags 名稱來做該 tag 擁有的 task

### 變數使用

其範例是 [variable-use.yml](var/variable-use.yml)。因為 `sudo` 問題暫時修改 `sudoers` 將其變成 `%sudo   ALL=(ALL:ALL) NOPASSWD:ALL`。variable-use2.yml 是在 yml 中定義變數，因此在執行時不需帶入變數值。`{{}}` 而該符號是用來調用變數。

透過 -e 選項，範例[variable-use.yml](var/variable-use.yml)
```shell
$ ansible-playbook -e 'pkname=vsftpd' variable-use.yml # 
```

>如果有 timeout 的話，需嘗試將 ansible.cfg 的 timeout 在調高一下

定義變數方式有以下
- ansible setup facts
- /etc/ansible/hosts
```shell
[webserver]
192.168.134.143 http_port=81 # http_port 變數定義
192.168.134.145 http_port=82 # http_port 變數定義
[webserver:vars] # 針對於 webserver 的統一變數，優先級最高
nodename=www
domain=cch.com
```
- 透過指令方式帶 -e 選項
- playbook 中定義
- role 中定義

而外定義一個專門存放變數的檔案([vars.yml](var/vars.yml))，使用 `vars_files` 引入，使用 [include_vars.yml](var/include_vars.yml) 做為範例

```shell
$ ansible-playbook include_vars.yml
$ ansible webserver -m shell -a 'dpkg -l | grep nginx' # 驗證
$ ansible webserver -m shell -a 'ls ./ | grep tree.log'
$ ansible webserver -m shell -a 'sudo apt autoremove nginx -y && sudo apt purge nginx -y' 
```

## 模板 Template
使用 nginx-templates.yml 和 nginx.conf.j2 做為模板練習，當中把 `worker_processes` 的數量設置為核心的兩倍。因為我核心是給 2，所以會有 4 個 worker process

```
# 模板配置
worker_processes  {{ ansible_processor_vcpus*2 }};
```
```shell
$ ansible-playbook nginx-templates.yml
$ ansible webserver -m shell -a 'ps aux|grep nginx'
192.168.134.145 | CHANGED | rc=0 >>
root       10565  0.0  0.0   8600   828 ?        Ss   15:32   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
nobody     10566  0.0  0.3   9284  3356 ?        S    15:32   0:00 nginx: worker process
nobody     10567  0.0  0.3   9284  3356 ?        S    15:32   0:00 nginx: worker process
nobody     10568  0.0  0.3   9284  3356 ?        S    15:32   0:00 nginx: worker process
nobody     10569  0.0  0.3   9284  3356 ?        S    15:32   0:00 nginx: worker process
cch        10795  0.0  0.0   2608   608 pts/0    S+   15:36   0:00 /bin/sh -c ps aux|grep nginx
cch        10797  0.0  0.0   6300   736 pts/0    S+   15:36   0:00 grep nginx
192.168.134.143 | CHANGED | rc=0 >>
root       10488  0.0  0.0   8600   824 ?        Ss   15:31   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
nobody     10489  0.0  0.3   9284  3268 ?        S    15:31   0:00 nginx: worker process
nobody     10490  0.0  0.3   9284  3268 ?        S    15:31   0:00 nginx: worker process
nobody     10491  0.0  0.3   9284  3268 ?        S    15:31   0:00 nginx: worker process
nobody     10492  0.0  0.3   9284  3268 ?        S    15:31   0:00 nginx: worker process
cch        10751  0.0  0.0   2608   544 pts/0    S+   15:36   0:00 /bin/sh -c ps aux|grep nginx
cch        10753  0.0  0.0   6300   740 pts/0    S+   15:36   0:00 grep nginx
```

嘗試從 hosts 定義的變量拿至 templates 應用

```shell
$ tail -f /etc/ansible/hosts

# Here's another example of host ranges, this time there are no
# leading 0s:

## db-[99:101]-node.example.com
[webserver]
192.168.134.143 http_port=85
192.168.134.145 http_port=90
[dbserver]
192.168.134.144
```

```
# 模板配置
...
server {
        listen       {{ http_port }};
        server_name  localhost;
...
```

```shell
$ ansible-playbook nginx-templates.yml
$ ansible webserver -m shell -a 'ss -ntl'
192.168.134.145 | CHANGED | rc=0 >>
State    Recv-Q   Send-Q     Local Address:Port     Peer Address:Port  Process  
LISTEN   0        4096       127.0.0.53%lo:53            0.0.0.0:*
LISTEN   0        128              0.0.0.0:22            0.0.0.0:*
LISTEN   0        511              0.0.0.0:90            0.0.0.0:* # this
LISTEN   0        128                 [::]:22               [::]:*
192.168.134.143 | CHANGED | rc=0 >>
State    Recv-Q   Send-Q     Local Address:Port     Peer Address:Port  Process  
LISTEN   0        511              0.0.0.0:85            0.0.0.0:* # this
LISTEN   0        4096       127.0.0.53%lo:53            0.0.0.0:*
LISTEN   0        128              0.0.0.0:22            0.0.0.0:*
LISTEN   0        128                 [::]:22               [::]:*
```

##### when
條件測試用

##### with_items
迭代，重複性任務時可以使用，範例為 with_items.yml

```shell
$ ansible webserver -m shell -a 'ls ./ | grep "file"'
192.168.134.145 | CHANGED | rc=0 >>
file1
file2
file3
192.168.134.143 | CHANGED | rc=0 >>
file1
file2
file3
```

迭代嵌套子變數，範例為 with_items_vars.yml


```shell
$ ansible webserver -m shell -a 'cat /etc/group | grep g[1-3]'       
192.168.134.143 | CHANGED | rc=0 >>
g1:x:1001:
g2:x:1002:
g3:x:1003:
192.168.134.145 | CHANGED | rc=0 >>
g1:x:1001:
g2:x:1002:
g3:x:1003:
```

##### for 與 if
範例為 for-port.yml，當中會引入一個由 for 迴圈形成的配置檔
```shell
$ ansible-playbook for-port.yml
$ ansible webserver -m shell -a 'cat ./for.conf'
192.168.134.145 | CHANGED | rc=0 >>
server{
        listen 90
}
server{
        listen 91
}
server{
        listen 92
}
192.168.134.143 | CHANGED | rc=0 >>
server{
        listen 90
}
server{
        listen 91
}
server{
        listen 92
}
```

for-map-port.yml 呈現出使用字典方式做迭代，其對應的 template 在 for-map.conf.j2 中
```shell
$ ansible-playbook for-map-port.yml
$ ansible webserver -m shell -a 'cat ./for-map.conf'
192.168.134.145 | CHANGED | rc=0 >>
server{
        listen 90
        servername web1.cch.com
        documentroot /data/website1
}
server{
        listen 91
        servername web2.cch.com
        documentroot /data/website2
}
server{
        listen 92
        servername web3.cch.com
        documentroot /data/website3
}
192.168.134.143 | CHANGED | rc=0 >>
...
```

## roles
用於層次性、結構化的組織 playbook。騎能夠根據結構話層次結構自動裝載變數檔案、tasks 或 handlers 等。使用 roles 時只需在 playbook 中用 include 引入即可。簡而言之，將 playbook 的 tasks、template 等配置在不同目錄，最後使用 include 方式引入。

預設建議該存放目錄在以下，但這可以做修正
```shell
$ ls /etc/ansible/
ansible.cfg  hosts  roles
```

我們以 nginx-roles.yml 為主要的運行檔案，roles 目錄為配置檔案
```shell
$ tree roles/nginx/
roles/nginx/
├── tasks
│   ├── apt.yml
│   ├── group.yml
│   ├── main.yml
│   ├── service-restart.yml
│   ├── service-start.yml
│   ├── template.yml
│   └── user.yml
└── templates
    └── nginx.conf.j2
```

主要的 playbook，當中 role 也是可以跨不同專案來參考其他專案的任務，只需指定路經即可。也可以配合著 tags 來指定某個 roles 執行。這靈活性相當高。
```yaml
$ cat nginx-roles.yml 
---
- hosts: webserver
  remote_user: cch
  become: true
  become_method: sudo

  roles:
    - role: nginx
```
定義執行的步驟

```shell
.../ansible/roles/nginx/tasks$ cat main.yml 
- include: group.yml
- include: user.yml
- include: apt.yml
- include: template.yml
- include: service-start.yml
```

```shell
$ ansible webserver -m shell -a 'sudo cat /etc/group | grep nginx'    # 驗證
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
192.168.134.143 | CHANGED | rc=0 >>
nginx:x:80:
192.168.134.145 | CHANGED | rc=0 >>
nginx:x:80:
```

