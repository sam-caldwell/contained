contained
=========
(c) 2019 Sam Caldwell.  See LICENSE.txt.

Purpose
-------
This project aims to simplify the environment-consistency problem and to simplify deployment
of container-based applications in bare-metal, cloud or other environments.  The envisioned 
end here is to facilitate developers being able to deploy a fully functional development 
environment using the `contained` pattern within minutes.


#### The Developer Environment Problem

We've all been there.  We start a new project or join a new team/company and spent a
long time setting up our dev environment to get the work done.  Usually this means following
some document that is either out of date, poorly written or written with a ton of assumptions
that may or may not be readily apparent to a n00b.  Containers addressed
this a bit for many companies.   But what if you could execute one privileged wrapper 
container that setup the entire environment on your laptop without tainting the underlying 
machine?


#### The Deployment Problem: Environment Drift

So we've gotten our dev environment up.  We've written code.  We're not a n00b anymore, and
then we end up on an incident where a bug made it to production because it wasn't caught in
our dev environment, our integration environment, our staging environment or anywhere before
hitting production.  The incident is customer facing and during the postmortem everyone says
the issue made it to prod because of "drift" between pre-production and production.  It should
not happen this way.  We can do better!  The `contained` project solves this because what goes
to prod is exactly what was in pre-production.  This project creates a wrapper container that
represents everything for a given stack just as it would be in production.  The chances of
drift are decreased without a bunch of wacky Ruby-based configuration management crap from 2005.


Implementation Details
----------------------
1. The project doesn't care if you are deploying docker containers to EC2, bare metal or
your local laptop.  The wrapper container executes with privilege on a vanilla system with 
minimal expectations.  Within the wrapper container, your application and its closely-related
side-car containers execute with minimum privileges they need to get the job done.

2. Running in Kubernetes?  No problem.  Your wrapper container is a single unit and that will
be constrained as a single unit of affinity.  Sure, that means you're grouping some parts in
one bundle rather than distributing them.  But that also means side-cars stay close by with 
the application container and they can be distributed with multiple instances of the wrapper
as we scale horizontally.  In the end what is important is that the container keeps the 
environment consistent.  The applications are protected from drift.


Getting Started
---------------
0. Create your project's git repository (local at least).

0. Open a terminal and navigate to your local project's empty git repo.

0. Clone this repository: `git clone git@github.com:sam-caldwell/contained.git`.

0. Execute `scripts/initialize.sh` on your local machine.  The initialization script will
   automatically--

    a. Delete the reference to `origin` as the contained repository. 
    
    b. Clone [contained-bootstrap](git@github.com:sam-caldwell/contained-bootstrap.git)
    
    c. Prompt for (y/n) for whether or not you wish you update the `origin` reference to
       your remote repository.  If 'y', the remote repository information will be updated.
       
0. Next you will open `contained-bootstrap` and edit the `Manifest` in `bootstrap.go` to 
   identify your services.  See comments in `bootstrap.go` for instructions.

0. Note that the `contained` project will pull built docker container images from either
   a local or remote docker registry.  It does not build them.  If you wish, you could 
   create a monorepo and do this.  But in most cases, you will probably be specifying the full
   location `Image` and appropriate `Tag` for each container in `bootstrap.go`.

0. Once `bootstrap.go` is fully defined, and after any other project-specific adjustments
   are made, execute `scripts/build.sh` to build your `contained` wrapper container.
   
0. The build script will compile `bootstrap.go` into a compressed, stripped binary that has
   two purposes:
   
    a. Provide a healthcheck for the wrapper container.
    
    b. Start all of the containers named in `bootstrap.go` as configured.

0. To start the environment (in any environment, simply use `docker run --privileged...`).
   Note that the `contained` container must run as `--privileged` but it will drop privileges 
   when the child containers are spawned.

At this point `contained` has setup a local development environment which can be iterated 
upon quickly.  All services run just as they will in pre- and post-production environments. 
When ready, the `contained` unit can be deployed to target environments with zero-touch.

Security Concerns
-----------------
Executing containers with `--privileged` should scare anyone.  But this is mitigated with a few
environmental precautions.

0. The `contained` wrapper container implements only the bootstrap and healthcheck.  It has
   no other functionality.  It does not interact with the underlying host.

0. ToDo: The `contained` wrapper container runs the child containers with minimal privileges.  In 
   fact, if network ports are set to zero (0) (default value), `bootstrap.go` will drop the
   network capabilities.

0. ToDo: The wrapper container implements a firewall (iptables) to block access to 169.254.169.254.

0. ToDo: The wrapper container implements a firewall (iptables) to block access to standard docker
   ports.
   
0. ToDo: The wrapper container implements AppArmor to restrict the privileged container 

0. ToDo: All child containers are executed as non-root users. 