import 'package:cutting_log/src/application/capture_workflow.dart';
import 'package:cutting_log/src/data/in_memory_journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates linked cutting and append-only timeline', () async {
    final repository = InMemoryJournalDataRepository();
    final workflow = CaptureWorkflow(
      repository,
      clock: () => DateTime.utc(2026, 1, 1),
    );
    final parent = await workflow.createParent(nickname: 'Kitchen pothos');
    final cutting = await workflow.startCutting(
      parentId: parent.id,
      name: 'Node A',
      method: 'Stem',
      startedAtUtc: DateTime.utc(2025, 12, 31),
      tags: const ['window'],
    );
    await workflow.addObservation(
      cuttingId: cutting.id,
      note: 'User-recorded change',
    );
    await workflow.changeStage(
      cuttingId: cutting.id,
      stage: CuttingStage.callusing,
    );
    await workflow.recordOutcome(
      cuttingId: cutting.id,
      outcome: CuttingOutcome.potted,
    );
    final events = await repository.getCuttingEvents(cutting.id);
    expect((await repository.getCutting(cutting.id))?.parentId, parent.id);
    expect(events, hasLength(4));
    expect(deriveCuttingState(events).stage, CuttingStage.callusing);
    expect(deriveCuttingState(events).outcome, CuttingOutcome.potted);
  });

  test('does not leave a partial cutting when validation rejects it', () async {
    final repository = InMemoryJournalDataRepository();
    final workflow = CaptureWorkflow(repository);
    final parent = await workflow.createParent(nickname: 'Parent');
    await expectLater(
      workflow.startCutting(
        parentId: parent.id,
        name: '',
        method: 'Stem',
        startedAtUtc: DateTime.now().toUtc(),
      ),
      throwsArgumentError,
    );
    expect(await repository.getCuttings(parentId: parent.id), isEmpty);
    expect(await repository.getCuttingEvents(EntityId('missing')), isEmpty);
  });

  test(
    'rejects duplicate active names without creating partial history',
    () async {
      final repository = InMemoryJournalDataRepository();
      final workflow = CaptureWorkflow(repository);
      final parent = await workflow.createParent(nickname: 'Parent');
      await workflow.startCutting(
        parentId: parent.id,
        name: 'Node A',
        method: 'Stem',
        startedAtUtc: DateTime.now().toUtc(),
      );

      await expectLater(
        workflow.startCutting(
          parentId: parent.id,
          name: ' node a ',
          method: 'Leaf',
          startedAtUtc: DateTime.now().toUtc(),
        ),
        throwsArgumentError,
      );

      expect(await repository.getCuttings(parentId: parent.id), hasLength(1));
    },
  );

  test('correction appends replacement and preserves original event', () async {
    final repository = InMemoryJournalDataRepository();
    var now = DateTime.utc(2026, 1, 1, 12);
    final workflow = CaptureWorkflow(repository, clock: () => now);
    final parent = await workflow.createParent(nickname: 'Parent');
    final cutting = await workflow.startCutting(
      parentId: parent.id,
      name: 'Node A',
      method: 'Stem',
      startedAtUtc: DateTime.utc(2026, 1, 1),
    );
    await workflow.addObservation(cuttingId: cutting.id, note: 'First wording');
    final original = (await repository.getCuttingEvents(cutting.id)).last;
    now = now.add(const Duration(minutes: 1));

    await workflow.correctEvent(original: original, note: 'Corrected wording');

    final events = await repository.getCuttingEvents(cutting.id);
    expect(events, hasLength(3));
    expect(events.where((event) => event.id == original.id), hasLength(1));
    expect(events.last.correctsEventId, original.id);
    expect(events.last.note, 'Corrected wording');
    expect(deriveCuttingState(events).outcome, CuttingOutcome.active);
  });
}
