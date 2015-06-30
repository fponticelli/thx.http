#!/bin/sh
haxe server.hxml
pm2 start bin/test-server.js -f
sleep 1
