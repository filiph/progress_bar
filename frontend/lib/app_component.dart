import 'dart:async';

import 'dart:html';
import 'package:angular/angular.dart';
import 'package:frontend/src/time_progress/time_progress.dart';

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [TimeProgressComponent],
  providers: const [],
)
class AppComponent implements OnInit {
  static const int startOfMorningHour = 7;

  static const int startOfDayHour = 9;

  static const int endOfDayHour = 18;

  static const int endOfEveningHour = 23;

  static const String WORKDAY = "Workday";

  static const String EVENING = "Evening";

  static const String NIGHT = "Night";

  static const String MORNING = "Morning";

  double year = 0.0;

  double month = 0.0;

  double quarter = 0.0;

  String daytimeName = "";

  double daytime = 0.0;

  bool daytimeInvalid = true;

  void recalculate() {
    var now = new DateTime.now();
    final DateTime startOfYear = new DateTime(now.year, 1, 1);
    final DateTime endOfYear = new DateTime(now.year + 1, 1, 1);
    year = ((now.difference(startOfYear)).inMinutes /
        (endOfYear.difference(startOfYear).inMinutes) *
        100);

    final DateTime startOfMonth = new DateTime(now.year, now.month, 1);
    final DateTime endOfMonth = new DateTime(now.year, now.month + 1, 1);
    month = ((now.difference(startOfMonth)).inMinutes /
        (endOfMonth.difference(startOfMonth).inMinutes) *
        100);

    final DateTime startOfQuarter =
        new DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
    final DateTime endOfQuarter =
        new DateTime(now.year, ((now.month - 1) ~/ 3 + 1) * 3 + 1, 1);
    quarter = ((now.difference(startOfQuarter)).inMinutes /
        (endOfQuarter.difference(startOfQuarter).inMinutes) *
        100);

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

    final DateTime nextRecalculate =
        new DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    new Timer(nextRecalculate.difference(now), () => recalculate());
  }

  bool _daytimeCalculate(
      DateTime now, DateTime start, DateTime end, String name) {
    if (now.compareTo(start) >= 0 && now.compareTo(end) < 0) {
      daytimeInvalid = false;
      daytime =
          ((now.difference(start).inMinutes / end.difference(start).inMinutes) *
              100);
      daytimeName = name;
      return true;
    } else {
      return false;
    }
  }

  @override
  ngOnInit() {
    window.onFocus.listen((_) => recalculate());
    new Timer(const Duration(), () {
      // Putting this in a timer makes it animate from 0 on page load.
      recalculate();
    });
  }
}
