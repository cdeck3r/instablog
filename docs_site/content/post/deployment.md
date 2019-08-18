+++
title = "Deployment and Execution"
description = "How to run instablog"
date = "2019-08-17"
author = "Christian Decker"
sec = 20
+++

The design of the instablog deployment consists of several scripts with the following features

* install from Github repository
* update from repository
* setup a cronjob for periodic execution
* update the Github hosted blog  

The software shall run on a Linux Server. Details of the server deployment and  detailed instructions how to run instablog manually and via a wrapper script are described in the [deployment instructions](https://github.com/cdeck3r/instablog/tree/master/deploy).

**Note:** To update the Github hosted blog instablog requires the appropriate user credentials. The user needs to configure the Github settings in order to retrieve the access token. Details are part of the [deployment instructions](https://github.com/cdeck3r/instablog/tree/master/deploy).
