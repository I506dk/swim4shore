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
read -p "Please enter a password for the newly created user 'swimlane-user':" swimlane_password

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
usermod -a -G microk8s ${USER}

# Enabled microk8s services
microk8s enable dns hostpath-storage ingress rbac

# Create alias
alias kubectl='microk8s kubectl'

# Edit sysctl.conf file
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# Check status of kubernetes
microk8s status --wait-ready

# See nodes
microk8s kubectl get nodes

# Get current namespaces
microk8s kubectl get namespaces

# Create a new namespace called swimlane
export k8namespace=swimlane
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
microk8s kubectl kots install swimlane-platform --namespace ${k8namespace} --wait-duration 10m

# Create ingress file
# This forwards everything to the swimlane web on port 443 (sw-web service)
sudo tee swimlane_ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: swimlane-ingress
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: https
    nginx.ingress.kubernetes.io/proxy-ssl-verify: "false"
    nginx.org/client-max-body-size: "1024m"
    nginx.ingress.kubernetes.io/proxy-body-size: "1024m"
  namespace: ${k8namespace}
spec:
  rules:
  - http:
      paths:
      - path: "/"
        pathType: Exact
        backend:
          service:
            name: sw-web
            port:
              number: 443
EOF

# Setup ingress
microk8s kubectl apply -f swimlane_ingress.yaml -n ${k8namespace}

# Get the dns server of the host
export dnsservers=$(resolvectl status | grep -o -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")

# Create the swimlane dns configuration
sudo tee dns_config.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: swimlane-dns-config
  namespace: ${k8namespace}
spec:
  containers:
    - name: dns
      image: nginx
  dnsPolicy: "None"
  dnsConfig:
    nameservers:
      - ${dnsservers}
EOF

# Setup dns
microk8s kubectl apply -f dns_config.yaml -n ${k8namespace}

# Setup the kotsadm service
sudo tee kots_config.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: kotsadm
  namespace: ${k8namespace}
spec:
  type: NodePort
  ports:
  - port: 3000
    nodePort: 31000
  selector:
    app: kotsadm
EOF

# Setup dns
microk8s kubectl apply -f kots_config.yaml -n ${k8namespace}

# Get the hostname and ipv4 address of the current machine
export ipv4_address=$(hostname -I | awk '{print $1}')
export hostname=$(hostname)

# Print messages for swimlane information
echo "The Swimlane administrator panel can be accessed using 'http://${hostname}:31000' or 'http://${ipv4_address}:31000'."
echo "Once Swimlane has been configured from the administrator panel, the Swimlane instance can be accessed using 'https://${hostname}' or 'https://${ipv4_address}'."