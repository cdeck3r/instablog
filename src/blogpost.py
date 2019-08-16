# generic, util
import click
import logging
from pathlib import Path
import random

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


def load_post_info(post_file, blog_date, no_filter):
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

    # filter for image content
    logger.info('Filter for image content')
    post_info_df_filtered = post_info_df[ (post_info_df['post_content_type'] == 'image') ]

    # now filter for blog_date
    if no_filter:
        # do nothing
        post_info_df_filtered = post_info_df_filtered
    else:
        logger.info('Filter for post date: %s', blog_date)
        post_info_df_filtered = post_info_df_filtered[ (post_info_df_filtered['post_date'] == blog_date) ]

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

    logger = logging.getLogger(__file__)

    # Heuristics
    post_count_threshold = 2
    caption_len_threshold = 25
    caption_huge_threshold = 200
    album_threshold = 12
    album_img_count = 4

    post_info_df['pres_type'] =''
    post_info_df['desc_type'] =''

    # few images --> regular
    if len(post_info_df) <= post_count_threshold:
        post_info_df['pres_type'] = 'regular'

    # single image --> fullscreen
    if len(post_info_df) <= 1: # single post
        post_info_df['pres_type'] = 'fullscreen'

    for index, post in post_info_df.iterrows():
        if len(post['caption']) <= caption_len_threshold:
            post_info_df.loc[index, 'desc_type'] = 'caption'
        else:
            post_info_df.loc[index, 'desc_type'] = 'paragraph'

    if len(post_info_df) <= post_count_threshold:
        return post_info_df

    #
    # post counts > post_count_threshold
    #
    for index, post in post_info_df.iterrows():
        if len(post['caption']) <= caption_huge_threshold:
            post_info_df.loc[index, 'pres_type'] = 'regular'
            post_info_df.loc[index, 'desc_type'] = 'caption'
            logger.debug('Classify [regular / caption] for post: %s', post['shortcode'])
        else:
            post_info_df.loc[index, 'pres_type'] = 'leftright'
            post_info_df.loc[index, 'desc_type'] = 'paragraph'
            logger.debug('Classify [leftright / paragraph] for post: %s', post['shortcode'])

    # many short captions: album with caption
    numOfRows = len(post_info_df[
        (post_info_df['pres_type'] == 'regular') &
        (post_info_df['desc_type'] == 'caption')
    ])

    # decide on albums
    if numOfRows > album_threshold:
        # we define albums
        img_idx = 0
        for index, post in post_info_df.iterrows():
            if (post['pres_type'] == 'regular') and (img_idx % album_img_count == 0):
                post_info_df.loc[index, 'pres_type'] = 'album'
                img_idx = img_idx + 1
                logger.debug('Classify [album / caption] for post: %s', post['shortcode'])

    return post_info_df


def pres_fullscreen(post):
    entry = '<figure class="large" markdown="1">'
    entry = entry + '<p><img src=" '
    entry = entry + post[post_image_url]
    entry = entry + ' alt="" /></p> '

    if post['desc_type'] == 'caption':
        entry = entry + '<figcaption>'
        entry = entry + post['caption']
        entry = entry + '</figcaption>'
    entry = entry + '</figure>'

    if post['desc_type'] == 'paragraph':
        entry = entry + '<p>' + post['caption'] + '</p>'

    return entry


def pres_regular(post):
    entry = '<figure>'
    entry = entry + ' <img src=" '
    entry = entry + post['post_image_url']
    entry = entry + ' " /> '

    if post['desc_type'] == 'caption':
        entry = entry + '<figcaption>'
        entry = entry + post['caption']
        entry = entry + '</figcaption>'
    entry = entry + '</figure>'

    if post['desc_type'] == 'paragraph':
        entry = entry + '<p>' + post['caption'] + '</p>'

    return entry


def pres_leftright(post, lr_idx):
    entry = '<p><img src=" '
    entry = entry + post['post_image_url']

    if lr_idx % 2:
        entry = entry + '#right" alt="" />'
    else:
        entry = entry + '#left" alt="" />'
    pass
    entry = entry + '</p>'
    if post['desc_type'] == 'paragraph':
        entry = entry + '<p>' + post['caption'] + '</p>'

    return entry

