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


def load_shortcodes(code_file):
    logger = logging.getLogger(__file__)
    logger.info('Load shortcodes from file: %s', code_file)

    insta_posts_shortcodes = []

    with open(code_file, 'r', newline='') as csvfile:
        # values in the first row of file f will be used as the fieldnames
        reader = csv.DictReader(csvfile,
                            delimiter=';',
                            quotechar='|')
        try:
            for row in reader:
                #print(row['shortcode'])
                insta_posts_shortcodes.append(row['shortcode'])

        except:
            # log error handling
            logger.error('Error reading file : %s', code_file)
            sys.exit(1)

    logger.info('Loaded shortcodes: %d', len(insta_posts_shortcodes))
    return insta_posts_shortcodes

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

        try:
            post_info.append( post_json["caption"] )
        except KeyError:
            logger.warning('No caption in instagram post. Add empty one.')
            post_info.append( "" ) # empty caption

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
        logger.error('Error writing file : %s', post_file)
        sys.exit(1)


#############################################
# Main
#############################################
@click.command()
@click.argument('code_file',
                type=click.Path(exists=True, dir_okay=False) )
@click.argument('post_file',
                type=click.Path(exists=False, dir_okay=False, writable=True) )
def instapost(code_file, post_file):
    """
        code_file Filepath storing the codes of all profile\'s posts
        post_file Filepath containing all relevant information for each Instagram post
    """

    logger = logging.getLogger(__file__)
    logger.info('Start downloading Instagram posts')

    insta_posts_shortcodes = load_shortcodes(code_file)
    post_info_df = download_posts(insta_posts_shortcodes)
    store_posts(post_file, post_info_df)

    logger.info('Downloading Instagram posts done.')
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
    instapost()
