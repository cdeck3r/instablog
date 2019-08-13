+++
title = "Components"
date = 2019-08-12T19:13:13Z
description = "System design"
sec = 5
+++

### Instacrawler

Instacrawler collects URLs of posts from an Instagram's profile. It identifies them by their short code - an alphanumeric string, such as `BhRpkfqgnsf`.

The software component consists of two parts.

* `instacrawler.sh` Defines the profile URL and the file storing posts' shortcodes as `.csv` file. Afterwards, it calls the python script to do the work.
* `instacrawler.py` Downloads the profile website, extracts the shortcodes and stores them in `.csv` file.

**Invoke instacrawler**. The entry point is always the shell script.

``` bash
./instacrawler.sh /tmp https://www.instagram.com/koloot.design/
```

This will let the instacrawler download the profile of koloot.design and store all found posts as shortcodes in the `/tmp/shortcodes.csv`. Note, the filename is defined _within_ the script in order to hide the components' data sharing via the filesystem from the user. 

### Instapost

_tbd._

### instablog

_tbd._
