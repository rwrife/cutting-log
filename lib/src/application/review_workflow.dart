import 'package:cutting_log/src/application/review_models.dart';
import 'package:cutting_log/src/domain/journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';

final class ReviewWorkflow {
  const ReviewWorkflow(this._repository);

  final JournalDataRepository _repository;

  Future<List<ReviewItem>> search(
    ReviewFilter filter, {
    required DateTime nowUtc,
  }) async {
    final parents = {
      for (final p in await _repository.getParentPlants()) p.id: p,
    };
    final items = <ReviewItem>[];
    for (final cutting in await _repository.getCuttings()) {
      if (cutting.archivedAtUtc != null) continue;
      final parent = parents[cutting.parentId];
      if (parent == null) continue;
      final events = await _repository.getCuttingEvents(cutting.id);
      final reminders = await _repository.getReminders(cutting.id);
      final pending =
          reminders.where((r) => r.status == ReminderStatus.pending).toList()
            ..sort(_compareReminders);
      final item = ReviewItem(
        cutting: cutting,
        parent: parent,
        state: deriveCuttingState(events),
        lastActivityUtc: events.isEmpty
            ? cutting.createdAtUtc
            : events.last.occurredAtUtc,
        pendingReminder: pending.firstOrNull,
      );
      if (_matches(item, filter, nowUtc)) items.add(item);
    }
    items.sort((a, b) {
      final aDue = a.pendingReminder?.scheduledForUtc;
      final bDue = b.pendingReminder?.scheduledForUtc;
      if (aDue != null && bDue != null) {
        final due = aDue.compareTo(bDue);
        if (due != 0) return due;
      } else if (aDue != null) {
        return -1;
      } else if (bDue != null) {
        return 1;
      }
      final activity = b.lastActivityUtc.compareTo(a.lastActivityUtc);
      return activity != 0 ? activity : a.cutting.id.compareTo(b.cutting.id);
    });
    return items;
  }

  Future<List<SiblingSummary>> siblings(EntityId parentId) async {
    final result = <SiblingSummary>[];
    for (final cutting in await _repository.getCuttings(parentId: parentId)) {
      final events = await _repository.getCuttingEvents(cutting.id);
      result.add(
        SiblingSummary(
          cutting: cutting,
          state: deriveCuttingState(events),
          events: List.unmodifiable(events),
        ),
      );
    }
    result.sort((a, b) {
      final started = a.cutting.startedAtUtc.compareTo(b.cutting.startedAtUtc);
      return started != 0 ? started : a.cutting.id.compareTo(b.cutting.id);
    });
    return result;
  }
}

bool _matches(ReviewItem item, ReviewFilter filter, DateTime nowUtc) {
  final query = filter.query.trim().toLowerCase();
  if (query.isNotEmpty &&
      !<String>[
        item.cutting.name,
        item.parent.nickname,
        item.cutting.method,
        item.cutting.medium,
        item.cutting.location,
        ...item.cutting.tags,
      ].join(' ').toLowerCase().contains(query)) {
    return false;
  }
  if (filter.parentId != null && item.parent.id != filter.parentId) {
    return false;
  }
  if (filter.stage != null && item.state.stage != filter.stage) return false;
  if (filter.outcome != null && item.state.outcome != filter.outcome) {
    return false;
  }
  if (filter.tag != null && !item.cutting.tags.contains(filter.tag)) {
    return false;
  }
  final due = item.pendingReminder?.scheduledForUtc;
  switch (filter.due) {
    case DueFilter.any:
      break;
    case DueFilter.due:
      if (due == null || due.isAfter(nowUtc)) return false;
    case DueFilter.overdue:
      if (due == null || !due.isBefore(nowUtc)) return false;
    case DueFilter.upcoming:
      if (due == null || !due.isAfter(nowUtc)) return false;
    case DueFilter.none:
      if (due != null) return false;
  }
  final activeWithin = filter.activeWithin;
  if (activeWithin != null &&
      item.lastActivityUtc.isBefore(nowUtc.subtract(activeWithin))) {
    return false;
  }
  return true;
}

int _compareReminders(Reminder a, Reminder b) {
  final scheduled = a.scheduledForUtc.compareTo(b.scheduledForUtc);
  return scheduled != 0 ? scheduled : a.id.compareTo(b.id);
}
