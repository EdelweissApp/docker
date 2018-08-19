#!/bin/bash

# Tweak nginx to match the workers to cpu's
procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes 4/worker_processes $procs/" /etc/nginx/nginx.conf

# Clean things before change permissions.
echo '' > ./.ssh/known_hosts

# Replace some env variables
envsubst < /etc/supervisor/supervisord.conf > /etc/supervisor/supervisord.conf

# Always chown for better mounting
##################################
cd /var/www
chown dev:www-data $(ls -A)
chown dev:www-data ./

# Change passwords on start
echo "root:${BOX_ROOT_SSH_PASSWORD}" | chpasswd
echo "dev:${BOX_DEV_USER_PASSWORD}" | chpasswd

# Run Supervisor daemon.
/usr/bin/supervisord