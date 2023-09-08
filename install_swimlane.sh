#!/bin/bash
# For ubuntu 22.04
# Run this script with sudo privileges

# Disable the ipv6 stack
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Install microk8s (using a specific version. Not necessary)
snap install microk8s --classic

# Create swimlane user
export swimlane_username=swimlane-user
useradd ${swimlane_username}

# Ask the user to set a password for the new swimlane user
read -p "Please enter a password for the newly created swimlane user:" swimlane_password

# Set password for the new swimlane user
passwd ${swimlane_username} << EOD
${swimlane_password}
${swimlane_password}
EOD

# Unset the swimlane_password variable
unset ${swimlane_password}

# Add the user to the microk8s group
usermod -a -G microk8s ${swimlane_username}

# Alternatively, add yourself to the group
#usermod -a -G microk8s ${USER}

# Enabled microk8s services
microk8s enable dns hostpath-storage ingress rbac

# Create alias
#alias kubectl="microk8s kubectl"

# Edit sysctl.conf file
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# Check status of kubernetes
microk8s status --wait-ready

# See nodes
microk8s kubectl get nodes

# Get current namespaces
microk8s kubectl get namespaces

# Create a new namespace called production
export k8namespace=production
microk8s kubectl create namespace ${k8namespace}

# Download the swimlane SPI kubectl add-on
wget "https://get.swimlane.io/existing-cluster/install/linux/kots_linux.tar.gz"

# Untar file
tar zxf kots_linux.tar.gz

# Rename kots
mv kots kubectl-kots

# Move the binary to the PATH so kubectl can see it
mv kubectl-kots /usr/local/bin/

# Delete tar file
rm kots_linux.tar.gz

# Install the add-on
microk8s kubectl kots install swimlane-platform --namespace ${k8namespace}

# Setup ingress
#microk8s kubectl apply -f test-ingress.yaml

# Port forward from the host to the pod
#microk8s kubectl port-forward service/kotsadm 8800:3000 --namespace ${k8namespace} --address='0.0.0.0'
