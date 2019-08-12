+++
title = "Project Definition"
description = "Goals, objectives and approach"
date = "2019-08-12"
author = "Christian Decker"
sec = 2
+++

Existing solutions sharing instagram posts within a blog explicitly embedd an post URL. This is a manual effort one has to do for every new instagram post entry. The Instagram JavaScript plugin, [Instafeed.js](//instafeedjs.com), utilizes Instagram's API and retrieves new posts filtered by a user-defined function. As a result, a single blog post embedding this javascript would display a large list of Instagram post. However, it is unclear how a daily blog is generated which only contains the posts from that day.

### Goal

This project shall regularly monitor our [Instagram account](//www.instagram.com/dramalamas.tours2019/) and automatically create daily blog posts on [our website](//dramalamas.tours).

### Approach & Objectives

* To setup a github project framework and development environment 
* To include a project blog for documentation
* To enable automatic download of new instagram posts filtered by a given date
* To enable the automatic creation of blog posts from instagram posts of that date
* To let the blog post have a URL reference back to the genuine instagram post 
* To enable the software to monitor and run the blog post creation on a regular basis, e.g. at a hourly interval
* To be able to single-click deploy the software on a Virtual Private Server
* Optionally: To enable a simple remote monitoring notifying the regular successful or failed run

