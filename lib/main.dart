import 'package:cutting_log/src/app.dart';
import 'package:cutting_log/src/application/load_journal_overview.dart';
import 'package:cutting_log/src/data/in_memory_journal_repository.dart';
import 'package:flutter/widgets.dart';

void main() {
  const repository = InMemoryJournalRepository();
  const loadOverview = LoadJournalOverview(repository);

  runApp(CuttingLogApp(overview: loadOverview()));
}
