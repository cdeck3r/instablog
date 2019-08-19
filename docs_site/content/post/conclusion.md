+++
title = "Conclusion"
description = "Summary, conclusion and next steps"
date = "2019-08-12"
author = "Christian Decker"
sec = 100
+++

This section concludes the project.

### Summary

The list below displays the achieved objectives:

* [x] To setup a github project framework and development environment
* [x] To include a project blog for documentation
* [x] To enable automatic download of new instagram posts filtered by a given date
* [x] To enable the automatic creation of blog posts from instagram posts of that date
* [ ] To let the blog post have a URL reference back to the genuine instagram post
* [x] To run the blog post creation on a regular basis, e.g. at a hourly interval
* [x] To be able to single-click deploy the software on a Virtual Private Server
* [ ] Optionally: To enable a simple remote monitoring notifying the regular successful or failed run

### Conclusion

[Instablog](//github.com/cdeck3r/instablog) autonomously monitors our Instagram profile for new posts and creates a blog post containing on instagram post from a single day. The software runs on a virtual private server on the Internet. It successfully runs since three days and has shown this MVP's functionality for at least two different days.

### Final Note

I took this exercise as an test case how fast I develop a small end-to-end software. In particular, this encompasses the use of Docker, Makefile, various scripting languages, version control, parallel documentation and many other development activities.

Instablog runs unattended on a server on the Internet. The software is split into different small components. It is kept intentionelly lean by using the filesystem as middleware between components. I utilized the approach of [convention over configuration](https://en.wikipedia.org/wiki/Convention_over_configuration), not only to speed up development, but to achieve resilience, too.

Still, lots of things are missing. The shell scripts do not check for parameters when invoked. There are no unit tests at all. It is unclear what happens, if the scripts meet a video or other content other than images. The python code requires improvement. There are lots of `for` loops and `if/then` statements instead of `map` or `apply` and `switch/case` statements. The Instagram images link to a content delivery network (CDN). It is unclear, wether the links will stay constant over time. An enhancement option is to download the images and store them for the blog.  
