double computeProgress(DateTime start, DateTime end, DateTime current) {
  if (start.isAtSameMomentAs(end)) {
    throw ArgumentError("Start and end datetimes are equal.");
  }
  final wholeDiff = end.difference(start).inSeconds;
  final currentDiff = current.difference(start).inSeconds;
  return currentDiff / wholeDiff;
}

double computeCurrentYearProgress([DateTime? current]) {
  final now = (current ?? DateTime.now()).toUtc();
  final start = DateTime.utc(now.year, 1, 1);
  final end = DateTime.utc(now.year + 1, 1, 1);
  return computeProgress(start, end, now);
}

String createProgressString(double progress, {int width = 20}) {
  final progressInt = (progress * width).round();
  final restInt = width - progressInt;
  return '${'▓' * progressInt}${'░' * restInt}';
}
