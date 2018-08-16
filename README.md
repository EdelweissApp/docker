## Edelweiss app - Docker
This is our main image for development puproses. We using it only for development, because all services are combined in one docker image. In production we will have different setup. Example usage can be found in: ./test/docker-compose.env

#### Technology stack
- PHP 7.2
- nginx
- openssh-server
- Composer
- Supervisor

#### Ports
- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)
- 9000 (FPM)
- 9002 (Supervisor UI)

### Volumes
- /var/www/feed
- /var/www/profile
- /var/www/app