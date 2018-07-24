#!/bin/bash
###################################
# edit vars
###################################
set -e
password=Pa22word


token=$(curl -sk -d '{"username":"admin","password":"'$password'"}' https://ucp.dockr.life/auth/login | jq -r .auth_token) > /dev/null 2>&1
curl -kX POST 'https://ucp.dockr.life/api/support'  -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: en-US,en;q=0.9' -H "Authorization: Bearer $token" --compressed > ~/Desktop/support.tgz