def create_post_entries(post_info_df):
    logger = logging.getLogger(__file__)

    if len(post_info_df) < 1:
        logger.warning('No posts found for creating blog post entries.')
        return post_info_df

    # first: sort uploadDate asc
    post_info_df = post_info_df.sort_values(by=['uploadDate'])

    # apply heuristics to indicate for each entry
    # the type of presentation
    post_info_df = classify_posts(post_info_df)
    post_info_df['post_entry'] = ''

    # posts are classified
    # let's render the presentation
    lr_idx = 0
    for index, post in post_info_df.iterrows():
        if post['pres_type'] == 'fullscreen':
            logger.debug('Render [fullscreen] for post: %s', post['shortcode'])
            post_info_df.loc[index, 'post_entry'] = pres_fullscreen(post)

        if post['pres_type'] == 'regular':
            logger.debug('Render [regular] for post: %s', post['shortcode'])
            post_info_df.loc[index, 'post_entry'] = pres_regular(post)

        if post['pres_type'] == 'leftright':
            logger.debug('Render [leftright] for post: %s', post['shortcode'])
            post_info_df.loc[index, 'post_entry'] = pres_leftright(post, lr_idx)
            lr_idx = lr_idx + 1

    return post_info_df

def create_post_frontmatter(post_info_df, blog_date):
    logger = logging.getLogger(__file__)

    if len(post_info_df) < 1:
        logger.warning('No posts found for frontmatter.')
        return ''

    # randomly select an image as cover image
    cover_idx = random.randint(0,len(post_info_df))

    lb = '\n'

    post_frontmatter = '---'
    post_frontmatter += lb
    post_frontmatter += 'layout: post'
    post_frontmatter += lb
    post_frontmatter += 'title: "TEST: Tourblog Post" '
    post_frontmatter += lb
    post_frontmatter += 'menutitle: "TEST: Tourblog Post" '
    post_frontmatter += lb
    post_frontmatter += 'cover: ' + post_info_df.loc[cover_idx, 'post_image_url']
    post_frontmatter += lb
    post_frontmatter += 'category: Tourblog'
    post_frontmatter += lb
    post_frontmatter += 'date: ' + blog_date
    post_frontmatter += lb
    post_frontmatter += 'author: instablog'
    post_frontmatter += lb
    post_frontmatter += 'published: true'
    post_frontmatter += lb
    post_frontmatter += 'comments: false'
    post_frontmatter += lb
    post_frontmatter += 'math: false'
    post_frontmatter += lb
    post_frontmatter += '---'
    post_frontmatter += lb
    post_frontmatter += lb

    return post_frontmatter

def store_blog(blog_file, post_frontmatter, post_entry_df):

    logger = logging.getLogger(__file__)
    if len(post_frontmatter) < 1:
        logger.warning('No posts found. Will not create blog post.')
        return

    logger.info('Write data in file: %s', blog_file)

    lb = '\n'
    try:
        with open(blog_file, 'w') as f:
            # frontmatter
            f.write(post_frontmatter)
            # content
            for index, post in post_entry_df.iterrows():
                f.write(post['post_entry'])
                f.write(lb)
        f.closed
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
@click.option('--no-filter', '-f', required=False, is_flag=True,
                help='Do not filter <post_file> entries by <blog_date>.')
def blogpost(post_file, blog_file, blog_date, no_filter):
    """Creates a blog post file

        \b
        <post_file> Filepath containing all relevant information for each Instagram post.
        <blog_file> Filepath containing the blog post, usually a .md markdown file.
        <blog_date> Blog entry date [YYYY-MM-DD]; only <post_file> entries matching the date will be included.

        You may disable the date filtering using -f switch.
        The blog post file will then contain all <post_file> entries.
    """

    logger = logging.getLogger(__file__)
    logger.info('Start creating blog post')

    blog_date = pd.to_datetime(blog_date).date().strftime('%Y-%m-%d')

    post_info_df = load_post_info(post_file, blog_date, no_filter)
    post_entry_df = create_post_entries(post_info_df)
    post_frontmatter = create_post_frontmatter(post_info_df, blog_date)
    store_blog(blog_file, post_frontmatter, post_entry_df)

    if len(post_frontmatter) < 1:
        logger.info('No blog post created.')
    else:
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
