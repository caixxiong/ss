wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks.sh
chmod +x shadowsocks.sh
./shadowsocks.sh <<EOF
1111
1224
7
EOF

cat > /etc/shadowsocks.json<<-EOF
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

/bin/python /usr/bin/ssserver -c /etc/shadowsocks.json -d restart

for port in '1224' '55501' '55502' '55503'; do
  echo "open port ${port}/tcp"
  firewall-cmd --zone=public --add-port=${port}/tcp --permanent
done

systemctl restart firewalld
firewall-cmd --zone=public --list-ports

wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh
chmod +x bbr.sh
./bbr.sh
