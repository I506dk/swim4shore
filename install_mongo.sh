#!/bin/bash
# For ubuntu 22.04
# Run this script with sudo privileges

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
export bind_address=0.0.0.0
sed -i -r 's/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/"${bind_address}"/ /etc/mongod.conf
# Update the security authorization within the mongod configuration
sed -i -r '/security:/a \  authorization: "enabled"' /etc/mongod.conf
sed -i -r 's/#security:/security:/' /etc/mongod.conf

# Restart mongo
systemctl restart mongod
systemctl stop mongod
systemctl daemon-reload
systemctl start mongod

# Ask the user to set a password for the new user to be created in mongo
# (This user will have the same username as the current user)
read -p "Please enter a password for the mongo user ${USER}:" current_user_password

# Create a new root user (username is the same as the currently logged in user)
mongosh --eval "use admin;db.createUser({user:'${USER}', pwd:'${current_user_password}', roles:[{role:'root', db:'admin'}]})"

# Unset the password variable
unset ${current_user_password}

# Ask the user to set a password for the new user to be created in mongo
# (This user will be 'swimlane-user')
read -p "Please enter a password for the mongo user 'swimlane-user':" swimlane_user_password

# Create a new swimlane-user that is an administrator of the swimlane database
mongosh --eval "use Swimlane;db.createUser({user:'swimlane-user', pwd:'${swimlane_user_password}', roles:[{role:'dbAdmin', db:'Swimlane'}]})"

# Unset the password variable
unset ${swimlane_user_password}

# Ask the user to set a password for the new user to be created in mongo
# (This user will be 'swimlane-user')
read -p "Please enter a password for the mongo user 'swimlane-history-user':" swimlane_history_user_password

# Create a new swimlane-history-user that is an administrator of the swimlanehistory database
mongosh --eval "use SwimlaneHistory;db.createUser({user:'swimlane-history-user', pwd:'${swimlane_history_user_password}', roles:[{role:'dbAdmin', db:'SwimlaneHistory'}]})"

# Unset the password variable
unset ${swimlane_history_user_password}

# Restart mongo
systemctl restart mongod
