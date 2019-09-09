+++
title = "De-briefing"
description = "Summary, conclusion and next steps"
date = "2019-09-09"
author = "Christian Decker"
sec = 110
+++


The instablog software was in operation from August 20 until September 05, 2019. This section reviews the software's operation and performance.

### Hourly Operation

In the 16 days of operation instablog ran successfully every hour. It has updated in the [blog's website](//dramalamas.tours) in this hourly interval. The blog even correctly displayed emoticons included in the Instagram's posts captions.

**Conclusion:** The software operated stable throughout the 16 days of operation.

### Faults

As mentioned previously, there were no unit tests during the development. At the tour start day (August 22, 2019), this situation took revenge.

* Instagram posts on the start day were incompletely cross-posted on the blog's website.
* Tour day 2 and 3 have not been posted on the blog's website at all.

However, at the 4th tour day instablog's operation returned to normal. From that day on, all Instagram's posts have been successfully cross-posted again.

**Conclusion:** Unit test are valueable and should not be omitted. The instablog software is resilient.

### Analysis

After the rallye, we performed an error analysis. It revealed

* Incomplete log files: the log files only recorded the bash scripts' outputs, but not the log messages from the python's scripts. The reason was that the log file did not record the error channel.
* Complete shortcodes: the shortcodes acquired by the instacrawler component were complete for all days.

The feed_history component stored the Instagram's post shortcodes in files named according to the post date. This enables an instablog replay for past dates starting with the instapost component, which downloads the posts one after the other.

The replay revealed an exception in the instapost component. Latter was unable to process posts with empty captions.

**Conclusion:** The filesystem loosely couples the different software component together and persists the operational state. This enables the replay using the date-based Instagram feed history.

### Bugfixing

* Handle empty post captions: [bugfix #1](https://github.com/cdeck3r/instablog/commit/8cc0f2e2ecbe1e1d1b8edb6d59f4a2c77816e598#diff-a0b55a612e78a93ade88e90156987a72) and [bugfix #2](https://github.com/cdeck3r/instablog/commit/3b6f7bb0d2adcce3d08b4b35d65e075f1e3f9bb8) catch the exception when the software encounters empty captions.
* Incomplete log files: The [bugfix](https://github.com/cdeck3r/instablog/commit/47cbdbac377a77535fabf7e90c15734e10396165) redirect error channel to stdout  

After the bugfixing, we re-run instablog with the recorded feed_history to complete the missing tour days on the blog's website. All Instagram posts are now available on the [blog's website](//dramalamas.tours/).

**Conclusion:** After the bugfixing, the blog's website is complete.
