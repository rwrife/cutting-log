import 'dart:io';

import 'package:cutting_log/src/data/app_database.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Opens the journal in the app-private application-support directory.
///
/// No shared storage or network service is involved. Tests continue to inject
/// temporary or in-memory executors directly into [AppDatabase].
Future<AppDatabase> openLocalDatabase() async {
  final supportDirectory = await getApplicationSupportDirectory();
  await supportDirectory.create(recursive: true);
  final file = File(path.join(supportDirectory.path, 'cutting-log.sqlite'));
  return AppDatabase(NativeDatabase.createInBackground(file));
}
