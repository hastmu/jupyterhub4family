
Status: Work-in-Progress

# Administrate access to jupyterhub

In case you do not want to give up all administrative task on your setup, one is able to delegate the jupyterhub membership administration by adding the delegates to the **jupyterhub_adm** group. Done so they can use the provided member.sh script to add/remove/show members of the access group.

```
adduser <user> jupyterhub_adm
```

would add your trustworthy person-account to the admins of jupyterhub membership. Which then is able to execute the following.

## add
```
jupyterhub-member add <username>
```

## remove
```
jupyterhub-member remove <username>
```

## show
```
jupyterhub-member show
```

# Install without deb.

I made a asciinema cast for you, so please do the following.

```
sudo apt install asciinema
asciinema play -s <speed> https://github.com/hastmu/jupyterhub4family/raw/main/docs/install-without-deb.cast
```
for speed i recommend 1-10 - you can press space to pause at any time.

