import 'package:cutting_log/src/application/review_models.dart';
import 'package:cutting_log/src/application/review_workflow.dart';
import 'package:cutting_log/src/data/in_memory_journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'filters every review dimension and orders overdue items first',
    () async {
      final repository = InMemoryJournalDataRepository();
      final now = DateTime.utc(2026, 6, 10, 12);
      final parent = ParentPlant(
        id: EntityId('parent'),
        nickname: 'Kitchen parent',
        createdAtUtc: now.subtract(const Duration(days: 20)),
        updatedAtUtc: now,
      );
      await repository.createParentPlant(parent);
      final older = _cutting('older', parent.id, now, const <String>['water']);
      final newer = _cutting('newer', parent.id, now, const <String>['soil']);
      await repository.createCutting(older);
      await repository.createCutting(newer);
      await repository.appendEvent(
        _stage(
          older.id,
          'older-stage',
          now.subtract(const Duration(days: 8)),
          CuttingStage.rooting,
        ),
      );
      await repository.appendEvent(
        _stage(
          newer.id,
          'newer-stage',
          now.subtract(const Duration(hours: 1)),
          CuttingStage.callusing,
        ),
      );
      await repository.createReminder(
        _reminder(older.id, 'due', now.subtract(const Duration(hours: 1)), now),
      );
      await repository.createReminder(
        _reminder(newer.id, 'later', now.add(const Duration(days: 1)), now),
      );
      final workflow = ReviewWorkflow(repository);

      final all = await workflow.search(const ReviewFilter(), nowUtc: now);
      expect(all.map((item) => item.cutting.id.value), <String>[
        'older',
        'newer',
      ]);
      expect(
        (await workflow.search(
          ReviewFilter(
            query: 'kitchen',
            parentId: parent.id,
            stage: CuttingStage.rooting,
            tag: 'water',
            outcome: CuttingOutcome.active,
            due: DueFilter.overdue,
          ),
          nowUtc: now,
        )).single.cutting.id,
        older.id,
      );
      expect(
        await workflow.search(
          const ReviewFilter(activeWithin: Duration(days: 2)),
          nowUtc: now,
        ),
        hasLength(1),
      );
    },
  );

  test(
    'sibling summaries use only recorded state and deterministic dates',
    () async {
      final repository = InMemoryJournalDataRepository();
      final now = DateTime.utc(2026, 6, 10);
      final parent = ParentPlant(
        id: EntityId('parent'),
        nickname: 'Parent',
        createdAtUtc: now,
        updatedAtUtc: now,
      );
      await repository.createParentPlant(parent);
      await repository.createCutting(
        _cutting('b', parent.id, now.add(const Duration(days: 1)), const []),
      );
      await repository.createCutting(_cutting('a', parent.id, now, const []));

      final summaries = await ReviewWorkflow(repository).siblings(parent.id);
      expect(summaries.map((item) => item.cutting.id.value), <String>[
        'a',
        'b',
      ]);
      expect(
        summaries.every((item) => item.state.stage == CuttingStage.started),
        isTrue,
      );
    },
  );
}

Cutting _cutting(
  String id,
  EntityId parentId,
  DateTime now,
  List<String> tags,
) => Cutting(
  id: EntityId(id),
  parentId: parentId,
  name: 'Cutting $id',
  method: 'stem',
  tags: tags,
  startedAtUtc: now,
  createdAtUtc: now,
  updatedAtUtc: now,
);

CuttingEvent _stage(
  EntityId cuttingId,
  String id,
  DateTime at,
  CuttingStage stage,
) => CuttingEvent(
  id: EntityId(id),
  cuttingId: cuttingId,
  occurredAtUtc: at,
  createdAtUtc: at,
  kind: CuttingEventKind.stage,
  stage: stage,
);

Reminder _reminder(
  EntityId cuttingId,
  String id,
  DateTime scheduled,
  DateTime created,
) => Reminder(
  id: EntityId(id),
  cuttingId: cuttingId,
  scheduledForUtc: scheduled,
  timeZoneId: 'UTC',
  status: ReminderStatus.pending,
  createdAtUtc: created,
  updatedAtUtc: created,
);
