# wg-easy

###### guide-by-example

![logo](https://i.imgur.com/IRgkp2o.png)

# Purpose & Overview

Web GUI for Wireguard VPN.<br>

* [Github](https://github.com/wg-easy/wg-easy)

Wireguard is the best VPN solution right now. But its not noob friendly or easy.<br>
WG-easy tries to solve this.

Written in javascript.

# Files and directory structure

```
/home/
└── ~/
    └── docker/
        └── wg-easy/
            ├── 🗁 wireguard_data/
            └── 🗋 docker-compose.yml
```              
* `wireguard_data/` - a directory with wireguard config files
* `docker-compose.yml` - a docker compose file, telling docker how to run the container

# Compose

`docker-compose.yml`
```yml
services:

  wg-easy:
    image: ghcr.io/wg-easy/wg-easy:15.4
    container_name: wg-easy
    hostname: wg-easy
    restart: unless-stopped
    volumes:
      - ./wireguard_data:/etc/wireguard
      - /lib/modules:/lib/modules:ro
    ports:
      - "51820:51820/udp"  # vpn traffic
    expose:
      - "51821"  # web interface
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
    environment:
      - INSECURE=true
      - DISABLE_IPV6=true
      # unattended setup on first run
      - INIT_ENABLED=true
      - INIT_USERNAME=myspecialadmin
      - INIT_PASSWORD=mysecretpasswordthatislong12charAtleast
      - INIT_HOST=vpn.example.com
      - INIT_PORT=51820
      - INIT_DNS=
      - INIT_ALLOWED_IPS=192.168.1.0/24

networks:
  default:
    name: caddy_net
    external: true
```

# Reverse proxy

Caddy is used, that's why the web interface port is just exposed and not mapped
and why the insecure is set to true for just http.<br>
Details [here](https://github.com/DoTheEvo/selfhosted-apps-docker/tree/master/caddy_v2).</br>

`Caddyfile`
```php
vpn.example.com {
    reverse_proxy wg-easy:51821
}
```

# First run

![loginpic](https://i.imgur.com/V30cDwq.png)

If you need to import old config, you need to change env variable `INIT_ENABLED=false` <br>
It then guides you through setup and one of the steps is import of old config.

# Trouble shooting

Make sure you forward udp port `51820`.

# Site-to-Site

[https://www.procustodibus.com/blog/2020/12/wireguard-site-to-site-config/](https://www.procustodibus.com/blog/2020/12/wireguard-site-to-site-config/)

# Update

Manual image update:

- `docker compose pull`</br>
- `docker compose up -d`</br>
- `docker image prune`

# Alternative

[netbird](https://github.com/netbirdio/netbird)
