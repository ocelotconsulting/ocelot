This project is a fork of the https://github.com/MonsantoCo/ocelot repository. The MonsantoCo version is meant to be open source while this project makes a few tweaks that are Monsanto specific. These tweaks are pretty much for deploying to NPM Enterprise and a default config for running locally. 

Deviation from MonsantoCo:
* Default bin config file for running locally
* Changes to the package json for deploying to Monsanto's NPM enterprise

When deploying a new version to NPM Enterprise:
* Merge in the latest version of Ocelot from MonsantoCo on Github
* NPM Publish, make sure you have the ability to write to @monsantoit
