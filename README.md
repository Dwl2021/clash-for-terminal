# Clash for terminal 配置

## Quick Start

### 1. 获取订阅链接

首先到V2NEO的控制面包->左边一栏的首页->服务概览->选择使用的服务->左边一栏的配置下载->Clash配置链接->复制地址

然后就得到了用户下面的的Clash配置链接，并且替换下面的https://example/clash.yml 

```
git clone https://github.com/Dwl2021/Clash_for_Terminal.git
sudo chmod +x install.sh
sh install.sh https://example/clash.yml
```

### 2. 启动Clash

然后就可以启动Clash

```
clash -d /usr/local/etc/clash
```

如果弹出以下信息则说明启动成功：

```
(base) root@I167fea8ecd0030127e:~# clash -d /usr/local/etc/clash
INFO[0000] Start initial compatible provider Hijacking  
INFO[0000] Start initial compatible provider PROXY      
INFO[0000] Start initial compatible provider FINAL      
INFO[0000] RESTful API listening at: 127.0.0.1:9090     
INFO[0000] inbound http://:7890 create success.         
INFO[0000] inbound socks://:7891 create success.  
```

**尤其注意，如果关闭这个开启了Clash的终端，就会断开，因此开启Clash的终端要一直在后台挂着**

### 3. 测试Clash

clash一般都是映射到127.0.0.1:7890端口，在终端中输入

```
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
```

使用http协议访问YouTube，如果出现很多网页的内容，则说明没有问题

```
curl -x http://127.0.0.1:7890 https://www.youtube.com
```

### 4. 设置Git的代理办法

基本设置完成就可以git push 和 git clone了

```
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
```



## 手动设置Clash

```
wget https://pub-eac3eb5670f44f09984dee5c57939316.r2.dev/clash-linux-amd64-v1.18.0.gz
gunzip clash-linux-amd64-v1.18.0.gz
chmod +x clash-darwin-amd64-v1.18.0
cp clash-darwin-amd64-v1.18.0 /usr/local/bin/clash

mkdir /usr/local/etc/clash
wget -P /usr/local/etc/clash https://feed-dl.org/files/REi4utiLvR/clash.yml	#更换为自己的配置链接
mv /usr/local/etc/clash/clash.yml /usr/local/etc/clash/config.yaml

wget -P /usr/local/etc/clash/ https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@release/Country.mmdb
```
