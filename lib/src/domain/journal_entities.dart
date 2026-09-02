/// Stable, caller-generated identifier persisted verbatim across exports.
final class EntityId implements Comparable<EntityId> {
  factory EntityId(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.length > 128) {
      throw ArgumentError.value(
        value,
        'value',
        'must contain 1–128 characters',
      );
    }
    return EntityId._(normalized);
  }

  const EntityId._(this.value);

  final String value;

  @override
  int compareTo(EntityId other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is EntityId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

enum CuttingEventKind { observation, stage, outcome }

enum CuttingOutcome { active, potted, gifted, unsuccessful }

enum CuttingStage { started, callusing, rooting, transferred }

enum ReminderStatus { pending, completed, cancelled }

final class ParentPlant {
  ParentPlant({
    required this.id,
    required String nickname,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.speciesText,
    this.notes = '',
    this.archivedAtUtc,
  }) : nickname = _requiredText(nickname, 'nickname', 80) {
    _utc(createdAtUtc, 'createdAtUtc');
    _utc(updatedAtUtc, 'updatedAtUtc');
    _ordered(createdAtUtc, updatedAtUtc, 'updatedAtUtc');
    final archived = archivedAtUtc;
    if (archived != null) {
      _utc(archived, 'archivedAtUtc');
      _ordered(createdAtUtc, archived, 'archivedAtUtc');
    }
    _optionalText(speciesText, 'speciesText', 160);
    _optionalText(notes, 'notes', 10000);
  }

  final DateTime? archivedAtUtc;
  final DateTime createdAtUtc;
  final EntityId id;
  final String nickname;
  final String notes;
  final String? speciesText;
  final DateTime updatedAtUtc;
}

final class Cutting {
  Cutting({
    required this.id,
    required this.parentId,
    required String name,
    required String method,
    required this.startedAtUtc,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.medium = '',
    this.location = '',
    Iterable<String> tags = const <String>[],
    this.archivedAtUtc,
  }) : name = _requiredText(name, 'name', 80),
       method = _requiredText(method, 'method', 120),
       tags = normalizeTags(tags) {
    _utc(startedAtUtc, 'startedAtUtc');
    _utc(createdAtUtc, 'createdAtUtc');
    _utc(updatedAtUtc, 'updatedAtUtc');
    _ordered(createdAtUtc, updatedAtUtc, 'updatedAtUtc');
    final archived = archivedAtUtc;
    if (archived != null) {
      _utc(archived, 'archivedAtUtc');
      _ordered(createdAtUtc, archived, 'archivedAtUtc');
    }
    _optionalText(medium, 'medium', 160);
    _optionalText(location, 'location', 240);
  }

  final DateTime? archivedAtUtc;
  final DateTime createdAtUtc;
  final EntityId id;
  final String location;
  final String medium;
  final String method;
  final String name;
  final EntityId parentId;
  final DateTime startedAtUtc;
  final List<String> tags;
  final DateTime updatedAtUtc;

  static List<String> normalizeTags(Iterable<String> values) {
    final normalized =
        values.map((tag) => tag.trim().toLowerCase()).toSet().toList()..sort();
    if (normalized.length > 20 ||
        normalized.any((tag) => tag.isEmpty || tag.length > 40)) {
      throw ArgumentError.value(
        values,
        'tags',
        'use up to 20 tags of 1–40 characters',
      );
    }
    return List<String>.unmodifiable(normalized);
  }
}

final class CuttingEvent {
  CuttingEvent({
    required this.id,
    required this.cuttingId,
    required this.occurredAtUtc,
    required this.createdAtUtc,
    required this.kind,
    this.note = '',
    this.stage,
    this.outcome,
    this.correctsEventId,
  }) {
    _utc(occurredAtUtc, 'occurredAtUtc');
    _utc(createdAtUtc, 'createdAtUtc');
    _optionalText(note, 'note', 10000);
    switch (kind) {
      case CuttingEventKind.observation:
        if (stage != null || outcome != null) {
          throw ArgumentError(
            'observation events cannot contain stage or outcome payloads',
          );
        }
      case CuttingEventKind.stage:
        if (stage == null || outcome != null) {
          throw ArgumentError('stage events require only a stage payload');
        }
      case CuttingEventKind.outcome:
        if (outcome == null || stage != null) {
          throw ArgumentError('outcome events require only an outcome payload');
        }
    }
    if (correctsEventId == id) {
      throw ArgumentError('an event cannot correct itself');
    }
  }

  final DateTime createdAtUtc;
  final EntityId? correctsEventId;
  final EntityId cuttingId;
  final EntityId id;
  final CuttingEventKind kind;
  final String note;
  final DateTime occurredAtUtc;
  final CuttingOutcome? outcome;
  final CuttingStage? stage;
}

final class DerivedCuttingState {
  const DerivedCuttingState({required this.stage, required this.outcome});

  final CuttingOutcome outcome;
  final CuttingStage stage;
}

/// Replays the effective append-only history in a deterministic order.
///
/// Corrections are new events that name the event they supersede; stored rows
/// are never updated. Equal occurrence times use creation time and then stable
/// ID as tie-breakers. Events may be entered out of chronological order.
DerivedCuttingState deriveCuttingState(Iterable<CuttingEvent> source) {
  final events = source.toList();
  final byId = <EntityId, CuttingEvent>{};
  for (final event in events) {
    if (byId[event.id] != null) {
      throw StateError('duplicate event ID');
    }
    byId[event.id] = event;
  }

  final superseded = <EntityId>{};
  for (final event in events) {
    final targetId = event.correctsEventId;
    if (targetId == null) {
      continue;
    }
    final target = byId[targetId];
    if (target == null || target.cuttingId != event.cuttingId) {
      throw StateError('correction target must exist on the same cutting');
    }
    if (event.createdAtUtc.isBefore(target.createdAtUtc)) {
      throw StateError('a correction cannot be created before its target');
    }
    if (!superseded.add(targetId)) {
      throw StateError('an event can be corrected only once');
    }
  }

  final effective =
      events.where((event) => !superseded.contains(event.id)).toList()
        ..sort(_compareEvents);
  var stage = CuttingStage.started;
  var outcome = CuttingOutcome.active;
  for (final event in effective) {
    switch (event.kind) {
      case CuttingEventKind.observation:
        break;
      case CuttingEventKind.stage:
        if (outcome != CuttingOutcome.active) {
          throw StateError('stage cannot change after a terminal outcome');
        }
        final next = event.stage!;
        if (next.index < stage.index) {
          throw StateError('stage events cannot move backward');
        }
        stage = next;
      case CuttingEventKind.outcome:
        final next = event.outcome!;
        if (outcome != CuttingOutcome.active && next != outcome) {
          throw StateError(
            'terminal outcomes cannot be replaced by later events',
          );
        }
        outcome = next;
    }
  }
  return DerivedCuttingState(stage: stage, outcome: outcome);
}

final class MediaAsset {
  MediaAsset({
    required this.id,
    required this.eventId,
    required String relativePath,
    required String sha256,
    required String mediaType,
    required this.importedAtUtc,
    this.caption = '',
    this.capturedAtUtc,
  }) : relativePath = _relativePath(relativePath),
       sha256 = _sha256(sha256),
       mediaType = _requiredText(mediaType, 'mediaType', 120) {
    _utc(importedAtUtc, 'importedAtUtc');
    final captured = capturedAtUtc;
    if (captured != null) {
      _utc(captured, 'capturedAtUtc');
    }
    _optionalText(caption, 'caption', 1000);
  }

  final DateTime? capturedAtUtc;
  final String caption;
  final EntityId eventId;
  final EntityId id;
  final DateTime importedAtUtc;
  final String mediaType;
  final String relativePath;
  final String sha256;
}

final class Reminder {
  Reminder({
    required this.id,
    required this.cuttingId,
    required this.scheduledForUtc,
    required String timeZoneId,
    required this.status,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.platformNotificationId,
    this.completedAtUtc,
    this.snoozedFromUtc,
  }) : timeZoneId = _timeZoneId(timeZoneId) {
    _utc(scheduledForUtc, 'scheduledForUtc');
    _utc(createdAtUtc, 'createdAtUtc');
    _utc(updatedAtUtc, 'updatedAtUtc');
    _ordered(createdAtUtc, updatedAtUtc, 'updatedAtUtc');
    final completed = completedAtUtc;
    if (completed != null) {
      _utc(completed, 'completedAtUtc');
    }
    final snoozed = snoozedFromUtc;
    if (snoozed != null) {
      _utc(snoozed, 'snoozedFromUtc');
    }
    if (status == ReminderStatus.completed && completed == null) {
      throw ArgumentError('completed reminders require completedAtUtc');
    }
    if (status != ReminderStatus.completed && completed != null) {
      throw ArgumentError('only completed reminders may have completedAtUtc');
    }
    _optionalText(platformNotificationId, 'platformNotificationId', 256);
  }

  final DateTime? completedAtUtc;
  final DateTime createdAtUtc;
  final EntityId cuttingId;
  final EntityId id;
  final String? platformNotificationId;
  final DateTime scheduledForUtc;
  final DateTime? snoozedFromUtc;
  final ReminderStatus status;
  final String timeZoneId;
  final DateTime updatedAtUtc;

  static bool canTransition(ReminderStatus from, ReminderStatus to) =>
      from == to ||
      (from == ReminderStatus.pending && to != ReminderStatus.pending);
}

int _compareEvents(CuttingEvent left, CuttingEvent right) {
  final occurred = left.occurredAtUtc.compareTo(right.occurredAtUtc);
  if (occurred != 0) {
    return occurred;
  }
  final created = left.createdAtUtc.compareTo(right.createdAtUtc);
  return created != 0 ? created : left.id.compareTo(right.id);
}

void _optionalText(String? value, String name, int maxLength) {
  if (value != null && value.length > maxLength) {
    throw ArgumentError.value(
      value,
      name,
      'must be at most $maxLength characters',
    );
  }
}

void _ordered(DateTime earliest, DateTime value, String name) {
  if (value.isBefore(earliest)) {
    throw ArgumentError.value(value, name, 'must not be earlier than creation');
  }
}

String _relativePath(String value) {
  final normalized = value.trim();
  final parts = normalized.split('/');
  if (normalized.isEmpty ||
      normalized.startsWith('/') ||
      normalized.contains('\\') ||
      parts.any((part) => part.isEmpty || part == '.' || part == '..')) {
    throw ArgumentError.value(
      value,
      'relativePath',
      'must be a normalized app-relative path',
    );
  }
  return normalized;
}

String _requiredText(String value, String name, int maxLength) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > maxLength) {
    throw ArgumentError.value(
      value,
      name,
      'must contain 1–$maxLength characters',
    );
  }
  return normalized;
}

String _sha256(String value) {
  final normalized = value.trim().toLowerCase();
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(normalized)) {
    throw ArgumentError.value(
      value,
      'sha256',
      'must be 64 lowercase hexadecimal characters',
    );
  }
  return normalized;
}

String _timeZoneId(String value) {
  final normalized = value.trim();
  if (normalized == 'UTC' ||
      RegExp(r'^[A-Za-z_+-]+(?:/[A-Za-z0-9_+.-]+)+$').hasMatch(normalized)) {
    return normalized;
  }
  throw ArgumentError.value(
    value,
    'timeZoneId',
    'must be UTC or an IANA-style zone ID',
  );
}

void _utc(DateTime value, String name) {
  if (!value.isUtc) {
    throw ArgumentError.value(value, name, 'must be an explicit UTC DateTime');
  }
}
