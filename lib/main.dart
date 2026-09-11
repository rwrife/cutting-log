import 'dart:io';

import 'package:cutting_log/src/app.dart';
import 'package:cutting_log/src/application/media_workflow.dart';
import 'package:cutting_log/src/application/portability_workflow.dart';
import 'package:cutting_log/src/application/reminder_workflow.dart';
import 'package:cutting_log/src/data/app_private_media_store.dart';
import 'package:cutting_log/src/data/drift_journal_repository.dart';
import 'package:cutting_log/src/data/local_database.dart';
import 'package:cutting_log/src/domain/journal_overview.dart';
import 'package:cutting_log/src/platform/flutter_local_notification_gateway.dart';
import 'package:cutting_log/src/platform/journey_configuration.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:cutting_log/src/platform/optional_permission_gateway.dart';
import 'package:cutting_log/src/platform/permission_handler_optional_permission_gateway.dart';
import 'package:cutting_log/src/platform/photo_import_gateway.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openLocalDatabase();
  final repository = DriftJournalRepository(database);

  LocalNotificationGateway notifications = FlutterLocalNotificationGateway();
  try {
    // Bounded, not just error-guarded: plugin init or reconciliation that
    // never answers (observed on a CI iOS simulator, which hung startup for
    // 40 minutes with a blank screen) must also fall back to the disabled
    // gateway instead of blocking the journal forever.
    await notifications.initialize().timeout(const Duration(seconds: 15));
    await ReminderWorkflow(
      repository,
      notifications,
    ).reconcile().timeout(const Duration(seconds: 15));
  } on Object {
    // Optional notification setup must never prevent access to the journal.
    notifications = const DisabledLocalNotificationGateway();
  }

  OptionalPermissionGateway permissions =
      const PermissionHandlerOptionalPermissionGateway();
  PhotoImportGateway photoImports = ImagePickerPhotoImportGateway();
  if (JourneyConfiguration.isIntegrationTest) {
    // Automated device journey: swap only the two capability entry points
    // that would otherwise open native UI an instrumented test cannot
    // answer. Persistence, media storage, and portability stay real.
    if (notifications is! DisabledLocalNotificationGateway) {
      notifications = JourneyDeferredNotificationGateway(notifications);
    }
    permissions = const JourneyAutoGrantPermissionGateway();
    photoImports = const JourneySyntheticPhotoGateway();
  }
  Directory cacheRoot;
  Directory mediaRoot;
  try {
    // Ensure platform channels are available before enabling import actions.
    mediaRoot = await getApplicationSupportDirectory();
    cacheRoot = await getTemporaryDirectory();
  } on Object {
    permissions = const DisabledOptionalPermissionGateway();
    photoImports = const DisabledPhotoImportGateway();
    mediaRoot = await Directory.systemTemp.createTemp('cutting-log-media-');
    cacheRoot = await Directory.systemTemp.createTemp('cutting-log-cache-');
  }

  final mediaStore = AppPrivateMediaStore(mediaRoot);
  final mediaWorkflow = MediaWorkflow(
    repository,
    permissions,
    photoImports,
    mediaStore,
  );
  final portabilityWorkflow = PortabilityWorkflow(
    database,
    repository,
    mediaStore,
    notifications,
    exportDirectory: Directory(path.join(mediaRoot.path, 'exports')),
    cacheDirectory: cacheRoot,
  );

  runApp(
    CuttingLogApp(
      overview: const JournalOverview(
        parentPlantCount: 0,
        activeCuttingCount: 0,
      ),
      dataRepository: repository,
      notificationGateway: notifications,
      mediaWorkflow: mediaWorkflow,
      portabilityWorkflow: portabilityWorkflow,
    ),
  );
}
