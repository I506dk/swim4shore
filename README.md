# swim4shore

![sw-inline-logo-color](https://github.com/I506dk/swim4shore/assets/33561466/4d9bb750-e136-4bed-9ce3-ab0312c0854a)

A collection of utilities and tools for installing and configuring swimlane.

## Usage

The Mongo install script installs MongoDB as a standalone instance. Three users are created, one of which is named after the currently logged in user. The other two are named 'swimlane-user' and 'swimlane-history-user' and are used by swimlane. These two accounts are used in the 'Swimlane' and 'SwimlaneHistory' databases respectively.

First, install MongoDB on a standalone machine or virtual machine.
```
curl -O https://raw.githubusercontent.com/I506dk/swim4shore/main/install_mongo.sh
```
Next, make the mongo script executable using chmod:
```
chmod +x install_mongo.sh
```
Finally, run the swimlane script with sudo privileges
```
sudo ./install_mongo.sh
```

Download the swimlane install script using curl:
```
curl -O https://raw.githubusercontent.com/I506dk/swim4shore/main/install_swimlane.sh
```
Next, make the swimlane script executable using chmod:
```
chmod +x install_swimlane.sh
```
Finally, run the swimlane script with sudo privileges
```
sudo ./install_swimlane.sh
```
