# swim4shore

![sw-inline-logo-color](https://github.com/I506dk/swim4shore/assets/33561466/4d9bb750-e136-4bed-9ce3-ab0312c0854a)

A collection of utilities and tools for installing and configuring swimlane.

## Features
- Automated configuration of MongoDB
- Create the necessay users and databases for Swimlane functionality
- Automated installation of Swimlane
- Automated configuration of services and DNS

## Installation

The Mongo install script installs MongoDB as a standalone instance. Three users are created, one of which is named after the currently logged in user.
The other two are named 'swimlane-user' and 'swimlane-history-user' and are used by swimlane. These two accounts are used in the 'Swimlane' and 'SwimlaneHistory' databases respectively.

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
The Swimlane administrator panel will allow for the backend configuration of Swimlane, and will be availiable on port 31000.

For example:
```
http://<swimlane_hostname_or_ip>:31000
```
This will present the login page. The password will be the same as the password set during the latter portion of the install script.

![kotsadm_login](https://github.com/I506dk/swim4shore/assets/33561466/15aaffdd-dfb4-49d5-a93e-6b157fb16d20)

Backend configurations for Swimlane can then be modified as needed.

![swimlane_ingress](https://github.com/I506dk/swim4shore/assets/33561466/86d5c24e-8b4d-4964-b33e-18d3d82230af)

In this specific case, the Mongo database was deployed outside of the Kubernetes cluster.

![mongo_external](https://github.com/I506dk/swim4shore/assets/33561466/aa0e8d23-2266-43c6-ad6f-db948d63653b)

There are two configurations that apply to the Mongo databases created using the "install_mongo" script.
The first is for the "Swimlane" database, and the second is for the "SwimlaneHistory" database.
The usernames will be "swimlane-user" and "swimlane-history-user", respectively. Enter the passwords that were set during the creation of these users.

If DNS is properly configured, the hostname of the Mongo database(s) can be used. Otherwise, use the IP address.
The port will be "27017" by default unless otherwise changed.

![swimlane_db](https://github.com/I506dk/swim4shore/assets/33561466/c0440c46-b694-4055-aa99-a1ec1cadb218)
![swimlane_history_db](https://github.com/I506dk/swim4shore/assets/33561466/2ca783f8-5bb0-4d70-ad25-d978773e2771)

## Useful Commands
#### Below is a collection of useful commands for interacting with Kubernetes and Microk8s.

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
Install dnsutils for troubleshooting DNS related issues:
```
kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
```
Perform an nslookup on a host from within the cluster (requires 'microk8s enable dns'):
```
kubectl exec -i -t dnsutils -- nslookup <hostname_or_ip_to_lookup>
```

## Troubleshooting
If MongoDB commands result in an "Illegal Instruction (core dumped)" error, change the cpu type to "host" instead of "kvm64" or anything else virtualized if using a hypervisor.
Otherwise, make sure the cpu supports the avx instruction set.
