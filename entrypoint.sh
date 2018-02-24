#!/bin/bash

files="server.properties pocketmine.yml ops.txt"
for f in $files; do
  if [ -f "/data/config/$f" ]; then
    cp -p /data/config/$f /data/$f
  else
    cp -p /data/default_config/$f /data/$f
  fi
done

cd /data
/data/start.sh
