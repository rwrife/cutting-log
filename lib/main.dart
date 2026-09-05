import 'dart:io';

import 'package:cutting_log/src/app.dart';
import 'package:cutting_log/src/application/media_workflow.dart';
import 'package:cutting_log/src/application/reminder_workflow.dart';
import 'package:cutting_log/src/data/app_private_media_store.dart';
import 'package:cutting_log/src/data/drift_journal_repository.dart';
import 'package:cutting_log/src/data/local_database.dart';
import 'package:cutting_log/src/domain/journal_overview.dart';
import 'package:cutting_log/src/platform/flutter_local_notification_gateway.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:cutting_log/src/platform/optional_permission_gateway.dart';
import 'package:cutting_log/src/platform/permission_handler_optional_permission_gateway.dart';
import 'package:cutting_log/src/platform/photo_import_gateway.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

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

  OptionalPermissionGateway permissions =
      const PermissionHandlerOptionalPermissionGateway();
  PhotoImportGateway photoImports = ImagePickerPhotoImportGateway();
  Directory mediaRoot;
  try {
    // Ensure platform channels are available before enabling import actions.
    mediaRoot = await getApplicationSupportDirectory();
  } on Object {
    permissions = const DisabledOptionalPermissionGateway();
    photoImports = const DisabledPhotoImportGateway();
    mediaRoot = await Directory.systemTemp.createTemp('cutting-log-media-');
  }

  final mediaWorkflow = MediaWorkflow(
    repository: repository,
    permissions: permissions,
    sourceGateway: photoImports,
    mediaStore: AppPrivateMediaStore(mediaRoot),
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
    ),
  );
}
