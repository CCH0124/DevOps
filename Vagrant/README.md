```shell
$ vagrant init ubuntu/trusty64 # 產生一個 Vagrantfile 檔案
```

配置以下內容基本上可以運行一個虛擬機。

```shell
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  
  config.vm.box = "ubuntu/trusty64"

  # Provider Settings
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
end

```


wsl 需設置以下

```shell
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/network/Oracle/VirtualBox"
```

使用 `vagrant up` 即可建立一台虛擬機。如果要讓其虛擬機有休眠狀態便暫存資料可以使用 `vagrant suspend` 回覆則是 `resume`。

如果要修正虛擬機一些配置像是增加 cpu 之類，可在檔案中添加如下，修正完後使用 `vagrant reload` 進行重新載入動作
```shell
Vagrant.configure("2") do |config|
  
  config.vm.box = "ubuntu/trusty64"

  # Provider Settings
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 2
  end
end
```

可以透過 `vagrant ssh` 進入啟動的虛擬機，預設密碼是 `vagrant`。


## 指定虛擬機運行的腳本

預設是注釋，但從下面來看，當啟動虛擬機時會執行更新並安裝 apache
```shell
# Provision Setting
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y apache2
  SHELL
```

使用路徑方式將本地寫好的腳本引入

```shell
config.vm.provision "shell", path: "init.sh"
```