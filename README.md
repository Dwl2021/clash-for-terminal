

# Clash for terminal 配置

## Quick Start

### 1. 获取订阅链接

首先到机场的控制面板复制clash文件的下载地址

### 2. 一键安装 Clash for Terminal

```bash
git clone --depth 1 https://github.com/Dwl2021/clash-for-terminal.git
cd clash-for-terminal
./install.sh
```

安装脚本会提示您输入订阅链接，然后自动下载配置文件并创建启动脚本。

### 3. 启动 Clash

```bash
./cft.sh
```

启动成功后，您会看到类似以下信息：

```
INFO[0000] Start initial compatible provider Hijacking  
INFO[0000] Start initial compatible provider PROXY      
INFO[0000] Start initial compatible provider FINAL      
INFO[0000] RESTful API listening at: 127.0.0.1:9090     
INFO[0000] inbound http://:7890 create success.         
INFO[0000] inbound socks://:7891 create success.  
```

**重要提示：** 启动 Clash 的终端需要保持运行状态，关闭终端会断开代理连接。建议使用tmux挂在后台。

### 4. 测试 Clash

clash一般都是映射到127.0.0.1:7890端口，如果不确定是不是7890，可以查看clash.yml里面的port设置，**每个新开终端都要输入如下的命令**

```bash
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
```

如果不想每次都这样子输入，可以使用以下命令将函数添加到~/.bashrc：

```bash
echo 'proxy_on() { export http_proxy=http://127.0.0.1:7890; export https_proxy=http://127.0.0.1:7890;}' >> ~/.bashrc
echo 'proxy_off() { unset http_proxy; unset https_proxy;}' >> ~/.bashrc
```

然后执行 `source ~/.bashrc` 重新加载配置，之后就可以使用 `proxy_on` 开启代理，`proxy_off` 关闭代理。

或者直接使用脚本（推荐）：

```bash
source ./set_proxy.sh
```

脚本会自动读取clash.yml中的端口配置，并立即启用代理。

使用http协议访问YouTube，如果出现很多网页的内容，则说明没有问题

```bash
# 手动测试
curl -I --proxy http://127.0.0.1:7890 http://www.youtube.com

# 或使用脚本自动测试（推荐）
./test_youtube.sh
```

### 5. 设置Git的代理办法

基本设置完成就可以git push 和 git clone了

```bash
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
```

### 6. 更改代理

通过Web UI界面更改代理：

如果Clash运行在远程服务器上，需要先建立SSH隧道：

```bash
ssh -L 端口1:localhost:端口2 服务器用户名@服务器IP
```

其中：
- `端口1`：映射到本地的端口（可以自由选择，如10090）
- `端口2`：服务器上clash.yml配置文件中的external-controller端口

查看clash.yml配置文件中的`external-controller: '127.0.0.1:端口号'`来获取端口2的值。

然后在本地浏览器中访问：`http://localhost:端口1/ui`

也可以直接运行命令快速获取端口转发链接：

```bash
./echo_extern_control.sh
```

通过Web界面可以更直观地查看和切换代理。


具体可以参考Clash的API调用方法，可以参考[Clash API](https://clash.wiki/runtime/external-controller.html)


## 其他可能有用的命令
对于有桌面版的ubuntu，可以通过手动设置vpn实现全局的http代理。

```bash
gsettings set org.gnome.system.proxy mode 'manual'
gsettings set org.gnome.system.proxy.http host 'ip'
gsettings set org.gnome.system.proxy.http port 7890
gsettings set org.gnome.system.proxy.https host 'ip'
gsettings set org.gnome.system.proxy.https port 7890
```



