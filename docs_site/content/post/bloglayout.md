+++
title = "blogpost: Layout"
date = 2019-08-16T00:20:13Z
description = "Layout options when creating a blogpost "
sec = 6
+++

The `blogpost` component, to be specific the `blogpost.py` script, determines the the blogpost's layout. This includes frontmatter information, such as title and cover image as well as post content like image alignment and captions.

### Title

The `blogpost` component enumerates blog posts by the day in relation to a reference date. In our case, the reference date is the tour start. As a result, titles refer to the tour day.

### Cover Image

This is also part of the post's frontmatter. From all Instagram images selected for this post the script chooses one by random to declare it as the cover image.

### Image Alignment and Captions

The dramalamas.tours blog theme aligns images in the following ways.

* fullscreen: images takes the complete browser window width
* regular: images takes the text block width
* left or right: stamped-size left and right alignment
* album: images aligned in a banner to be scrolling left/right

The [theme's example site](https://jwillmer.github.io/jekyllDecent/blog/features/Features) provides a nice overview. All images can be zoomed in to browser size or even on the entire screen size by clicking on it.

The `blogpost.py` script implements a couple of heuristics to align images according the options listed above. The selection mainly depends on

* the number of images selected for this blogpost
* the length of the images' captions

The following thresholds define the behavior.
```
post_count_threshold = 2
caption_len_threshold = 25
caption_huge_threshold = 200
album_threshold = 8
album_img_count = 4
```

#### **Blog Post with Few Images**

If the number of selected entries is less or equal than `post_count_threshold`, we speak about a blog post with only a few images.

**fullscreen.** A single image is always aligned as a fullscreen image.

**regular.** If there are less or equal than `post_count_threshold` images, they are aligned as regular images.

**caption or paragraph.** If an entry's caption is less or equal `caption_len_threshold`, an image is described by a caption. Otherwise, a separate paragraph below the image will include the caption.

#### **Blog Post with Many Images**

If the number of selected entries exceeds the `post_count_threshold`, we speak about a blog post with many images.

**regular.** For short image captions, i.e. if an entry's caption is less or equal than `caption_huge_threshold`, the image will be aligned as regular with a caption.

**leftright.** Otherwise, if there is long image caption, i.e. if an entry's caption is greater than `caption_huge_threshold`, the image will be aligned alternatingly as left or right image. A separate paragraph will hold the the caption.

**album.** If we find many regular aligned images, i.e. more than `album_threshold`, we realign regular images as album images. Remember that regular aligned images always correspond with captions as their description. An album will not change it. Each album image includes an image caption. The size of the album is controlled by `album_img_count` parameter. The album consists of `album_img_count` images and the next images is a regular aligned one again.
