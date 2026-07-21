import 'dart:io';
import 'package:args/args.dart';
import 'package:mastodon_client/mastodon_client.dart';
import 'package:backend/progress.dart';
import 'package:backend/state_store.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'db-path',
      defaultsTo:
          Platform.environment['DATABASE_PATH'] ?? '/app/data/database.db',
      help: 'Path to SQLite database file',
    )
    ..addOption(
      'base-url',
      defaultsTo:
          Platform.environment['MASTODON_BASE_URL'] ?? 'https://techhub.social',
      help: 'Mastodon base URL',
    )
    ..addOption(
      'access-token',
      defaultsTo: Platform.environment['MASTODON_ACCESS_TOKEN'],
      help: 'Mastodon access token',
    )
    ..addOption(
      'current-time',
      help: 'Override current time in ISO 8601 format (UTC)',
    )
    ..addFlag(
      'dry-run',
      negatable: false,
      help:
          'Calculate progress, check state, and print what would be posted without posting',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print help message');

  ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (e) {
    stderr.writeln('Error parsing arguments: $e');
    exit(64); // ExitCode.usage.code
  }

  if (results['help'] as bool) {
    print('Usage: toot [options]');
    print(parser.usage);
    return;
  }

  final dbPath = results['db-path'] as String;
  final baseUrl = results['base-url'] as String;
  final accessToken = results['access-token'] as String?;
  final dryRun = results['dry-run'] as bool;

  DateTime now = DateTime.now().toUtc();
  final currentTimeStr = results['current-time'] as String?;
  if (currentTimeStr != null) {
    now = DateTime.parse(currentTimeStr).toUtc();
  }

  // Ensure DB parent directory exists
  final dbFile = File(dbPath);
  if (!dbFile.parent.existsSync()) {
    dbFile.parent.createSync(recursive: true);
  }

  // Calculate year progress
  final progressRatio = computeCurrentYearProgress(now);
  final ratioInt = (progressRatio * 100).toInt();

  print('Current simulated/actual time (UTC): $now');
  print('Progress ratio: $progressRatio ($ratioInt%)');

  // Load the state
  final store = StateStore(dbPath);
  final stateKey = 'MASTODON_PERCENTAGE_SINGLE_KEY';
  final lastPercentage = store.getLastPercentage(stateKey);

  print('Last posted percentage from database: $lastPercentage');

  if (lastPercentage == ratioInt) {
    print("Old percentage hasn't changed: $ratioInt%. Nothing to do.");
    store.close();
    return;
  }

  // Helper function to post the progress status
  Future<void> postProgress(double ratio, int percentage) async {
    final progressString = createProgressString(ratio, width: 15);
    final statusMessage = '$progressString $percentage%';

    print('Preparing to toot: "$statusMessage"');

    if (dryRun) {
      print('[DRY RUN] Would toot: "$statusMessage"');
      return;
    }

    if (accessToken == null || accessToken.isEmpty) {
      throw StateError(
        'MASTODON_ACCESS_TOKEN is missing or empty. Cannot post.',
      );
    }

    final client = MastodonClient(baseUrl: baseUrl, accessToken: accessToken);

    try {
      final request = MastodonStatusCreateRequest(status: statusMessage);
      final result = await client.statuses.create(request);
      if (result is MastodonStatusCreated) {
        print('Successfully tooted! ID: ${result.status.id}');
      } else if (result is MastodonStatusScheduled) {
        print('Toot scheduled for: ${result.scheduledStatus.scheduledAt}');
      }
    } catch (e) {
      stderr.writeln('Failed to post to Mastodon: $e');
      rethrow;
    }
  }

  try {
    if (ratioInt == 0) {
      // New Year's Eve: post 100% first
      print('New Year detected! Dual-posting: 100% first, then 0%.');
      await postProgress(1.0, 100);
    }

    await postProgress(progressRatio, ratioInt);

    // Save the new state
    if (!dryRun) {
      store.setLastPercentage(stateKey, ratioInt);
      print('Saved new percentage to DB: $ratioInt%');
    } else {
      print('[DRY RUN] Would save percentage to DB: $ratioInt%');
    }
  } finally {
    store.close();
  }
}
