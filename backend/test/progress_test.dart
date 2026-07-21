import 'package:test/test.dart';
import 'package:backend/progress.dart';

void main() {
  group('Progress', () {
    late DateTime january1;
    late DateTime january1Dupl;
    late DateTime january2;
    late DateTime january10;
    late DateTime july4;
    late DateTime december30;
    late DateTime endyear;

    setUp(() {
      january1 = DateTime.utc(2015, 1, 1);
      january1Dupl = DateTime.utc(2015, 1, 1);
      january2 = DateTime.utc(2015, 1, 2);
      january10 = DateTime.utc(2015, 1, 10);
      july4 = DateTime.utc(2015, 7, 4);
      december30 = DateTime.utc(2015, 12, 30);
      endyear = DateTime.utc(2016, 1, 1);
    });

    test('computeProgress', () {
      expect(
        computeProgress(january1, endyear, january1Dupl),
        closeTo(0.0, 1e-4),
      );
      expect(
        computeProgress(january1, endyear, january2),
        closeTo(0.0027, 1e-4),
      );
      expect(
        computeProgress(january1, endyear, january10),
        closeTo(0.0247, 1e-4),
      );
      expect(computeProgress(january1, endyear, july4), closeTo(0.5041, 1e-4));
      expect(
        computeProgress(january1, endyear, december30),
        closeTo(0.9945, 1e-4),
      );
      expect(computeProgress(january1, endyear, endyear), closeTo(1.0, 1e-4));

      expect(
        () => computeProgress(january1, january1, january10),
        throwsArgumentError,
      );
    });

    test('computeCurrentYearProgress', () {
      expect(computeCurrentYearProgress(january1), closeTo(0.0, 1e-4));
      expect(computeCurrentYearProgress(january10), closeTo(0.0247, 1e-4));
      expect(computeCurrentYearProgress(july4), closeTo(0.5041, 1e-4));
      // End of year input (which is january 1 of next year) should give 0.0 of that next year
      expect(computeCurrentYearProgress(endyear), closeTo(0.0, 1e-4));

      final progressNow = computeCurrentYearProgress();
      expect(progressNow, greaterThanOrEqualTo(0.0));
      expect(progressNow, lessThanOrEqualTo(1.0));
    });

    test('createProgressString', () {
      expect(createProgressString(0.0), "░░░░░░░░░░░░░░░░░░░░");
      expect(createProgressString(0.5), "▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░");
      expect(createProgressString(0.49), "▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░");
      expect(createProgressString(1.0), "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓");
      expect(createProgressString(0.03, width: 15), "░░░░░░░░░░░░░░░");
      expect(createProgressString(1.0, width: 15), "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓");
      expect(createProgressString(0.97, width: 15), "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓");
    });
  });
}
