#!/usr/bin/env python
# coding=utf-8
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
import progress
import ConfigParser
import tweepy

from google.appengine.ext import ndb
import logging

class LastPercentageModel(ndb.Model):
    percentage = ndb.IntegerProperty(indexed=False, default=0)

SINGLE_KEY_NAME = "PERCENTAGE_SINGLE_KEY"


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


class MainHandler(webapp2.RequestHandler):
    def get(self):
        progress_ratio = progress.compute_current_year_progress()

        self.response.write("{} │ {:.8%}".format(
            progress.create_progress_string(progress_ratio),
            progress_ratio))


class TweetHandler(webapp2.RequestHandler):
    def get(self):
        progress_ratio = progress.compute_current_year_progress()

        ratio_int = int(progress_ratio * 100)
        save = LastPercentageModel.get_or_insert(SINGLE_KEY_NAME)
        if save.percentage != ratio_int:
            status = "{} │ {}%".format(
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
        else:
            logging.info("Old percentage hasn't changed: {}".format(ratio_int))



app = webapp2.WSGIApplication([
    ('/', MainHandler),
    ('/admin/tweet', TweetHandler)
], debug=True)
