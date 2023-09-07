#!/bin/bash

# For ubuntu 22.04

# Disable the ipv6 stack
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Add Mongo key and repository
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb-6.gpg
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Update repositories
apt update

# Install mongo
apt install mongodb-org mongodb-cli -y

# Start and enabel mongo
systemctl enable --now mongod

# Check status of mongo
systemctl status mongod

# Allow remote connections to mongo (Set to listen on all interfaces)
export BINDADDRESS=0.0.0.0
sed -i -r 's/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/"$BINDADDRESS"/ /etc/mongod.conf
# same file add
#security:
#  authorization: "enabled"

# Restart mongo
systemctl restart mongod
systemctl stop mongod
systemctl daemon-reload
systemctl start mongod

# Create a new root user (username is the same as the currently logged in user)
mongosh --eval "use admin;db.createUser({user:'${USER}', pwd:'Linux_User', roles:[{role:'root', db:'admin'}]})"

# Create swimlane database
#sudo mongosh --eval "use Swimlane"

# Create a new swimlane-user that is an administrator of the swimlane database
mongosh --eval "use Swimlane;db.createUser({user:'swimlane-user', pwd:'Linux_User', roles:[{role:'dbAdmin', db:'Swimlane'}]})"

# Create the swimlanehistory database
#sudo mongosh --eval "use SwimlaneHistory"

# Create a new swimlane-history-user that is an administrator of the swimlanehistory database
mongosh --eval "use SwimlaneHistory;db.createUser({user:'swimlane-history-user', pwd:'Linux_User', roles:[{role:'dbAdmin', db:'SwimlaneHistory'}]})"

# Restart mongo
systemctl restart mongod
