**This is archvied, this is no longer of use.**

# jupyterhub4family
Jupyterhub instant on for Papa's and Mam's administrating their family ;) and all other who can make use of it.

Meaning Jupyterhub, but easy 
-   no docker
-   no containers
-   no kubernetes
-   no helm charts
-   no cloud

actually just your PC/Laptop on Debian 11 and thats it.

And just to be clear nothing wrong about the technologies listed above, if you would like to learn them perfect,
if you like to administrate them let's go, I have choosen the way of KISS - Keep It Stupid Simple -. 

# What is in the box
One gets a running jupyterhub with sudospawner on a standalone debian (11) setup, it may work on others but thats on you.
My family runs there business on Debian, therefore **this is the way** (and yes i kept my helmet on ;)). 

Some setups run in a LXC-Container on a proxmox server some on Laptops for takeaway.

# How to open the box / install it

Just download the released .deb and run dpkg -i as root, after that you go for apt install --fix-broken and you are good.
(you can also clone the repo and use the buildscript to build it local on your machine, if that helps for some reason. If you have a local repo just copy over and update the index.)

```
dpkg -i <deb-pkg>
apt update && apt install --fix-broken
```

In case you like a non-deb way checkout [docs/README.md](docs/README.md).

# How does it work.
The architecture splits up into 3 main parts.

- The **Root**-Part
    - First of all the service account **jupyterhub** is created (password-disabled), including a unix-group (jupyterhub) which comes along with the same name.
    - As it uses **sudospawner** we need sudo and a configuration. The configuration allowes the **jupyterhub**-service account to impersonate all members of the unix-group **jupyterhub** in order to start the jupyterhub-singleuser process.
    - Last but least, a **jupyterhub_adm** group is create for administrative delegation, members of this group are allowed to add members to the **jupyterhub** group.
- The **Service**-Part
    - jupyterhub itself gets setuped 100% in userspace, so all python and npm packages are installed locally under the account "jupyterhub".
    - a user cronjob is uses to start it.
- The **User**-Part
    - if you are member of the jupyterhub-group you can login on the jupyterhub portal (default: https://127.0.0.1:8000) and use your server (named-servers enabled). 
    - During first spawn (which may fail - as the timeout maybe reached) - the spawner installs all needed packages into your account.
    - **Hint**: if you need different setups - use different accounts to get this as cheap as possible, means you can install packages/up and downgrade as you like. The Spawner gets only active if juypterhub-singleuser, jupyterlab or jupyter-notebook is missing.

# Docs

More details you find under [docs/README.md](docs/README.md)

# Debugging

In case something does not run as expected you have to make your hands dirty, just impersonate the jupyterhub account and use **screen -r** to attached to the running jupyterhub instance it was started in debug mode and will provide you some ideas. Beyond that you have to know what to do.

# Roadmap

- Pre-Release items:
    - TODO: Review security settings of the jupyterhub setup.
    - DONE: Enable per default self-signed https for login
    - DONE: Complete the non-deb docs.
    - DONE: Decide if package should be called jupyterhub or jupyterhub4family -> decided to jupyterhub4family as it is not jupyterhub it is a software appliance for a dedicated purpose.
    - DONE: move service-bootstrap away from deb-package installations success path.
- Release 1.0.0:
- Next Level items:
    - TODO: Decide on providing an auto-upgrade function.
    - TODO: Decide on if the setup should be based on conda instead of native debian foundation.
    - TODO: Decide if a node jump is needed for e.g. bigger workloads (exceeding the local low budget laptop, maybe mam or dad has a big NAS in the basement)

Thats it.
Enjoy.
