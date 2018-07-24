#!/bin/bash
###################################
# edit vars
###################################
set -e
password=Pa22word
data_dir=/Users/clemenko/Dropbox/docker/dump_clean

#get dump
token=$(curl -sk -d '{"username":"admin","password":"'$password'"}' https://ucp.dockr.life/auth/login | jq -r .auth_token) > /dev/null 2>&1
curl -kX POST 'https://ucp.dockr.life/api/support'  -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: en-US,en;q=0.9' -H "Authorization: Bearer $token" --compressed > $data_dir/original-support.tgz

#no need to copy the tar since untar makes a copy.
#untar
mkdir dsinfo
tar -zxf $data_dir/original-support.tgz -C dsinfo
cd dsinfo

#get hostname and scrub them.
host_num=0
rm -f conversion.txt
for hostname in $(cat ucp-nodes.txt |jq -r .[].Description.Hostname); do
  echo "$hostname ==> host_$host_num"
  grep -lRi $hostname . | xargs sed -i '' "s/$hostname/host_$host_num/g"
  echo "$hostname host_$host_num" >> conversion.txt
  host_num=$((host_num+1))
  mv $hostname* host_$host_num
done

#sed - with change log


#repackage
