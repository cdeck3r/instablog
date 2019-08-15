# generic, util
import click
import logging
from pathlib import Path

# website download and parsing
import json
import requests
from bs4 import BeautifulSoup
from lxml.html.soupparser import fromstring

# reading and writing files
import sys
import csv
import os
import pandas as pd


def load_post_info(post_file, blog_date):
    logger = logging.getLogger(__file__)
    logger.info('Load post info from file: %s', post_file)

    post_info_df = pd.DataFrame()
    blog_date = pd.to_datetime(blog_date).date()

    try:
        post_info_df = pd.read_csv(post_file, sep=';', encoding='utf-8')
    except:
        # log error handling
        logger.error('Error reading file : %s', post_file)
        sys.exit(1)

    # convert to datetime
    post_info_df['uploadDate'] = pd.to_datetime(post_info_df['uploadDate'])
    post_info_df['post_date'] = [d.date() for d in post_info_df['uploadDate']]
    # now filter
    logger.info('Filter for post date: %s', blog_date)
    post_info_df_filtered = post_info_df[ (post_info_df['post_date'] == blog_date) ]

    if len(post_info_df_filtered) < 1:
        logger.warning('No post info found. Maybe filtered out?')
    else:
        logger.info('Number of post info loaded: %d', len(post_info_df_filtered))

    return post_info_df_filtered

#
# Classify posts
#
# presentation: pres_type
# * fullscreen
# * regular
# * leftright
# * album
#
# description type: desc_type
# * caption
# * paragraph
#
def classify_posts(post_info_df):
    # Heuristics
    post_count_threshold = 2
    caption_len_threshold = 25
    caption_huge_threshold = 200
    album_threshold = 12
    album_img_count = 4

    # few images --> regular
    if len(post_info_df) <= post_count_threshold:
        post_info_df['pres_type'] = 'regular'

    # single image --> fullscreen
    if len(post_info_df) <= 1: # single post
        post_info_df['pres_type'] = 'fullscreen'

    for index, post in post_info_df.iterrows():
        if len(post['caption']) <= caption_len_threshold:
            post['desc_type'] = 'caption'
        else:
            post['desc_type'] = 'paragraph'

    if len(post_info_df) <= post_count_threshold:
        return post_info_df

    #
    # post counts > post_count_threshold
    #
    for index, post in post_info_df.iterrows():
        if len(post['caption']) <= caption_huge_threshold:
            post['pres_type'] = 'regular'
            post['desc_type'] = 'caption'
        else:
            post['pres_type'] = 'leftright'
            post['desc_type'] = 'paragraph'

    # many short captions: album with caption
    seriesObj = post_info_df.apply(lambda x:
                                    True
                                        if ((x['pres_type'] == 'regular' )
                                        and (x['desc_type'] == 'caption'))
                                    else False , axis=1)
    numOfRows = len(seriesObj[seriesObj == True].index)

    # decide on albums
    if numOfRows > album_threshold:
        # we define albums
        img_idx = 0
        for index, post in post_info_df.iterrows():
            if (post['pres_type'] == 'regular') and (img_idx % album_img_count == 0):
                post['pres_type'] = 'album'
                img_idx = img_idx + 1

    return post_info_df


def pres_fullscreen(post):
    entry = """<figure class="large" markdown="1">"""
    entry = entry + """<p><img src=" """
    entry = entry + post[post_image_url]
    entry = entry + """ alt="" /></p> """

    if post['desc_type'] == 'caption':
        entry = entry + "<figcaption>"
        entry = entry + post['caption']
        entry = entry + "</figcaption>"
    entry = entry + "</figure>"

    if post['desc_type'] == 'paragraph':
        entry = entry + "<p>" + post['caption'] + "</p>"

    return entry


def pres_regular(post):
    entry = "<figure>"
    entry = entry + """ <img src=" """
    entry = entry + post['post_image_url']
    entry = entry + """ " /> """

    if post['desc_type'] == 'caption':
        entry = entry + "<figcaption>"
        entry = entry + post['caption']
        entry = entry + "</figcaption>"
    entry = entry + "</figure>"

    if post['desc_type'] == 'paragraph':
        entry = entry + "<p>" + post['caption'] + "</p>"

    return entry


def pres_leftright(post, lr_idx):
    entry = '<p><img src=" '
    entry = entry + post['post_image_url']

    if lr_idx % 2:
        entry = entry + """#right" alt="" />"""
    else:
        entry = entry + """#left" alt="" />"""
    pass
    entry = entry + "</p>"
    if post['desc_type'] == 'paragraph':
        entry = entry + "<p>" + post['caption'] + "</p>"

    return entry

