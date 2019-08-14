+++
title = "instablog: Main Script"
date = 2019-08-14
description = "Details of the instablog main script"
sec = 6
+++


### instablog

The main script for automatically creating daily blog posts from Instagram posts. This script may run as a cronjob.

`instablog.sh` Defines basic interface parameters:

* data directory: storing all intermediate data for the exchange between instablog's other software components.
* profile URL: the Instagram profile URL sourcing the feed data from
* github repo URL: the URL to the github repo providing the jekyll blog

**Default values:** If no params are provided, instablog will fall back to default values; see [`instablog.sh`](https://github.com/cdeck3r/instablog/blob/master/scripts/instablog.sh).

**Invoke instablog:**

``` bash
./instablog.sh /tmp https://www.instagram.com/koloot.design/ https://github.com/dramalamas/dramalamas.github.io
```

Credentials to update the github repo are stored in an external `.env` file.

### "Recent Posts" Limit

The Instagram profile feed is limited to only recent posts, which Instagram defines to be 12 posts.

#### *Option 1: RSS feeds*

Typical RSS feed solution, e.g. [RSS Hub](https://docs.rsshub.app/en/#instagram) or [RSS.app](https://rss.app/rss-feed/create-instagram-rss-feed), have basically the same as the `instacrawler` component. The source all recent posts from a profile and provide an RSS output format containing posts' information. The limit still remains.

#### *Option 2: Instagram explore*

Explore brings up posts matching a tag. The tag `#iceland` brings up a page with lots of posts associated with this tag. Just have a look on [`https://www.instagram.com/explore/tags/iceland/`](https://www.instagram.com/explore/tags/iceland/). Interestingly, the page data refers to 76 individual posts. The `instacrawler` component can successfully process the explore URL, extracts and stores all 70+ shortcodes. It means, however, that all DramaLamas Instagram posts must be specifically tagged to separate the DramaLamas posts from others. Still, we can't avoid free riding. When others would use this tag, their posts would make it into our blog.

#### *Option 3: State-based Crawler*

This idea is simple and effective. After each run of the `instacrawler` component, it simply adds the current posts to the ones from the previous run. Run after run, it builds up history of posts. The frequency of the crawler's runs depends on how often we would post new images on Instagram. The recent post limit is only valid for a single website lookup. If the crawler runs frequently enough, the risk is low it would miss any post.

Option 3 is easy to implement. The `instablog` main script records the results file, that is the `shortcodes.csv` file, of each instacrawler run throughout the day. It merges the current file with all the last ones, removes duplicates and provides the results to the `instapost` script for the next step.