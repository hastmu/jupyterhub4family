# jupyterhub4family
Jupyterhub instand on for Papas and Mamas administrating their family ;) and all other who can make use of it.

# What is in the box
One gets a running jupyterhub with sudospawner on a standalone debian (11) setup, it may work on others but thats on you.
My family runs there busyness on Debian, therefore this is the way to go. Some setups run in a LXC-Container on a proxmox server some on Notebooks for takeaway.

# How does it work.
The architecture splits up into 3 main parts.

- The **Root**-Part
    - First of all the service account **jupyterhub** is created, including a unix-group (jupyterhub) which comes along with the same name.
    - As it uses **sudospawner** we need sudo and a configuration. The configuration allowes the **jupyterhub**-service account to impersonate all members of the unix-group **jupyterhub** in order to start the jupyterhub-singleuser process.
- The **Service**-Part
    - jupyterhub itself gets setuped 100% in userspace, so all python and npm packages are installed locally under the account "jupyterhub".
    - a user cronjob is uses to start it on reboot.
- The **User**-Part
    - if you are member of the jupyterhub-group you can login on the jupyterhub portal (default: 8000) and use your server (named-servers enabled). During first spawn (which may fail - as the timeout maybe reached) - the spawner installs all needed packages into your account. (Hint: if you need different setup - use different accounts to get this as cheap as possible, means you can install packages/up and downgrade as you like. The Spawner gets only active if juypterhub-singleuser, jupyterlab or jupyter-notebook is missing)

Thats it.
Enjoy.