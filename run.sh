#!/bin/bash

# Tweak nginx to match the workers to cpu's
procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes 4/worker_processes $procs/" /etc/nginx/nginx.conf

# Clean things before change permissions.
echo '' > ./.ssh/known_hosts

# Run Supervisor daemon.
/usr/bin/supervisord