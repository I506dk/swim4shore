# swim4shore

![sw-inline-logo-color](https://github.com/I506dk/swim4shore/assets/33561466/4d9bb750-e136-4bed-9ce3-ab0312c0854a)

A collection of utilities and tools for installing and configuring swimlane.

## Features

## Installation

The Mongo install script installs MongoDB as a standalone instance. Three users are created, one of which is named after the currently logged in user. The other two are named 'swimlane-user' and 'swimlane-history-user' and are used by swimlane. These two accounts are used in the 'Swimlane' and 'SwimlaneHistory' databases respectively.

First, install MongoDB on a standalone machine or virtual machine.
```
curl -O https://raw.githubusercontent.com/I506dk/swim4shore/main/install_mongo.sh
```
Next, make the mongo script executable using chmod:
```
chmod +x install_mongo.sh
```

Download the swimlane install script using curl:
```
curl -O https://raw.githubusercontent.com/I506dk/swim4shore/main/install_swimlane.sh
```
Next, make the swimlane script executable using chmod:
```
chmod +x install_swimlane.sh
```

## Usage

To run the swimlane script with sudo privileges:
```
sudo ./install_mongo.sh
```
To run the swimlane script with sudo privileges:
```
sudo ./install_swimlane.sh
```

## Swimlane Configuration


## Useful Commands
Below is a collection of useful commands for interacting with Kubernetes and Microk8s.

Get all nodes:
```
kubectl get nodes
```
Get all pods:
```
kubectl get pods -A
```
Get all services:
```
kubectl get services -A
```
Port forward a service (kotsadm in this example):
```
kubectl port-forward service/kotsadm 8800:3000 --address='0.0.0.0' -n <namespace_if_needed> 
```
Edit the current ingress configuration:
```
kubectl edit ingress -n <namespace_if_needed>
```
Apply a local configuration file (ingress configuration file in this example):
```
kubectl apply -f <my_ingress_file>.yaml -n <namespace_if_needed>
```
Perform an nslookup on a host from within the cluster (requires 'microk8s enable dns'):
```
kubectl exec -i -t dnsutils -- nslookup <hostname_or_ip_to_lookup>
```

## Troubleshooting
If MongoDB commands result in an "Illegal Instruction (core dumped)" error, change the cpu type to "host" instead of "kvm64" or anything else virtualized if using a hypervisor.
Otherwise, make sure the cpu supports the avx instruction set.