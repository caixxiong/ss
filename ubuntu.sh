#!/bin/bash

ln /usr/bin/python3 /usr/bin/python

# 安装pip setuptools shadowsocks
apt install python3-pip && pip3 install pip -U && pip install setuptools > log
if [ $? -ne 0 ]; then
    printf "install python3-pip or upgrade pip or install setuptools failed!!\n\n"
    exit -1
fi
pip install https://github.com/shadowsocks/shadowsocks/archive/master.zip >> log
# pip install shadowsocks >> log
if [ $? -ne 0 ]; then
    printf "install shadowsocks failed!!\n\n"
    exit -1
fi
printf "INSTALL SHADOWSOCKS FINISHED!!\n\n"

# 修改openssl.py文件, 否则会报错, 因为ss的一些API改动了
# name=/usr/local/lib/python3.*/dist-packages/shadowsocks/crypto/openssl.py
# sed -i 's/cleanup/reset/g' $name
# 用github地址安装shadowsocks, 可以安装3.0.0, 就不会有上面这个问题

# 安装net-tools, 可以使用netstat和ifconfig命令
apt install net-tools
printf "INSTALL NET-TOOLS FINISHED!!\n\n"

# 安装BBR加速TCP协议
if [ ! -f "bbr.sh" ]; then
    printf "Downloading BBR ...\n" wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh >> log
    chmod +x bbr.sh
    ./bbr.sh >> log
fi
printf "INSTALL BBR FINISHED!!\n\n"

# 设置打开的文件描述符上限数
sed -i '$a * soft nofile 51200\n* hard nofile 51200' /etc/security/limits.conf
sed -i '$a fs.file-max = 51200\
net.core.rmem_max = 67108864\
net.core.wmem_max = 67108864\
net.core.netdev_max_backlog = 250000\
net.core.somaxconn = 4096\
net.ipv4.tcp_syncookies = 1\
net.ipv4.tcp_tw_reuse = 1\
net.ipv4.tcp_fin_timeout = 30\
net.ipv4.tcp_keepalive_time = 1200\
net.ipv4.ip_local_port_range = 10000 65000\
net.ipv4.tcp_max_syn_backlog = 8192\
net.ipv4.tcp_max_tw_buckets = 5000\
net.ipv4.tcp_fastopen = 3\
net.ipv4.tcp_mem = 25600 51200 102400\
net.ipv4.tcp_rmem = 4096 87380 67108864\
net.ipv4.tcp_wmem = 4096 65536 67108864\
net.ipv4.tcp_mtu_probing = 1' /etc/sysctl.conf
sysctl -p
# ulimit -n 51200 

# 构造shadowsocks.json配置文件
cat > /etc/shadowsocks4.json <<EOF
{
    "server":"0.0.0.0",
    "local_address": "127.0.0.1",
    "local_port":1080,
    "port_password": {
         "55501": "gg55501gg",
         "55502": "gg55502gg",
         "55503": "gg55503gg"
    },
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false
}
EOF

# 要使用ipv6, 必须将server设置成"::"
cat > /etc/shadowsocks6.json <<EOF
{
    "server":"::",
    "local_address": "127.0.0.1",
    "local_port":1080,
    "port_password": {
         "55501": "gg55501gg",
         "55502": "gg55502gg",
         "55503": "gg55503gg"
    },
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false
}
EOF

# 给scholar指定ipv6域名, 因为vps的ipv4很有可能被scholar封掉了
cat >> /etc/hosts << EOF
2404:6800:4008:c06::be scholar.google.com
2404:6800:4008:c06::be scholar.google.com.hk
2404:6800:4008:c06::be scholar.google.com.tw
2401:3800:4001:10::101f scholar.google.cn
EOF

# 获取sss文件
curl https://raw.githubusercontent.com/caixxiong/ss/master/sss -o /usr/bin/sss
chmod +x /usr/bin/sss

sss on 4
printf "SHADOWSOCKS STARTED!!\n\n"
printf "ALL FINISHED!!\n\n"
