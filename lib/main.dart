import 'package:cutting_log/src/app.dart';
import 'package:cutting_log/src/data/drift_journal_repository.dart';
import 'package:cutting_log/src/data/local_database.dart';
import 'package:cutting_log/src/domain/journal_overview.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openLocalDatabase();
  final repository = DriftJournalRepository(database);

  runApp(
    CuttingLogApp(
      overview: const JournalOverview(
        parentPlantCount: 0,
        activeCuttingCount: 0,
      ),
      dataRepository: repository,
    ),
  );
}
