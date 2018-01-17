Creating a user
---------------

Creating a user is as simple as:
```sh
cf create-user lexsys "a1tor0s"
```

Note that the user has been created, but they are not assigned to any org or space.

Managing user roles
-------------------

Cloud Foundry has a built-in RBAC (Role Based Access Control) system that allows you to control what a user can or cannot do inside an organization or a space.

The basic roles provided by Cloud Foundry are well described in the official documentation:

* [Organization roles](https://docs.cloudfoundry.org/concepts/roles.html#org-roles)
* [Space roles](https://docs.cloudfoundry.org/concepts/roles.html#space-roles)

What a user is going to be able to do in Cloud Foundry is the combination of the roles that the administrator has set for that user.

Roles can be set very easily, using the `set-org-role` and `set-space-role` commands from the CLI.

Let's set one organization role and one space role for the user we have just created:

```sh
cf set-org-role lexsys riman OrgAuditor
```

**Tip:** If you would like to see the roles available for you to choose from, simply do `cf set-org-role` and you will get a listing of the roles. The same applies to the `set-space-role` command.

Now, we are going to assign a space role. Remember that a user can have any combination of roles.

```sh
cf set-space-role lexsys riman hyper SpaceDeveloper
```

Getting info about users and roles
----------------------------------

How do we get information about what user is assigned to what role in an organization or a space?

There are two very useful commands for this: `org-users` and `space-users`.

Try the first one:

```sh
cf org-users riman
```

The same can be done for spaces:

```sh
cf space-users riman hyper
```

Removing roles
--------------

You might have noticed in the previous step that the user `admin` has `Space Manager` and `Space Developer` roles. This is because Cloud Foundry will assign those roles automatically when an `admin` user creates a space.

You can remove roles from a `user/Org` or `user/Space` combination, using the `unset-org-role` and `unset-space-role` commands.

Let's leave `admin` as a `Space Manager`,  but remove the `Space Developer` role.

```sh
cf unset-space-role lexsys riman hyper SpaceDeveloper
```

Verify changes with `cf space-users` command:

```sh
$ cf space-users riman hyper
```

Deleting users
--------------

Let's delete the user we have just created:

```sh
cf delete-user lexsys -f
```

**Tip**: Note that we are forcing the confirmation with the `-f` modifier. If you don't include that modifier, the CLI will ask you for confirmation.


