ToDo List
=========

### Core Functionality
* Finish the `scripts/intialize.sh` script.  Maybe we should create a binary to help configure
  the contained system?
* Create `scripts/start.sh` to start contained:local.
* Verify the capabilities are minimum but sustainable.
* Implement the `iptables` restrictions on `http://169.254.169.254`
* Implement the `iptables` restrictions to block access to the Docker ports.
* Implement an AppArmor policy to restrict the privileged container (this may cause 
  issues in macOs for dev environments).
  
### Demo Project
* Create some example container images (web server plus redis server).
* Create a demo.sh script to demonstrate how the project can be used.