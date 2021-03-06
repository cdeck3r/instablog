# instablog Deployment and Execution

Server software for automatically creating daily blog posts from Instagram posts

## Documentation Blog

The project has its own website under http://cdeck3r.com/instablog.

### Initial Installation

The software shall run on a Linux Server. We assume, the instablog installation resides in `$HOME/instablog`. Initially, clone the instablog repo when in `$HOME`. This will create the `instablog` directory.

``` bash
cd $HOME
git clone https://github.com/cdeck3r/instablog.git
cd instablog
```

### Update

After the initial installation further updates or changes can be installed.
Run the update script as follows.
```bash
$HOME/instablog/deploy/update_instablog.sh
```
It will update the `instablog` installation from the [Github repo](https://github.com/cdeck3r/instablog).

**Note:** The update script assumes `$HOME/instablog` as the installation directory.

### Github Credentials

When instablog updates the Github hosted blog website using `git` it requires the user creditials. The user needs to configure the website's Github repository to retrieve an access token. The token must be placed on the server in `$HOME/.env` which is included when instablog starts. The content of the file looks like the following

```
# dramalamas github
# https://github.com/dramalamas/dramalamas.github.io
# WRITE_PUBLIC_REPO
GITHUB_ACCESS_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXX"
```

The `.env` file is not included in the repository, because it contains the secret access token. The user must create the file and place it in `$HOME`.

### Run instablog

You may run the instablog main script from the command line or using a wrapper script in a periodic cronjob.

##### **Run from Command Line**

First, change into the instablog installation directory.
``` bash
cd $HOME/instablog
```

Then create the virtualenv `venv` and activtate it.
``` bash
make venv
source venv/bin/activate
```

Now, run the instablog main script after defining some variables used as script's parameters.
``` bash
DATAROOT = ...
PROFILE_URL = ...
GITHUB_URL = ...

cd scripts
./instablog.sh -r "$DATAROOT" -p "$PROFILE_URL" -g "$GITHUB_URL"
```

Finally, at the end, deactivate the `venv` again.
``` bash
cd $HOME/instablog
deactivate
```

##### **Run instablog as a cronjob**

The wrapper script may be used as entry script for a cronjob.
Install a cronjob calling the following script.

``` bash
$HOME/instablog/deploy/cron_instablog.sh
```

The `cron_instablog.sh` activates the venv, defines the data directory and the URLs for the Instagram profile and the Github blog. It runs `instablog.sh` script and at the end, the script deactivates the venv.

You install provided the cronjob example [instablog.crontab](https://github.com/cdeck3r/instablog/blob/master/deploy/instablog.crontab)

```bash
crontab instablog.crontab
crontab -l
```

The last line verifies that the cronjob got installed. The example schedules the script once an hour at minute 58. So, it runs 0:58, 1:58, 2:58, ...
