import 'package:cutting_log/src/domain/journal_entities.dart';

enum DueFilter { any, due, overdue, upcoming, none }

final class ReviewFilter {
  const ReviewFilter({
    this.query = '',
    this.parentId,
    this.stage,
    this.tag,
    this.outcome,
    this.due = DueFilter.any,
    this.activeWithin,
  });

  final Duration? activeWithin;
  final DueFilter due;
  final CuttingOutcome? outcome;
  final EntityId? parentId;
  final String query;
  final CuttingStage? stage;
  final String? tag;
}

final class ReviewItem {
  const ReviewItem({
    required this.cutting,
    required this.parent,
    required this.state,
    required this.lastActivityUtc,
    required this.pendingReminder,
  });

  final Cutting cutting;
  final DateTime lastActivityUtc;
  final ParentPlant parent;
  final Reminder? pendingReminder;
  final DerivedCuttingState state;
}

final class SiblingSummary {
  const SiblingSummary({
    required this.cutting,
    required this.state,
    required this.events,
  });

  final Cutting cutting;
  final List<CuttingEvent> events;
  final DerivedCuttingState state;
}