def create_post_entries(post_info_df):

    # first: sort uploadDate asc
    post_info_df = post_info_df.sort_values(by=['uploadDate'])

    # apply heuristics to indicate for each entry
    # the type of presentation
    post_info_df = classify_posts(post_info_df)

    # posts are classified
    # let's render the presentation
    lr_idx = 0
    for index, post in post_info_df.iterrows():
        if post['pres_type'] == 'fullscreen':
            post['post_entry'] = pres_fullscreen(post)
        if post['pres_type'] == 'regular':
            post['post_entry'] = pres_regular(post)
        if post['pres_type'] == 'leftright':
            post['post_entry'] = pres_leftright(post, lr_idx)
        lr_idx = lr_idx + 1

def download_posts(insta_posts_shortcodes):

    logger = logging.getLogger(__file__)

    if len(insta_posts_shortcodes) < 1:
        logger.warning('No shortcodes found for download')

    # data structure holding all info
    post_info_df = pd.DataFrame(columns=['shortcode', 'caption', 'uploadDate', 'post_content_type', 'post_image_url'])

    for shortcode in insta_posts_shortcodes:
        insta_post_url = 'https://www.instagram.com/p/' + shortcode + '/'
        logger.info('Downloading post: %s', insta_post_url)

        insta_post = requests.get(insta_post_url, allow_redirects=True)
        if insta_post.status_code != 200:
            logger.error('Unexpected error code while downloading: %d', insta_profile.status_code)
            continue

        # this is the good case
        post_info = []
        post_info.append( shortcode )
        # let's parse the website
        soup = BeautifulSoup(insta_post.text, 'lxml')

        ##################################
        # Post desciptive information
        ##################################
        # find json data and parse the data from the website
        post_data_str = soup.find(attrs={"type": "application/ld+json"}).string
        # remove any leading and trailing whitespaces such as \n, \r, \t, \f, space.
        post_data_str = post_data_str.strip()
        # prep string for json parsing
        post_json = json.loads(post_data_str.replace("\n","\\n"))

        post_info.append( post_json["caption"] )
        post_info.append( post_json['uploadDate'] )

        ##################################
        # Post media
        ##################################
        #    <meta name="medium" content="image" />
        #
        post_content_type = soup.find('meta', attrs={"name": "medium"})['content']
        logger.info('Found the content-type: %s', post_content_type)
        post_info.append( post_content_type )

        post_image_url = soup.find('meta', attrs={"property": "og:image"})['content']
        post_info.append( post_image_url )

        # collect all info in DataFrame
        post_info_df.loc[len(post_info_df)] = post_info

    logger.info('Downloaded instagram posts: %d', len(post_info_df))

    return post_info_df

def store_posts(post_file, post_info_df):

    logger = logging.getLogger(__file__)
    logger.info('Write data in file: %s', post_file)

    try:
        post_info_df.to_csv(post_file, sep=';', encoding='utf-8', index=False)
    except:
        # log error handling
        logger.error('Error writing file : %s', pos_file)
        sys.exit(1)


#############################################
# Main
#############################################
@click.command()
@click.argument('post_file',
                type=click.Path(exists=True, dir_okay=False) )
@click.argument('blog_file',
                type=click.Path(exists=False, dir_okay=False, writable=True) )
@click.argument('blog_date',
                type=click.DateTime(formats=['%Y-%m-%d']) )
@click.option('--no-filter', '-f', required=False,
                type=click.DateTime(formats=['%Y-%m-%d']) )
def blogpost(post_file, blog_file, blog_date, no_filter):
    """
        post_file Filepath containing all relevant information for each Instagram post
        blog_file Filepath containing the blog post, usually a .md markdown file
        blog_date Date of blog entry, format: YYYY-MM-DD
    """

    logger = logging.getLogger(__file__)
    logger.info('Start creating blog post')

    post_info_df = load_post_info(post_file, blog_date)
    #post_entry_df = create_post_entries(post_info_df)
    #post_frontmatter = create_post_frontmatter(post_info_df, blog_date)
    #store_blog(blog_file, post_frontmatter, post_entry_df)

    logger.info('Blog post created.')
    pass


#############################################
# Entry
#############################################
if __name__ == '__main__':
    log_fmt = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    logging.basicConfig(level=logging.INFO, format=log_fmt)

    # not used in this stub but often useful for finding various files
    project_dir = Path(__file__).resolve().parents[2]
    # start the crawler
    blogpost()
