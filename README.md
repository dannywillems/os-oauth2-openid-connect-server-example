Instructions
============

This project is (initially) generated by `eliom-distillery` as the basic
project `oauth_server`.

Generally, you can compile it and run ocsigenserver on it by
```Shell
make db-init
make db-create
make db-schema
make test.byte (or test.opt)
```
Then connect to `http://localhost:8080` to see the running app skeleton.
Registration will work only if sendmail if configured on your system.
But the default template will print the activation link on the standard
output to make possible for you to create your first users (remove this!).

See below for other useful targets for make.

Generated files
---------------

The following files in this directory have been generated by
`eliom-distillery`:

- `oauth_server*.eliom[i]`
  Initial source file of the project.
  All Eliom files (*.eliom, *.eliomi) in this directory are
  automatically compiled and included in the application.
  To add a .ml/.mli file to your project,
  append it to the variable `SERVER_FILES` or `CLIENT_FILES` in Makefile.options.

- `static/`.
  This folder contains the static data for your Website.
  The content will be copied into the static file directory of the server.
  Put your CSS or additional JavaScript files here.

- `Makefile.options`
  Configure your project here.

- `oauth_server.conf.in`.
  This file is a template for the configuration file for
  ocsigenserver. You will rarely have to edit itself - it takes its
  variables from the Makefile.options. This way, the installation
  rules and the configuration files are synchronized with respect to
  the different folders.

- `mobile`
  The files needed by Cordova mobile apps

- `Makefile`
  This contains all rules necessary to build, test, and run your
  Eliom application. See below for the relevant targets.

- `README.md`


Makefile targets
----------------

Here's some help on how to work with this basic distillery project:

- Initialize, start, create, stop, delete a local db, or show status:
```Shell
make db-init
make db-start
make db-create
make db-stop
make db-delete
make db-status
```

- Test your application by compiling it and running ocsigenserver locally
```
make test.byte (or test.opt)
```

- Compile it only
```Shell
make all (or byte or opt)
```

- Deploy your project on your system
```Shell
sudo make install (or install.byte or install.opt)
```

- Run the server on the deployed project
```Shell
sudo make run.byte (or run.opt)
```

If `WWWUSER` in the `Makefile.options` is you, you don't need the
`sudo`. If Eliom isn't installed globally, however, you need to
re-export some environment variables to make this work:
```Shell
sudo PATH=$PATH OCAMLPATH=$OCAMLPATH LD_LIBRARY_PATH=$LD_LIBRARY_PATH make run.byte/run.opt
```

- If you need a findlib package in your project, add it to the
  variables `SERVER_PACKAGES` and/or `CLIENT_PACKAGES`. The configuration
  file will be automatically updated.

Build the mobile applications
-----------------------------

## Prepare the mobile infrastructure.

### For all mobile platforms:

- Install npm (on Debian and Ubuntu, `sudo apt-get install npm`).
- Install Cordova (`sudo npm install -g cordova`)
- Install the needed Cordova plugins:
```Shell
sudo npm install -g cordova-hot-code-push-cli read-package-json xml2js
```

### For Android:

- Install JDK 7 or newer (`openjdk-7-jdk` package in Debian/Ubuntu)
- Download and untar the [Android SDK](http://developer.android.com/sdk) (the smaller version without Android Studio suffices).
- Run tools/android
- Using the Android package management interface, install latest versions of SDK Tools, SDK Platform-tools, and SDK Build-tools
- Install Android API 23 (which corresponds to Android 6.0): SDK Platform.
- From Extras, enable the Android Support Repository and the Google Repository.
- For convenience, add the SDK directories platform-tools and tools in your $PATH

If you will test on an Android device, you don't need to do anything else.

If you want to emulate an Android device, you need to

- install qemu-kvm
- install a system image (e.g., Intel x86 Atom_64)
- configure an emulator: from the Android interface, go to Tools -> Manage AVDs -> Device definition (for example choose Nexus 6 no skin)

You can install any Android API version you want, depending on the platform you want to target. By default, in ocsigen-start, the minimal version is Android API 15.

### For iOS:

- Xcode installs all dependencies you need.

### For Windows:

Ocsigen-start uses
[cordova-hot-code-push-plugin](https://github.com/nordnet/cordova-hot-code-push)
to upload local files (like CSS and JavaScript files, images and logo) when the
server code changes.

Unfortunately, this plugin is not yet available for Windows Phone. However, as
ocsigen-start also builds the website part, an idea is to run the website into a
WebView on Windows Phones.

Even if Cordova allows you to build Windows app, it doesn't authorize you to
load an external URL without interaction with the user.

Another solution is to build an [Hosted Web
App](https://developer.microsoft.com/en-us/windows/bridges/hosted-web-apps). It
makes it possible to create easily an application based on your website. You can
also use Windows JavaScript API (no OCaml binding available for the moment) to
get access to native components. You can create the APPX package (package format
for Windows app) by using [Manifold JS](http://manifoldjs.com/), even if you are on MacOS X or Linux.

If you are on Windows, you can use [Visual Studio Community](https://www.visualstudio.com/fr/vs/community/). The Visual Studio Community solution is recommended to test and debug. You can see all errors in the JavaScript console provided in Visual Studio.

[Here](https://blogs.windows.com/buildingapps/2016/02/17/building-a-great-hosted-web-app/#3mlzw0giKcuGZDeq.97) a complete tutorial from the Windows blog for both versions (with Manifold JS and Visual Studio).

If you use the Manifold JS solution, you need to sign the APPX before installing it on a device.

## Launching the mobile app

he following examples are described for Android but they are also available for iOS: you only need to replace `android` by `ios`.

- Launch an Ocsigen server serving your app:
```
make test.opt
```
The mobile apps need to communicate with the server in order to retrieve data,
and thus we are assuming that the server is running at all times.

- To run the application in the emulator, use:

```
make APP_SERVER=http://${YOUR_IP_ADDRESS}:8080 APP_REMOTE=yes emulate-android
```

The above command will attempt to launch your app in the Android emulator that
you have configured previously. Depending on your setup, you may need to start
the emulator before running the command.

To run the application on a connected device, use:

```
make APP_SERVER=http://${YOUR_IP_ADDRESS}:8080 APP_REMOTE=yes run-android
```
Notice that the `APP_SERVER` argument needs to point to your LAN or public
address (e.g., `192.168.1.x`), not to `127.0.0.1` (neither to `localhost`). The
reason is that the address will be used by the Android emulator/device, inside
which `127.0.0.1` has different meaning; it points to the Android host itself.

If you only wants to build the mobile application, you can use:
```
make APP_SERVER=http://${YOUR_IP_ADDRESS}:8080 APP_REMOTE=yes android
```

## Update the mobile application.

To update the mobile application, you can use
```
make APP_SERVER=http://${YOUR_IP_ADDRESS}:8080 APP_REMOTE=yes chcp
```
