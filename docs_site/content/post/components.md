+++
title = "Components"
date = 2019-08-12T19:13:13Z
description = "System design"
sec = 5
+++

### instacrawler

Instacrawler collects URLs of posts from an Instagram's profile feed. It identifies posts by their short code - an alphanumeric string, such as `BhRpkfqgnsf`.

The software component consists of two parts.

* `instacrawler.sh` Defines the profile URL and the file storing posts' shortcodes as `.csv` file. Afterwards, it calls the python script to do the work.
* `instacrawler.py` Downloads the profile website, extracts the shortcodes and stores them in `.csv` file.

**Invoke instacrawler:** The entry point is always the shell script.

``` bash
./instacrawler.sh /tmp https://www.instagram.com/koloot.design/
```

This will let the instacrawler download the profile's feed of koloot.design and store all found posts as shortcodes in the `/tmp/shortcodes.csv`. Note, the filename is defined _within_ the script in order to hide the components' data sharing via the filesystem from the user.

**Note:** Instagram shows only up 12 recent posts in a profile's feed. The number of shortcodes is therefore limited to 12 recent posts.

### instapost

Instapost downloads Instagram post information. A shortcode, e.g. `BhRpkfqgnsf`, acquired from Instacrawler refers to a single post's URL in the form of `https://instagram.com/p/BhRpkfqgnsf`.


The software component consists of two parts.

* `instapost.sh` Defines the file storing relevant Instagram post information as `.csv` file. Afterwards, it calls the python script to do the work.
* `instapost.py` Downloads post for each shortcode in the shortcode file and extracts relevant information and stores it in a `.csv` file.

**Invoke instapost:** The entry point is always the shell script.

``` bash
./instapost.sh /tmp
```

Only a data directory, here `/tmp`, needs to be defined. The script assumes _all data files_ to stay in this data directory. The input shortcode file is assumed to be `shortcodes.csv`. The output file storing the relevant post information is `postinfo.csv`.


### blogpost

Blogpost creates a blog post from the Instagram posts information. This component is _specific for the blog_ where the post appears. The [component's code](https://github.com/cdeck3r/instablog/blob/master/src/blogpost.py) is specific for the [dramalamas.tours blog](//dramalamas.tours) and its [jekyllDecent theme](https://github.com/jwillmer/jekyllDecent).

The software component consists of two parts.

* `blogpost.sh` Defines the Instagram post information source file as well as the filepath to the blogpost file. Addtionally, it requires the blog date. Afterwards, it calls the python script to do the work.
* `blogpost.py` Filters the post information file for the blog date and creates the blogpost file formatted to be compliant with the [jekyllDecent theme](https://github.com/jwillmer/jekyllDecent).

**Invoke blogpost:** The entry point is always the shell script.
``` bash
./blogpost.sh /tmp 2019-08-16 https://github.com/<user>/<repo>.git
```

The `/tmp` directory serves a dataroot. Filenames are set by convention through the script. The blog date must be in format YYYY-MM-DD. A successful script run will generate `2019-08-16-instablog.md` file the `/tmp` directory when called with the parameters from above. At the end the scripts uploads the newly created file to the github repository specified the last parameter.
