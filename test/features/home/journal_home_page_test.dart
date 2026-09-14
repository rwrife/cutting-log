import 'package:cutting_log/src/app.dart';
import 'package:cutting_log/src/data/in_memory_journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
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
    // The explainer card occupies the first viewport at 2x text, so the
    // overview tiles now need one scroll step.
    await tester.scrollUntilVisible(
      find.bySemanticsLabel(RegExp('Parent plants: 0')),
      200,
    );
    await tester.pumpAndSettle();
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
      find.widgetWithText(TextField, 'Cutting name (optional)'),
      'Node A',
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

  testWidgets('review and due state remain readable without motion or color', (
    tester,
  ) async {
    final repository = InMemoryJournalDataRepository();
    final now = DateTime.now().toUtc();
    final parent = ParentPlant(
      id: EntityId('review-parent'),
      nickname: 'Review parent',
      createdAtUtc: now.subtract(const Duration(days: 2)),
      updatedAtUtc: now,
    );
    final cutting = Cutting(
      id: EntityId('review-cutting'),
      parentId: parent.id,
      name: 'Review cutting',
      method: 'stem',
      tags: const <String>['window'],
      startedAtUtc: now.subtract(const Duration(days: 2)),
      createdAtUtc: now.subtract(const Duration(days: 2)),
      updatedAtUtc: now,
    );
    await repository.createParentPlant(parent);
    await repository.createCutting(cutting);
    await repository.createReminder(
      Reminder(
        id: EntityId('review-reminder'),
        cuttingId: cutting.id,
        scheduledForUtc: now.subtract(const Duration(hours: 1)),
        timeZoneId: 'UTC',
        status: ReminderStatus.pending,
        createdAtUtc: now.subtract(const Duration(days: 1)),
        updatedAtUtc: now.subtract(const Duration(days: 1)),
      ),
    );
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          textScaler: TextScaler.linear(1.5),
          disableAnimations: true,
        ),
        child: CuttingLogApp(
          overview: const JournalOverview(
            parentPlantCount: 1,
            activeCuttingCount: 1,
          ),
          dataRepository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review active cuttings'));
    await tester.pumpAndSettle();

    expect(find.text('Review cutting'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Overdue check-in')),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('Overdue check-in'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('explainer card explains the app and links to the guide', (
    tester,
  ) async {
    await tester.pumpWidget(
      CuttingLogApp(
        overview: const JournalOverview(
          parentPlantCount: 0,
          activeCuttingCount: 0,
        ),
        dataRepository: InMemoryJournalDataRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('What is Cutting Log?'), findsOneWidget);
    expect(find.text('Read the full how-to guide'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('open-how-to-use')));
    await tester.pumpAndSettle();
    expect(find.text('How to use Cutting Log'), findsOneWidget);
    expect(find.text('Basic flow'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('does not diagnose plants'),
      300,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('does not diagnose plants'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('portability tools moved to the separate advanced screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      CuttingLogApp(
        overview: const JournalOverview(
          parentPlantCount: 0,
          activeCuttingCount: 0,
        ),
        dataRepository: InMemoryJournalDataRepository(),
      ),
    );
    await tester.pumpAndSettle();

    // The home screen no longer carries the everyday-data clutter.
    expect(find.text('Export, restore, and erase local data'), findsNothing);
    expect(find.byKey(const ValueKey('export-backup')), findsNothing);

    await _tapVisible(tester, find.byKey(const ValueKey('advanced-tools')));
    await tester.pumpAndSettle();
    expect(find.text('Advanced data tools'), findsOneWidget);
    expect(
      find.textContaining('never uploads backups automatically'),
      findsOneWidget,
    );
    // This runtime wires no portability workflow, so the tools report
    // themselves unavailable rather than disappearing silently.
    expect(find.textContaining('unavailable in this runtime'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a dozen plant icons are offered and persist on the parent', (
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
      'Icon parent',
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('pick-new-parent-icon')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Choose a plant icon'), findsOneWidget);
    expect(find.byKey(const ValueKey('plant-icon-eco')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('plant-icon-local_florist')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('plant-icon-local_florist')));
    await tester.pumpAndSettle();
    expect(find.text('Icon: Flower'), findsOneWidget);

    await _tapVisible(tester, find.byKey(const ValueKey('create-parent')));
    await tester.pumpAndSettle();

    final parents = await repository.getParentPlants();
    expect(parents.single.iconKey, 'local_florist');
  });

  testWidgets('method and medium are dropdowns and the name can be blank', (
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
      'Defaults parent',
    );
    await _tapVisible(tester, find.byKey(const ValueKey('create-parent')));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(DropdownButtonFormField<String>, 'Method'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(DropdownButtonFormField<String>, 'Medium'),
      findsOneWidget,
    );

    // Start a cutting without typing any identifier at all.
    await _tapVisible(tester, find.byKey(const ValueKey('start-cutting')));
    await tester.pumpAndSettle();
    expect(find.text('Cutting 1 timeline'), findsOneWidget);

    final parents = await repository.getParentPlants();
    final cuttings = await repository.getCuttings(parentId: parents.single.id);
    expect(cuttings.single.name, 'Cutting 1');
    expect(cuttings.single.method, 'Stem');
    expect(cuttings.single.medium, 'Water');
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
