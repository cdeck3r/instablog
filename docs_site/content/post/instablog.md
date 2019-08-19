+++
title = "instablog: Main Script"
date = 2019-08-14
description = "Details of the instablog main script"
sec = 7
+++

<style>
img {
  max-width: 100%;
  height: auto;
}
</style>

### instablog

The main script for automatically creating daily blog posts from Instagram posts. This script may run as a cronjob.

`instablog.sh` Defines basic interface parameters:

* data directory: storing all intermediate data for the exchange between instablog's other software components.
* profile URL: the Instagram profile URL sourcing the feed data from
* github repo URL: the URL to the github repo providing the jekyll blog

**Default values:** If no params are provided, instablog will fall back to default values; see [`instablog.sh`](https://github.com/cdeck3r/instablog/blob/master/scripts/instablog.sh).

**Invoke instablog:**

``` bash
$ ./instablog.sh --help
Usage: ./instablog.sh <options>

Options:

-h | --help              This message
[-r | --dataroot]        directory to exchange data betw. components
[-p | --profile]         Instagram profile URL
[-g | --github]          Github blog URL
[-d | --postdate]        blog post date, format: yyyy-mm-dd

Default DATAROOT: /tmp
Default PROFILE_URL: https://www.instagram.com/koloot.design/
Default POST_DATE: 2019-08-15

```
There is no default value for the github blog URL. If you leave this option out, it  will not update the remote blog. Credentials to update the github repo are stored in an external `.env` file.

The following activity diagram displays the workflow of all `instablog` components.
<img src="uml/instablog.png" alt="instablog activity diagram" width="100%"/>

### Feed History and the "Recent Posts" Limit

The Instagram profile feed is limited to recent posts  only, which Instagram defines to be 12 posts. We discuss three options to overcome this limit.

##### **Option 1: RSS feeds**

Typical RSS feed solution, e.g. [RSS Hub](https://docs.rsshub.app/en/#instagram) or [RSS.app](https://rss.app/rss-feed/create-instagram-rss-feed), have basically the same as the `instacrawler` component. The source all recent posts from a profile and provide an RSS output format containing posts' information. The limit still remains.

##### **Option 2: Instagram explore**

Explore brings up posts matching a tag. The tag `#iceland` brings up a page with lots of posts associated with this tag. Just have a look on [`/explore/tags/iceland/`](https://www.instagram.com/explore/tags/iceland/). Interestingly, the page data refers to 76 individual posts. The `instacrawler` component can successfully process the explore URL, extracts and stores all 70+ shortcodes. It means, however, that all user specific Instagram posts must be specifically tagged to separate them posts from others. Still, we can't avoid free riding. When others would use this tag, their posts would make it into our blog.

##### **Option 3: State-based Crawler**

This idea is simple and effective. After each run of the `instacrawler` component, it simply adds the current posts to the ones from the previous run. Run after run, it builds up history of posts. The frequency of the crawler's runs depends on how often we would post new images on Instagram. The recent post limit is only valid for a single website lookup. If the crawler runs frequently enough, the risk is low it would miss any post.

Option 3 is easy to implement. The `instablog` main script records the results file, that is the `shortcodes.csv` file, of each instacrawler run throughout the day. It merges the current file with all the last ones, removes duplicates and provides the results to the `instapost` script for the next step. The following sequence diagram depicts the embedding of the feed history feature in the `instablog` main script.

<img src="uml/instablog_feed_history.png" alt="feed history sequence diagram" width="546"/>

One thing left. Option 3 only works from the day on when `instablog` starts. It can't restore a feed history from the past. When `instablog` starts the regular operation from the first time, it initializes the feed history. Subsequently, it must frequently run with no longer breaks to keep up with the feed history.

### Feed History: State-based Crawler

The feed history feature extends the `instablog` main script.
It stores a copy of the current `shortcodes.csv` file as a date-stamp version, merges all versions of a day, and creates a new  `shortcodes.csv` file with the complete content. The next component, `instapost`, continues with the newly created shortcodes file.

The following activity diagram depicts how the [`feed_history.sh`](https://github.com/cdeck3r/instablog/blob/master/scripts/feed_history.sh) script works.

<img src="uml/feed_history.png" alt="feed history ac tivity diagram"  width="544"/>
