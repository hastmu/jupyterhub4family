# jupyterhub4family
Jupyterhub instand on for Papas and Mamas administrating their family ;) and all other who can make use of it.

# What is in the box
One gets a running jupyterhub with sudospawner on a standalone debian (11) setup, it may work on others but thats on you.
My family runs there busyness on Debian, therefore this is the way to go. Some setups run in a LXC-Container on a proxmox server some on Notebooks for takeaway.

# How does it work.
The architecture splits up into 3 main parts.

- The Root-Part
    - As i use sudospawner we need sudo installed and configured, the configuration look more or less like this the jupyterhub-service account can impersonate all members of the "jupyterhub"-group to start the jupyterhub-singleuser server.
    - In addition the service-account "jupyterhub" is created.
- The Service-Part, jupyterhub itself gets setuped 100% in userspace, so all local installed under the account "jupyterhub".
- The User-Part, if you are member of the jupyterhub-group you can login on the jupyterhub portal (default: 8000) and use your server (named-servers enabled). During first spawn (which may fail - as the timeout maybe reached) - the spawner installes all needed packages into your account. (Hint: if you need different setup - use different accounts to get this as cheap as possible, means you can install packages/up and downgrade as you like. The Spawner gets only active if juypterhub-singleuser, jupyterlab or jupyter-notebook is missing)

Thats it.
Enjoy.