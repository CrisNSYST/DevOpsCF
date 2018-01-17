Operating Cloud Foundry
=======================

## What you are going to learn

In this section, you will learn how to:

-	Connect to a Cloud Foundry deployment
-	Create users
-	Create organizations and spaces
-	Assign permissions
-	Target an organization and space
-	Deploy a very simple application
-	Scale an application up and down

Connecting to the Cloud Foundry API
------------------------

Cloud Foundry provides an API endpoint to perform different operations and interact seamlessly with the the platform .

Using the CLI requires that you connect to the CF API endpoint for the CLI to know where to send the commands.

To configure the CLI to point to Cloud Foundry's API endpoint, you need to use the `cf api` command.

```sh
cf api --skip-ssl-validation https://api.cf.altoros.com
```

If the connection was successful, the following information will be displayed:

```
Setting api endpoint to https://api.cf.altoros.com
OK
```

**Important**: we are using `--skip-ssl-validation` since the Cloud Foundry deployment we are using for this course doesn't have a trusted SSL certificate installed. But as a good practice for development and testing, and mandatory for production, a trusted SSL cert should be used.

Now, you need to provide credentials. This is accomplished through the
interactive command `cf login`. Enter user name `admin` when asked for Email.

**Tip**: you can also use the `cf login` command setting the API: `cf login --skip-ssl-validation -a https://api.cf.altoros.com`

Create your first user
----------------------

Before doing anything, you need to create a user to perform day-to-day operations.

Creating a user is as simple as:

```sh
cf create-user jeffsmith SomeStrongPassword123
```

Create an Organization
----------------------

Cloud Foundry's organizational structure allows the use of "Organizations" and "Spaces". Each *Org* and *Space* can have multiple users assigned. All applications, services, and users are bound to Orgs and Spaces, so you need to create at least one Org to move forward:

```sh
cf create-org gauss
```

Create a Space
--------------

Spaces are very useful — they provide separation of concerns. For example, you can have "Dev", "Test," and "Staging" spaces in a single Cloud Foundry foundation. To create a space, use the `cf create-space` command. Try it and see the help provided by the CLI. Create a space with your username in the Org **training**, called `test-space`:

```sh
cf create-space hyper -o gauss
```

Set permissions to a space
------------------------

You need to add the necessary permissions for your user to use the Org and Space you have created:

```sh
cf set-space-role jeffsmith gauss hyper SpaceDeveloper
```

Now, your user has permissions to deploy an application. But first and foremost, authenticate with your non-admin user credentials. This can be done with `cf auth` (as shown in the example) or with `cf login`.

Example:

```sh
cf auth jeffsmith SomeStrongPassword123
```

Target your Org and Space
-------------------------

Targeting an Org and a Space means that all operations you will be doing will be performed in that Org and Space.

Targeting is done with the `cf target` command.

Use `cf target` for setting the CLI in the `training` org and the space that you just created and assigned permissions to.

```sh
cf target -o gauss -s hyper
```

Deploy an application
---------------------

Clone this GitHub repository into your work directory:

```sh
git clone https://github.com/Altoros/cf-example-sinatra
cd cf-example-sinatra
```

Deploying an application in CF involves using the `cf push` command. In this case, we will use the following format: `cf push application-name`. For example, if we use `Sinatra-Example-app`, the command will be:

```sh
cf push kelvin
```

CF will deploy the application and display its URL, in this case, it will be
something like `http://kelvin.cf.altoros.com`.

Viewing logs
------------

To view logs for a given application, run the `cf logs` command. You must specify the application name as a parameter.

Use `cf apps` to view the URL for the app.
```
cf apps
```

Use `cf logs` to view the real-time logs:
```
cf logs kelvin
```

Generate traffic by browsing to the app URL (`http://kelvin.cf.altoros.com`).  After a brief moment, the application logs will stream into your console. Use `Ctrl-C` to stop `cf logs`.

Scaling applications
--------------------

There are two ways to scale applications in CF: vertical and horizontal. Use the `cf scale` command to try both scaling strategies:

## Scale *vertically* by increasing the memory of the instance.

```sh
cf scale kelvin -m 512M
```

## Scale *horizontally* by adding more instances of the application.

```sh
cf scale kelvin -i 2
```

Next, reduce the number of application instances back to 1.

```sh
cf scale kelvin -m 256M -i 1
```
