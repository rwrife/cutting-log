import 'package:cutting_log/src/app.dart';
import 'package:cutting_log/src/data/in_memory_journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders an accessible offline journal shell at large text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: const CuttingLogApp(
          overview: JournalOverview(parentPlantCount: 0, activeCuttingCount: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cutting Log'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Private journal ready')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('Parent plants: 0')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Active cuttings: 0')), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Offline and account-free'), 200);
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp('Offline and account-free: Ready')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('captures a parent, cutting, observation, and outcome', (
    tester,
  ) async {
    final repository = InMemoryJournalDataRepository();
    await tester.pumpWidget(
      CuttingLogApp(
        overview: const JournalOverview(
          parentPlantCount: 0,
          activeCuttingCount: 0,
        ),
        dataRepository: repository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Parent plant nickname'),
      'Test parent',
    );
    await _tapVisible(tester, find.byKey(const ValueKey('create-parent')));
    await tester.pumpAndSettle();
    expect(find.text('Cuttings for Test parent'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Unique cutting name'),
      'Node A',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Medium (optional)'),
      'Water',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Location text (optional)'),
      'Kitchen window',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Tags, comma separated (optional)'),
      'window, trial',
    );
    await _tapVisible(tester, find.byKey(const ValueKey('start-cutting')));
    await tester.pumpAndSettle();
    expect(find.text('Node A timeline'), findsOneWidget);
    expect(find.textContaining('Stage: Started'), findsWidgets);

    await tester.enterText(
      find.widgetWithText(TextField, 'New observation'),
      'User-recorded change',
    );
    await _tapVisible(tester, find.byKey(const ValueKey('add-observation')));
    await tester.pumpAndSettle();
    expect(find.textContaining('User-recorded change'), findsOneWidget);

    await _tapVisible(tester, find.byTooltip('Correct observation'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Replacement note'),
      'Cancelled wording',
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Cancelled wording'), findsNothing);

    final parents = await repository.getParentPlants();
    final cuttings = await repository.getCuttings(parentId: parents.single.id);
    final events = await repository.getCuttingEvents(cuttings.single.id);
    expect(parents.single.nickname, 'Test parent');
    expect(cuttings.single.tags, <String>['trial', 'window']);
    expect(events, hasLength(2));
  });

  testWidgets('invalid input preserves entered data and creates no record', (
    tester,
  ) async {
    final repository = InMemoryJournalDataRepository();
    await tester.pumpWidget(
      CuttingLogApp(
        overview: const JournalOverview(
          parentPlantCount: 0,
          activeCuttingCount: 0,
        ),
        dataRepository: repository,
      ),
    );
    await tester.pumpAndSettle();

    final parentField = find.widgetWithText(TextField, 'Parent plant nickname');
    final invalidName = List<String>.filled(81, 'x').join();
    await tester.enterText(parentField, invalidName);
    await _tapVisible(tester, find.byKey(const ValueKey('create-parent')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Parent nickname'), findsOneWidget);
    expect(tester.widget<TextField>(parentField).controller?.text, invalidName);
    expect(await repository.getParentPlants(), isEmpty);
  });
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).at(0),
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
}
