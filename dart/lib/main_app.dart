// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:polymer/polymer.dart';
import 'dart:async';
import 'dart:html';

/// A Polymer `<main-app>` element.
@CustomTag('main-app')
class MainApp extends PolymerElement {

  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created();

  @observable
  num year = 0;
  @observable
  num month = 0;
  @observable
  num quarter = 0;

  @observable
  String daytimeName = "";
  @observable
  num daytime = 50;
  @observable
  bool daytimeInvalid = true;

  static const String WORKDAY = "Workday";
  static const String EVENING = "Evening";
  static const String NIGHT = "Night";
  static const String MORNING = "Morning";

  final startOfMorningHour = 7;
  final startOfDayHour = 9;
  final endOfDayHour = 18;
  final endOfEveningHour = 23;

  void recalculate() {
    var now = new DateTime.now();
    final DateTime startOfYear = new DateTime(now.year, 1, 1);
    final DateTime endOfYear = new DateTime(now.year + 1, 1, 1);
    year = ((now.difference(startOfYear)).inMinutes /
        (endOfYear.difference(startOfYear).inMinutes) * 100);

    final DateTime startOfMonth = new DateTime(now.year, now.month, 1);
    final DateTime endOfMonth = new DateTime(now.year, now.month + 1, 1);
    month = ((now.difference(startOfMonth)).inMinutes /
        (endOfMonth.difference(startOfMonth).inMinutes) * 100);

    final DateTime startOfQuarter =
        new DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
    final DateTime endOfQuarter =
        new DateTime(now.year, ((now.month - 1) ~/ 3 + 1) * 3 + 1, 1);
    quarter = ((now.difference(startOfQuarter)).inMinutes /
            (endOfQuarter.difference(startOfQuarter).inMinutes) * 100);

    final DateTime startOfMorning =
        new DateTime(now.year, now.month, now.day, startOfMorningHour);
    final DateTime startOfNextMorning =
        startOfMorning.add(const Duration(days: 1));
    final DateTime startOfWorkday =
        new DateTime(now.year, now.month, now.day, startOfDayHour);
    final DateTime endOfWorkday =
        new DateTime(now.year, now.month, now.day, endOfDayHour);
    final DateTime endOfEvening =
        new DateTime(now.year, now.month, now.day, endOfEveningHour);
    final DateTime endOfPreviousEvening =
        endOfEvening.subtract(const Duration(days: 1));

    _daytimeCalculate(now, endOfPreviousEvening, startOfMorning, NIGHT);
    _daytimeCalculate(now, startOfMorning, startOfWorkday, MORNING);
    _daytimeCalculate(now, startOfWorkday, endOfWorkday, WORKDAY);
    _daytimeCalculate(now, endOfWorkday, endOfEvening, EVENING);
    _daytimeCalculate(now, endOfEvening, startOfNextMorning, NIGHT);

    final DateTime nextRecalculate = new DateTime(now.year, now.month, now.day,
        now.hour, now.minute + 1);
    new Timer(nextRecalculate.difference(now), () => recalculate());
  }

  bool _daytimeCalculate(DateTime now, DateTime start, DateTime end,
                         String name) {
    if (now.compareTo(start) >= 0 &&
        now.compareTo(end) < 0) {
      daytimeInvalid = false;
      daytime = ((now.difference(start).inMinutes /
                  end.difference(start).inMinutes) * 100);
      daytimeName = name;
      return true;
    } else {
      return false;
    }
  }

  /// Called when main-app has been fully prepared (Shadow DOM created,
  /// property observers set up, event listeners attached).
  ready() {
    super.ready();
    recalculate();
    // window.onResize.listen((_) => _updateBackgroundImage());
    _updateBackgroundImage();
  }

  void _updateBackgroundImage() {
    int innerHeight = (window.innerHeight * window.devicePixelRatio).round();
    String suffix;
    if (innerHeight >= 2010) suffix = "@1x";
    else if (innerHeight >= 1005) suffix = "@0.5x";
    else if (innerHeight >= 603) suffix = "@0.3x";
    else suffix = "@0.2x";
    document.body.style.backgroundImage =
        "url(images/Balaton_Hungary_Landscape$suffix.jpg)";
  }
}
