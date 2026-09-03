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
    final events = await repository.getCuttingEvents(cutting.id);
    expect((await repository.getCutting(cutting.id))?.parentId, parent.id);
    expect(events, hasLength(3));
    expect(deriveCuttingState(events).stage, CuttingStage.callusing);
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
  });
}
