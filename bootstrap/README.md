escontained-bootstrap
=====================
(c) 2019 Sam Caldwell.  See LICENSE.txt.

Purpose
-------
This project creates a golang bootstrap program used
by the contained project.  This program allows the contained
project to spawn one or many child containers and expose a 
healthcheck for observing the health of the contained environment.

Future Plans
------------
* Add TLS support for contained-bootstrap healthcheck.
 
* Add secrets management (interconnectivity with Vault, etc).

* Add an ability to spawn arbitrary child containers and
  configure the contained environment dynamically.

* Add an ability to check the state of child container health
  checks when the contained-bootstrap healthcheck is called.

* Implement a contained-bootstrap network proxy as the TLS 
  hand-off
  
Getting Started
---------------
* Using this directly is recommended only for development purposes.

* If you are not developing new features for this project, then use 
  this via the contained project.
  

