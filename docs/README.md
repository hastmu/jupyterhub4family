
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

## unpacking

## sudo-stuff

## service-install

## service-start

