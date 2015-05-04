#!/usr/bin/env python
# coding=utf-8

from unittest import TestCase

__author__ = 'filiph'

from datetime import datetime
from progress import compute_progress, compute_current_year_progress, \
    create_progress_string, UTC

class TestProgress(TestCase):

    def setUp(self):
        self.january1 = datetime(2015, 1, 1, tzinfo=UTC())
        self.january1_dupl = datetime(2015, 1, 1, tzinfo=UTC())
        self.january2 = datetime(2015, 1, 2, tzinfo=UTC())
        self.january10 = datetime(2015, 1, 10, tzinfo=UTC())
        self.july4 = datetime(2015, 7, 4, tzinfo=UTC())
        self.december30 = datetime(2015, 12, 30, tzinfo=UTC())
        self.endyear = datetime(2016, 1, 1, tzinfo=UTC())

    def test_compute_progress(self):
        self.assertAlmostEqual(compute_progress(self.january1, self.endyear,
                                                self.january1_dupl),
                               0.0, places=4)
        self.assertAlmostEqual(compute_progress(self.january1, self.endyear,
                                                self.january2),
                               0.0027, places=4)
        self.assertAlmostEqual(compute_progress(self.january1, self.endyear,
                                                self.january10),
                               0.0247, places=4)
        self.assertAlmostEqual(compute_progress(self.january1, self.endyear,
                                                self.july4),
                               0.5041, places=4)
        self.assertAlmostEqual(compute_progress(self.january1, self.endyear,
                                                self.december30),
                               0.9945, places=4)
        self.assertAlmostEqual(compute_progress(self.january1, self.endyear,
                                                self.endyear),
                               1.0, places=4)

        def raise_test():
            compute_progress(self.january1, self.january1,
                             self.january10)

        self.assertRaises(ValueError, raise_test)

    def test_compute_current_year_progress(self):
        self.assertAlmostEqual(compute_current_year_progress(self.january1),
                               0.0, places=4)
        self.assertAlmostEqual(compute_current_year_progress(self.january10),
                               0.0247, places=4)
        self.assertAlmostEqual(compute_current_year_progress(self.july4),
                               0.5041, places=4)
        self.assertAlmostEqual(compute_current_year_progress(self.endyear),
                               0.0, places=4)

        self.assertTrue(0.0 <= compute_current_year_progress() <= 1.0)

    def test_create_progress_string(self):
        self.assertEqual(create_progress_string(0.0),
                         "░░░░░░░░░░░░░░░░░░░░")
        self.assertEqual(create_progress_string(0.5),
                         "▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░")
        self.assertEqual(create_progress_string(0.49),
                         "▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░")
        self.assertEqual(create_progress_string(1.0),
                         "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓")
        self.assertEqual(create_progress_string(0.03, width=15),
                         "░░░░░░░░░░░░░░░")
        self.assertEqual(create_progress_string(1.0, width=15),
                         "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓")
        self.assertEqual(create_progress_string(0.97, width=15),
                         "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓")