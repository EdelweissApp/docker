## Edelweiss app - Docker
This is our main image for development puproses. We using it only for development, because all services are combined in one docker image. In production we will have different setup.

Available users: `root` and `dev`.

#### Technology stack
- PHP 7.2
  - Composer
  - Laravel cli
- nginx
- openssh-server
- Supervisor

#### Ports
- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)
- 9000 (FPM)
- 9002 (Supervisor UI)

### Volumes
- /var/www/feed - Feed microservice
- /var/www/profile - Profile microservice
- /var/www/app - Front-end app
- /etc/nginx/sites-enabled - Nginx vhosts

# ENVs
- SVUSER - Supervisor UI username
- SVPASS - Supervisor UI password
- BOX_ROOT_SSH_PASSWORD - `root` user ssh password
- BOX_DEV_USER_PASSWORD - `dev` user ssh password

### Example usage with docker-compose
- ./test/build/ - build from source
- ./test/image/ - using `edelweissapp/dev:test`