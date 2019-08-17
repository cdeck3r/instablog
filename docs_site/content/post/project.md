+++
title = "Project Definition"
description = "Goals, objectives and approach"
date = "2019-08-12"
author = "Christian Decker"
sec = 2
+++

Existing solutions sharing instagram posts within a blog explicitly embedd an post URL. This is a manual effort one has to do for every new instagram post entry. The Instagram JavaScript plugin, [Instafeed.js](//instafeedjs.com), utilizes Instagram's API and retrieves new posts filtered by a user-defined function. As a result, a single blog post embedding this javascript would display a large list of Instagram post. However, it is unclear how a daily blog is generated which only contains the posts from that day.

### Goal

New posts on our [Instagram account](//www.instagram.com/dramalamas.tours2019/) shall automaically appear as daily blog posts on [our website](//dramalamas.tours).


### Approach & Objectives

* To setup a github project framework and development environment
* To include a project blog for documentation
* To enable automatic download of new instagram posts filtered by a given date
* To enable the automatic creation of blog posts from instagram posts of that date
* To let the blog post have a URL reference back to the genuine instagram post
* To run the blog post creation on a regular basis, e.g. at a hourly interval
* To be able to single-click deploy the software on a Virtual Private Server
* Optionally: To enable a simple remote monitoring notifying the regular successful or failed run

### Valueable Contributions

Instablog has some features, where it may have an advantage over alternative solutions.

* Keeps track of the complete feed history
* Highly modular and easy to extend because of a file system based interface using `.csv` files

However, instablog requires a Linux server to run. One may think to parasitically run instablog on [Travis](https://travis-ci.org/).

### Alternative Solutions

Other options of Instagram-Blog-crossposting include

* [Instafeed.js](//instafeedjs.com)
    * Pro: easy to embedd into a single blog post
    * Con: Still requires to manually create a blog post, filtering for a single date  unclear
* RSS feeds, e.g. [RSS Hub](https://docs.rsshub.app/en/#instagram) or [RSS.app](https://rss.app/rss-feed/create-instagram-rss-feed)
    * Pro: Structured data returned, easy to parse by a wide range of software
    * Con: Still requires to manually create a daily blog post
* Open Source, e.g. [Syncing Instagram posts to a Ghost blog](https://thomasclowes.com/syncing-instagram-posts-to-a-ghost-blog/)
    * Pro: existing code base, quick start for own projects
    * Con: limited to specific blog system, still requires customization effort
