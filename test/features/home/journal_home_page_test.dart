import 'package:cutting_log/src/app.dart';
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
}
