# Clash for Terminal Configuration

[中文版 README](README.md)

## Quick Start

### 1. Get Subscription Link

First, copy the clash file download address from your airport control panel

### 2. One-Click Install Clash for Terminal

```bash
git clone --depth 1 https://github.com/Dwl2021/clash-for-terminal.git
cd clash-for-terminal
./install.sh
```

The installation script will prompt you to enter the subscription link, then automatically download the configuration file and create a startup script.

You can also manually download the configuration file and name it `clash.yml` in the repository root directory to skip the download step.

### 3. Start Clash

```bash
./cft.sh
```

After successful startup, you will see information similar to:

```
INFO[0000] Start initial compatible provider Hijacking  
INFO[0000] Start initial compatible provider PROXY      
INFO[0000] Start initial compatible provider FINAL      
INFO[0000] RESTful API listening at: 127.0.0.1:9090     
INFO[0000] inbound http://:7890 create success.         
INFO[0000] inbound socks://:7891 create success.  
```

**Important Note:** The terminal that starts Clash needs to keep running, closing the terminal will disconnect the proxy. It's recommended to use tmux to keep it running in the background.

### 4. Test Clash

Clash generally maps to port 127.0.0.1:7890. If you're not sure if it's 7890, you can check the port setting in clash.yml. **Each new terminal needs to enter the following commands:**

```bash
PORT=7890
export http_proxy=http://127.0.0.1:${PORT}
export https_proxy=http://127.0.0.1:${PORT}
```

If you don't want to type this every time, you can add functions to ~/.bashrc using the following commands:

```bash
./echo_bashrc.sh
```

Then enter your configured port.

Then execute `source ~/.bashrc` to reload the configuration, after which you can use `proxy_on` to enable the proxy and `proxy_off` to disable it.

Or use the script directly for each new terminal (recommended), which won't modify `.bashrc` and is safer:

```bash
source ./set_proxy.sh
```

The script will automatically read the port configuration from clash.yml and immediately enable the proxy.

Using the http protocol to access YouTube, if you see a lot of webpage content, it means everything is working fine.

```bash
# Manual test
PORT=7890
curl -I --proxy http://127.0.0.1:$PORT http://www.youtube.com

# Or use script for automatic testing (recommended)
./test_youtube.sh
```

### 5. Set Git Proxy

After basic setup, you can git push and git clone

```bash
PORT=7890
git config --global http.proxy http://127.0.0.1:$PORT
git config --global https.proxy http://127.0.0.1:$PORT
```

### 6. Change Proxy

Change proxy through Web UI interface:

If Clash is running on a remote server, you need to establish an SSH tunnel first:

```bash
ssh -L port1:localhost:port2 username@server_ip
```

Where:
- `port1`: Port mapped to local (can be freely chosen, such as 10090)
- `port2`: external-controller port in the clash.yml configuration file on the server

Check the `external-controller: '127.0.0.1:port_number'` in the clash.yml configuration file to get the value of port2.

Then access in your local browser: `http://localhost:port1/ui`

You can also run the command directly to quickly get the port forwarding link:

```bash
./echo_extern_control.sh
```

Through the Web interface, you can more intuitively view and switch proxies.

For specific Clash API usage methods, you can refer to [Clash API](https://clash.wiki/runtime/external-controller.html)

## Other Useful Commands
For Ubuntu with desktop version, you can manually set VPN to achieve global HTTP proxy.

```bash
PORT=7890
gsettings set org.gnome.system.proxy mode 'manual'
gsettings set org.gnome.system.proxy.http host 'ip'
gsettings set org.gnome.system.proxy.http port $PORT
gsettings set org.gnome.system.proxy.https host 'ip'
gsettings set org.gnome.system.proxy.https port $PORT
```

---

[中文版 README](README.md)

