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

#
# Source: https://gist.github.com/douglasmiranda/5127251#gistcomment-2398949
#
def find_json(key, dictionary):
    """Returns the value for a key in in a (nested) iterable.

       Arguments:
           - key: a dictionary's entry
           - dictionary: <list> or <dictionary>
           - returned: <string> "value"

       Returns:
           - <iterator>
    """
    for k, v in dictionary.items():
        if k == key:
            yield v
        elif isinstance(v, dict):
            for result in find_json(key, v):
                yield result
        elif isinstance(v, list):
            for d in v:
                if isinstance(d, dict):
                    for result in find_json(key, d):
                        yield result


def download_profile(profile_url):
    # we download the profile's website
    logger = logging.getLogger(__file__)
    logger.info('Downloading: %s', profile_url)

    insta_profile = requests.get(profile_url, allow_redirects=True)

    # error check
    if insta_profile.status_code != 200:
        logger.error('Unexpected error code while downloading: %d', insta_profile.status_code)
        sys.exit(1)

    return insta_profile

def parse_profile(insta_profile):

    logger = logging.getLogger(__file__)
    logger.info('Parsing profile data')

    if len(insta_profile.text) < 1:
        logger.warn('No data in profile')

    # Let's parse the website
    soup = BeautifulSoup(insta_profile.text, 'lxml')

    json_data_str = ''
    # iterate through all scripts and find the
    # first occurence of the script containing the data
    for script in soup.find_all('script'):
        script_str = script.string
        if script_str.startswith('window._sharedData = '):
            json_data_str = script_str
            break

    # clean data
    json_data_str = json_data_str.strip('window._sharedData = ')
    json_data_str = json_data_str.strip(';')

    # decode string and receive json object
    json_data = json.loads(json_data_str.replace("\n","\\n"))
    # these are the shortcodes
    insta_posts_shortcodes = list(find_json('shortcode', json_data))

    if len(insta_posts_shortcodes) < 1:
        logger.warn('No shortcodes found')

    return insta_posts_shortcodes

def store_codes(code_file, insta_posts_shortcodes):

    logger = logging.getLogger(__file__)
    logger.info('Write data in file: %s', code_file)

    with open(code_file, 'w', newline='') as csvfile:
        fieldnames = ['shortcode']
        writer = csv.DictWriter(csvfile,
                            fieldnames=fieldnames,
                            delimiter=';',
                            quotechar='|',
                            quoting=csv.QUOTE_MINIMAL)
        try:
            writer.writeheader()
            for code in insta_posts_shortcodes:
                writer.writerow({'shortcode': code})
        except:
            # log error handling
            logger.error('Error writing file : %s', code_file)
            sys.exit(1)


#############################################
# Main
#############################################
@click.command()
@click.argument('code_file',
                type=click.Path(exists=False, dir_okay=False, writable=True) )
@click.argument('profile_url')
def instacrawler(code_file, profile_url):
    """
        code_file Filepath storing the codes of all profile\'s posts
        profile_url Instagram profile URL
    """

    logger = logging.getLogger(__file__)
    logger.info('Start crawling Instagram profile: %s', profile_url)

    insta_profile = download_profile(profile_url)
    insta_posts_shortcodes = parse_profile(insta_profile)
    store_codes(code_file, insta_posts_shortcodes)

    logger.info('Crawling Instagram profile done.')
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
    instacrawler()
