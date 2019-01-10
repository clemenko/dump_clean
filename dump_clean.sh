#!/bin/bash
###################################
# edit vars
###################################
set -e
username=admin
#password=Pa22word
#URL=ucp.dockr.life
password=docker4life
URL=ucp.jswann.dockerps.io
data_dir=/Users/clemenko/Dropbox/docker/dump_clean


######  NO MOAR EDITS #######
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

echo "------------------------------------------------------------------"
echo " Welcome to Docker Support Dump Data Scrubber."
echo "------------------------------------------------------------------"


echo -n " Getting Support Dump "
token=$(curl -sk -d '{"username":"'$username'","password":"'$password'"}' https://$URL/auth/login | jq -r .auth_token)
curl -kX POST https://$URL/api/support  -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: en-US,en;q=0.9' -H "Authorization: Bearer $token" --compressed > $data_dir/original-support.tgz
echo "$GREEN" " [ok]" "$NORMAL"


#no need to copy the tar since untar makes a copy.
echo -n " Untar-ing "
mkdir dsinfo
tar -zxf $data_dir/original-support.tgz -C dsinfo
cd dsinfo
echo "$GREEN" "[ok]" "$NORMAL"


echo -n " Generating Swap list "
host_num=1
echo "HOST NEW_HOST IP NEW_IP" > $data_dir/conversion.txt
for hostname in $(cat ucp-nodes.txt |jq -r .[].Description.Hostname); do
  orig_ip=$(cat ucp-nodes.txt |jq -r '.[] | select(.Description.Hostname=="'$hostname'") | .Status.Addr')
  echo "$hostname host_$host_num $orig_ip 0.0.0.$host_num" >> $data_dir/conversion.txt
  host_num=$((host_num+1))
done
echo "$GREEN" "[ok]" "$NORMAL"

exit

echo -n " Scrubbing hostnames "
for hostname in $(cat $data_dir/conversion.txt | grep -v HOST | awk '{print $1}'); do
  new_host=$(cat $data_dir/conversion.txt |grep $hostname | awk '{print $2}')
  grep -lRi $hostname . | xargs sed -i '' "s/$hostname/$new_host/g"
  mv $hostname* $new_host
done
echo "$GREEN" "[ok]" "$NORMAL"

echo -n " Scrubbing IPs "
for ip in $(cat $data_dir/conversion.txt | grep -v HOST | awk '{print $3}'); do
  new_ip=$(cat $data_dir/conversion.txt |grep $ip | awk '{print $4}')
  grep -lRi $ip . | xargs sed -i '' "s/$ip/$new_ip/g"
done
echo "$GREEN" "[ok]" "$NORMAL"

echo -n " Scrubbing Domains "
echo This is tough.........
#check for SANS
cat ucp-nodes.txt |jq -r '.[].Spec.Labels | .["com.docker.ucp.SANs"]'
#there should be enough info here for domain names.
#check for certs names

#echo test.life | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'

echo "$GREEN" "[ok]" "$NORMAL"

echo -n " Repackaging "
tar -zcvf $data_dir/cleaned_support_dump.tgz .  > /dev/null 2>&1
echo "$GREEN" "[ok]" "$NORMAL"
