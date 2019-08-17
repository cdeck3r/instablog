+++
title = "Deployment and Execution"
description = "How to run instablog"
date = "2019-08-17"
author = "Christian Decker"
sec = 20
+++


The software shall run on a Linux Server. We assume, the instablog installation resides in `$HOME/instablog`.

### Update

Initially clone this repo. This will create the `instablog` directory.

``` bash
cd $HOME
git clone https://github.com/cdeck3r/instablog.git
cd instablog
```

Run the `update_instablog.sh` script to update the `instablog` installation from the [Github repo](https://github.com/cdeck3r/instablog). Note, the update script hard-codes the installation directory.

### Run instablog

You may run instablog using a wrapper script or manually.

#### Run instablog as a cronjob.

The wrapper script may be used as entry script for a cronjob.
Install a cronjob calling the following script.

``` bash
$HOME/instablog/deploy/cron_instablog.sh
```

The `cron_instablog.sh` activates the venv, defines the data directory and the URLs for the Instagram profile and the Github blog. It runs `instablog.sh` script and at the end, the script deactivates the venv.

#### Run instablog manually

First, change into the instablog installation directory.
``` bash
cd $HOME/instablog
```

Create the virtualenv `venv` and activtate it.
``` bash
# activate virtualenv
make venv
source venv/bin/activate
```

Run the instablog main script.
``` bash
DATAROOT = ...
PROFILE_URL = ...
GITHUB_URL = ...

cd scripts
./instablog.sh -r "$DATAROOT" -p "$PROFILE_URL" -g "$GITHUB_URL"
```

Finally, deactivate the `venv` again.
``` bash
cd $HOME/instablog
deactivate
```
