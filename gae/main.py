    #!/usr/bin/env python
# coding=utf-8

import webapp2
import progress
import ConfigParser
import tweepy
from mastodon import Mastodon, MastodonAPIError

from google.appengine.ext import ndb
import logging


class LastPercentageModel(ndb.Model):
    percentage = ndb.IntegerProperty(indexed=False, default=0)

SINGLE_KEY_NAME = "PERCENTAGE_SINGLE_KEY"
MASTODON_SINGLE_KEY_NAME = "MASTODON_PERCENTAGE_SINGLE_KEY"


def tweet(message):
    config = ConfigParser.RawConfigParser()
    config.read('settings.cfg')

    # http://dev.twitter.com/apps/myappid
    CONSUMER_KEY = config.get('Twitter OAuth', 'CONSUMER_KEY')
    CONSUMER_SECRET = config.get('Twitter OAuth', 'CONSUMER_SECRET')
    # http://dev.twitter.com/apps/myappid/my_token
    ACCESS_TOKEN_KEY = config.get('Twitter OAuth', 'ACCESS_TOKEN_KEY')
    ACCESS_TOKEN_SECRET = config.get('Twitter OAuth', 'ACCESS_TOKEN_SECRET')

    auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
    auth.set_access_token(ACCESS_TOKEN_KEY, ACCESS_TOKEN_SECRET)
    api = tweepy.API(auth)
    result = api.update_status(status=message)
    return result

def toot(message):
    mastodon = Mastodon(
        access_token = 'pytooter_usercred.secret',
        api_base_url = 'https://techhub.social'
    )
    mastodon.toot(message)


class TweetHandler(webapp2.RequestHandler):
    def get(self):
        progress_ratio = progress.compute_current_year_progress()

        ratio_int = int(progress_ratio * 100)
        save = LastPercentageModel.get_or_insert(SINGLE_KEY_NAME)
        if save.percentage != ratio_int:
            if ratio_int == 0:
                # New Year's Eve: tweet 100% first
                self._tweet_percentage(1.0, 100, save)
            self._tweet_percentage(progress_ratio, ratio_int, save)
        else:
            logging.info("Old percentage hasn't changed: {}".format(ratio_int))

    @staticmethod
    def _tweet_percentage(progress_ratio, ratio_int, save):
        status = "{} {}%".format(
            progress.create_progress_string(progress_ratio, width=15),
            ratio_int
        )
        logging.info("Tweeting: {}".format(status))
        try:
            result = tweet(status)
            logging.info("Tweeted!\n{}".format(result))
            save.percentage = ratio_int
            save.put()
            logging.info("New percentage put: {}".format(ratio_int))
        except Exception as e:
            logging.error(e)


class TootHandler(webapp2.RequestHandler):
    def get(self):
        progress_ratio = progress.compute_current_year_progress()

        ratio_int = int(progress_ratio * 100)
        save = LastPercentageModel.get_or_insert(MASTODON_SINGLE_KEY_NAME)
        if save.percentage != ratio_int:
            if ratio_int == 0:
                # New Year's Eve: tweet 100% first
                self._toot_percentage(1.0, 100, save)
            self._toot_percentage(progress_ratio, ratio_int, save)
        else:
            logging.info("Old percentage hasn't changed: {}".format(ratio_int))

    @staticmethod
    def _toot_percentage(progress_ratio, ratio_int, save):
        status = "{} {}%".format(
            progress.create_progress_string(progress_ratio, width=15),
            ratio_int
        )
        logging.info("Tooting: {}".format(status))
        try:
            toot(status)
        except MastodonAPIError as e:
            if 'response code was 200, bad json content was' in str(e):
                # We are ignoring this because the toot was published.
                logging.info(e)
            else:
                logging.error(e)
                raise
        logging.info("Tooted!")
        save.percentage = ratio_int
        save.put()
        logging.info("New percentage put: {}".format(ratio_int))


# XXX: Currently unused
class MainHandler(webapp2.RequestHandler):
    def get(self):
        progress_ratio = progress.compute_current_year_progress()

        self.response.write("{} │ {:.8%}".format(
            progress.create_progress_string(progress_ratio),
            progress_ratio))


app = webapp2.WSGIApplication([
    ('/', MainHandler),
    ('/admin/tweet', TweetHandler),
    ('/admin/toot', TootHandler)
], debug=True)