import 'package:cutting_log/src/app.dart';
import 'package:cutting_log/src/application/reminder_workflow.dart';
import 'package:cutting_log/src/data/drift_journal_repository.dart';
import 'package:cutting_log/src/data/local_database.dart';
import 'package:cutting_log/src/domain/journal_overview.dart';
import 'package:cutting_log/src/platform/flutter_local_notification_gateway.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openLocalDatabase();
  final repository = DriftJournalRepository(database);
  LocalNotificationGateway notifications = FlutterLocalNotificationGateway();
  try {
    await notifications.initialize();
    await ReminderWorkflow(repository, notifications).reconcile();
  } on Object {
    // Optional notification setup must never prevent access to the journal.
    notifications = const DisabledLocalNotificationGateway();
  }

  runApp(
    CuttingLogApp(
      overview: const JournalOverview(
        parentPlantCount: 0,
        activeCuttingCount: 0,
      ),
      dataRepository: repository,
      notificationGateway: notifications,
    ),
  );
}
