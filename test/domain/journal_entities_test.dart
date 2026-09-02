import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final base = DateTime.utc(2026, 1, 1, 12);
  final cuttingId = EntityId('cutting-1');

  group('domain validation', () {
    test('requires explicit UTC timestamps and normalized IDs', () {
      expect(() => EntityId('  '), throwsArgumentError);
      expect(
        () => ParentPlant(
          id: EntityId('parent-1'),
          nickname: 'Mother plant',
          createdAtUtc: DateTime(2026),
          updatedAtUtc: DateTime(2026),
        ),
        throwsArgumentError,
      );
    });

    test('normalizes tags and rejects unsafe media paths', () {
      final cutting = Cutting(
        id: cuttingId,
        parentId: EntityId('parent-1'),
        name: 'First',
        method: 'stem',
        tags: const <String>[' Water ', 'water', 'North'],
        startedAtUtc: base,
        createdAtUtc: base,
        updatedAtUtc: base,
      );

      expect(cutting.tags, <String>['north', 'water']);
      expect(
        () => MediaAsset(
          id: EntityId('media-1'),
          eventId: EntityId('event-1'),
          relativePath: '../outside.jpg',
          sha256: 'a' * 64,
          mediaType: 'image/jpeg',
          importedAtUtc: base,
        ),
        throwsArgumentError,
      );
    });

    test('records UTC reminder instant and an IANA-style timezone', () {
      expect(
        () => Reminder(
          id: EntityId('reminder-1'),
          cuttingId: cuttingId,
          scheduledForUtc: base,
          timeZoneId: 'local',
          status: ReminderStatus.pending,
          createdAtUtc: base,
          updatedAtUtc: base,
        ),
        throwsArgumentError,
      );
      expect(
        Reminder.canTransition(
          ReminderStatus.completed,
          ReminderStatus.pending,
        ),
        isFalse,
      );
    });
  });

  group('event replay', () {
    test('orders equal and out-of-order timestamps deterministically', () {
      final callusing = _stageEvent(
        id: 'b',
        cuttingId: cuttingId,
        stage: CuttingStage.callusing,
        occurredAtUtc: base.add(const Duration(days: 1)),
        createdAtUtc: base.add(const Duration(days: 2)),
      );
      final rooting = _stageEvent(
        id: 'c',
        cuttingId: cuttingId,
        stage: CuttingStage.rooting,
        occurredAtUtc: base.add(const Duration(days: 1)),
        createdAtUtc: base.add(const Duration(days: 3)),
      );
      final observation = CuttingEvent(
        id: EntityId('a'),
        cuttingId: cuttingId,
        occurredAtUtc: base,
        createdAtUtc: base.add(const Duration(days: 4)),
        kind: CuttingEventKind.observation,
        note: 'Entered later for an earlier observation',
      );

      final state = deriveCuttingState(<CuttingEvent>[
        rooting,
        observation,
        callusing,
      ]);

      expect(state.stage, CuttingStage.rooting);
      expect(state.outcome, CuttingOutcome.active);
    });

    test('uses append-only correction events without mutating originals', () {
      final original = _stageEvent(
        id: 'original',
        cuttingId: cuttingId,
        stage: CuttingStage.rooting,
        occurredAtUtc: base.add(const Duration(days: 1)),
        createdAtUtc: base.add(const Duration(days: 1)),
      );
      final correction = _stageEvent(
        id: 'correction',
        cuttingId: cuttingId,
        stage: CuttingStage.callusing,
        occurredAtUtc: base.add(const Duration(days: 1)),
        createdAtUtc: base.add(const Duration(days: 2)),
        correctsEventId: original.id,
      );
      final later = _stageEvent(
        id: 'later',
        cuttingId: cuttingId,
        stage: CuttingStage.rooting,
        occurredAtUtc: base.add(const Duration(days: 3)),
        createdAtUtc: base.add(const Duration(days: 3)),
      );

      final state = deriveCuttingState(<CuttingEvent>[
        original,
        correction,
        later,
      ]);

      expect(state.stage, CuttingStage.rooting);
      expect(original.stage, CuttingStage.rooting);
    });

    test('rejects duplicate IDs, backward stages, and post-outcome stages', () {
      final callusing = _stageEvent(
        id: 'same',
        cuttingId: cuttingId,
        stage: CuttingStage.callusing,
        occurredAtUtc: base,
        createdAtUtc: base,
      );
      expect(
        () => deriveCuttingState(<CuttingEvent>[callusing, callusing]),
        throwsStateError,
      );
      expect(
        () => deriveCuttingState(<CuttingEvent>[
          _stageEvent(
            id: 'rooting',
            cuttingId: cuttingId,
            stage: CuttingStage.rooting,
            occurredAtUtc: base,
            createdAtUtc: base,
          ),
          _stageEvent(
            id: 'backward',
            cuttingId: cuttingId,
            stage: CuttingStage.callusing,
            occurredAtUtc: base.add(const Duration(days: 1)),
            createdAtUtc: base.add(const Duration(days: 1)),
          ),
        ]),
        throwsStateError,
      );
      expect(
        () => deriveCuttingState(<CuttingEvent>[
          CuttingEvent(
            id: EntityId('gifted'),
            cuttingId: cuttingId,
            occurredAtUtc: base,
            createdAtUtc: base,
            kind: CuttingEventKind.outcome,
            outcome: CuttingOutcome.gifted,
          ),
          _stageEvent(
            id: 'too-late',
            cuttingId: cuttingId,
            stage: CuttingStage.callusing,
            occurredAtUtc: base.add(const Duration(days: 1)),
            createdAtUtc: base.add(const Duration(days: 1)),
          ),
        ]),
        throwsStateError,
      );
    });
  });
}

CuttingEvent _stageEvent({
  required String id,
  required EntityId cuttingId,
  required CuttingStage stage,
  required DateTime occurredAtUtc,
  required DateTime createdAtUtc,
  EntityId? correctsEventId,
}) => CuttingEvent(
  id: EntityId(id),
  cuttingId: cuttingId,
  occurredAtUtc: occurredAtUtc,
  createdAtUtc: createdAtUtc,
  kind: CuttingEventKind.stage,
  stage: stage,
  correctsEventId: correctsEventId,
);
