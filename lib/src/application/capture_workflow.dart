import 'dart:math';

import 'package:cutting_log/src/domain/journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';

/// User-initiated commands for the first capture flow.  This layer owns no UI
/// and does not request permissions, so journaling remains useful offline.
final class CaptureWorkflow {
  CaptureWorkflow(
    this._repository, {
    DateTime Function()? clock,
    IdFactory? ids,
  }) : _clock = clock ?? (() => DateTime.now().toUtc()),
       _ids = ids ?? const IdFactory();

  final DateTime Function() _clock;
  final IdFactory _ids;
  final JournalDataRepository _repository;

  Future<ParentPlant> createParent({
    required String nickname,
    String? speciesText,
    String notes = '',
  }) async {
    final now = _clock();
    final parent = ParentPlant(
      id: _ids.next('parent'),
      nickname: nickname,
      speciesText: speciesText,
      notes: notes,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    await _repository.createParentPlant(parent);
    return parent;
  }

  Future<Cutting> startCutting({
    required EntityId parentId,
    required String name,
    required String method,
    required DateTime startedAtUtc,
    String medium = '',
    String location = '',
    Iterable<String> tags = const <String>[],
    String initialNote = '',
  }) async {
    final now = _clock();
    final cutting = Cutting(
      id: _ids.next('cutting'),
      parentId: parentId,
      name: name,
      method: method,
      medium: medium,
      location: location,
      tags: tags,
      startedAtUtc: startedAtUtc,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    final event = CuttingEvent(
      id: _ids.next('event'),
      cuttingId: cutting.id,
      occurredAtUtc: startedAtUtc,
      createdAtUtc: now,
      kind: CuttingEventKind.stage,
      stage: CuttingStage.started,
      note: initialNote,
    );
    await _repository.createCuttingWithInitialEvent(cutting, event);
    return cutting;
  }

  Future<void> addObservation({
    required EntityId cuttingId,
    required String note,
    DateTime? occurredAtUtc,
  }) => _repository.appendEvent(
    CuttingEvent(
      id: _ids.next('event'),
      cuttingId: cuttingId,
      occurredAtUtc: occurredAtUtc ?? _clock(),
      createdAtUtc: _clock(),
      kind: CuttingEventKind.observation,
      note: note,
    ),
  );

  Future<void> changeStage({
    required EntityId cuttingId,
    required CuttingStage stage,
    String note = '',
  }) => _repository.appendEvent(
    CuttingEvent(
      id: _ids.next('event'),
      cuttingId: cuttingId,
      occurredAtUtc: _clock(),
      createdAtUtc: _clock(),
      kind: CuttingEventKind.stage,
      stage: stage,
      note: note,
    ),
  );

  Future<void> recordOutcome({
    required EntityId cuttingId,
    required CuttingOutcome outcome,
    String note = '',
  }) => _repository.appendEvent(
    CuttingEvent(
      id: _ids.next('event'),
      cuttingId: cuttingId,
      occurredAtUtc: _clock(),
      createdAtUtc: _clock(),
      kind: CuttingEventKind.outcome,
      outcome: outcome,
      note: note,
    ),
  );
}

final class IdFactory {
  const IdFactory();
  EntityId next(String prefix) => EntityId(
    '$prefix-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}',
  );
}
