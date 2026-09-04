import 'package:cutting_log/src/application/capture_workflow.dart';
import 'package:cutting_log/src/application/reminder_workflow.dart';
import 'package:cutting_log/src/application/review_models.dart';
import 'package:cutting_log/src/application/review_workflow.dart';
import 'package:cutting_log/src/domain/journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:cutting_log/src/domain/journal_overview.dart';
import 'package:cutting_log/src/domain/startup_policy.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:flutter/material.dart';

final class JournalHomePage extends StatefulWidget {
  const JournalHomePage({
    required this.overview,
    this.dataRepository,
    this.notificationGateway = const DisabledLocalNotificationGateway(),
    super.key,
  });

  final JournalOverview overview;
  final JournalDataRepository? dataRepository;
  final LocalNotificationGateway notificationGateway;

  @override
  State<JournalHomePage> createState() => _JournalHomePageState();
}

final class _JournalHomePageState extends State<JournalHomePage> {
  final _parentName = TextEditingController();
  final _parentSpecies = TextEditingController();
  final _parentNotes = TextEditingController();
  final _cuttingName = TextEditingController();
  final _method = TextEditingController(text: 'Stem');
  final _medium = TextEditingController();
  final _location = TextEditingController();
  final _tags = TextEditingController();
  final _initialNote = TextEditingController();
  final _eventNote = TextEditingController();
  final _search = TextEditingController();

  List<ParentPlant> _parents = const <ParentPlant>[];
  List<Cutting> _cuttings = const <Cutting>[];
  List<CuttingEvent> _events = const <CuttingEvent>[];
  List<Reminder> _reminders = const <Reminder>[];
  List<ReviewItem> _reviewItems = const <ReviewItem>[];
  List<SiblingSummary> _siblings = const <SiblingSummary>[];
  EntityId? _reviewParent;
  CuttingStage? _reviewStage;
  CuttingOutcome? _reviewOutcome;
  DueFilter _dueFilter = DueFilter.any;
  String? _reviewTag;
  bool _recentOnly = false;
  ParentPlant? _parent;
  Cutting? _cutting;
  DateTime _startedAt = DateTime.now().toUtc();
  bool _loading = true;
  bool _saving = false;
  String? _error;

  JournalDataRepository? get _repository => widget.dataRepository;
  CaptureWorkflow? get _workflow =>
      _repository == null ? null : CaptureWorkflow(_repository!);

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _parentName,
      _parentSpecies,
      _parentNotes,
      _cuttingName,
      _method,
      _medium,
      _location,
      _tags,
      _initialNote,
      _eventNote,
      _search,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _reload({
    EntityId? selectParent,
    EntityId? selectCutting,
  }) async {
    final repository = _repository;
    if (repository == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (mounted) setState(() => _loading = true);
    try {
      final parents = await repository.getParentPlants();
      final parent = _findById(parents, selectParent ?? _parent?.id);
      final cuttings = parent == null
          ? const <Cutting>[]
          : await repository.getCuttings(parentId: parent.id);
      final cutting = _findById(cuttings, selectCutting ?? _cutting?.id);
      final events = cutting == null
          ? const <CuttingEvent>[]
          : await repository.getCuttingEvents(cutting.id);
      final reminders = cutting == null
          ? const <Reminder>[]
          : await repository.getReminders(cutting.id);
      final siblings = parent == null
          ? const <SiblingSummary>[]
          : await ReviewWorkflow(repository).siblings(parent.id);
      final reviewItems = await ReviewWorkflow(repository).search(
        ReviewFilter(
          query: _search.text,
          parentId: _reviewParent,
          stage: _reviewStage,
          tag: _reviewTag,
          outcome: _reviewOutcome,
          due: _dueFilter,
          activeWithin: _recentOnly ? const Duration(days: 7) : null,
        ),
        nowUtc: DateTime.now().toUtc(),
      );
      if (!mounted) return;
      setState(() {
        _parents = parents;
        _parent = parent;
        _cuttings = cuttings;
        _cutting = cutting;
        _events = events;
        _reminders = reminders;
        _siblings = siblings;
        _reviewItems = reviewItems;
        _loading = false;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _message(error, fallback: 'Could not load local records.');
      });
    }
  }

  T? _findById<T>(Iterable<T> values, EntityId? id) {
    if (id == null) return null;
    for (final value in values) {
      final valueId = switch (value) {
        final ParentPlant parent => parent.id,
        final Cutting cutting => cutting.id,
        _ => null,
      };
      if (valueId == id) return value;
    }
    return null;
  }

  Future<bool> _run(
    Future<void> Function() action, {
    EntityId? selectParent,
    EntityId? selectCutting,
  }) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await action();
      await _reload(selectParent: selectParent, selectCutting: selectCutting);
      if (mounted) setState(() => _saving = false);
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      setState(() {
        _saving = false;
        _loading = false;
        _error = _message(error);
      });
      return false;
    }
  }

  String _message(Object error, {String fallback = 'Could not save changes.'}) {
    if (error is ArgumentError) {
      final name = error.name?.toString();
      final reason = error.message?.toString() ?? 'is invalid';
      return name == null ? reason : '${_fieldLabel(name)} $reason.';
    }
    if (error is JournalRepositoryException) return error.message;
    if (error is StateError) return error.message;
    return fallback;
  }

  String _fieldLabel(String name) => switch (name) {
    'nickname' => 'Parent nickname',
    'name' => 'Cutting name',
    'method' => 'Method',
    'note' => 'Observation',
    'tags' => 'Tags',
    _ => 'Entry',
  };

  Future<void> _createParent() async {
    final workflow = _workflow;
    if (workflow == null) return;
    ParentPlant? created;
    final saved = await _run(() async {
      created = await workflow.createParent(
        nickname: _parentName.text,
        speciesText: _parentSpecies.text.trim().isEmpty
            ? null
            : _parentSpecies.text.trim(),
        notes: _parentNotes.text,
      );
    });
    if (saved) {
      _parentName.clear();
      _parentSpecies.clear();
      _parentNotes.clear();
      await _selectParent(created!);
    }
  }

  Future<void> _selectParent(ParentPlant parent) async {
    setState(() {
      _parent = parent;
      _cutting = null;
      _events = const <CuttingEvent>[];
    });
    await _reload(selectParent: parent.id);
  }

  Future<void> _createCutting() async {
    final workflow = _workflow;
    final parent = _parent;
    if (workflow == null || parent == null) return;
    Cutting? created;
    final saved = await _run(() async {
      created = await workflow.startCutting(
        parentId: parent.id,
        name: _cuttingName.text,
        method: _method.text,
        medium: _medium.text,
        location: _location.text,
        tags: _tags.text.split(',').where((tag) => tag.trim().isNotEmpty),
        startedAtUtc: _startedAt,
        initialNote: _initialNote.text,
      );
    }, selectParent: parent.id);
    if (saved) {
      _cuttingName.clear();
      _medium.clear();
      _location.clear();
      _tags.clear();
      _initialNote.clear();
      await _reload(selectParent: parent.id, selectCutting: created!.id);
    }
  }

  Future<void> _pickStartDate() async {
    final local = _startedAt.toLocal();
    final selected = await showDatePicker(
      context: context,
      initialDate: local,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Select cutting start date',
    );
    if (selected != null && mounted) {
      setState(() {
        _startedAt = DateTime.utc(selected.year, selected.month, selected.day);
      });
    }
  }

  Future<void> _addObservation() async {
    final workflow = _workflow;
    final cutting = _cutting;
    if (workflow == null || cutting == null) return;
    final saved = await _run(
      () =>
          workflow.addObservation(cuttingId: cutting.id, note: _eventNote.text),
      selectParent: cutting.parentId,
      selectCutting: cutting.id,
    );
    if (saved) _eventNote.clear();
  }

  Future<void> _changeStage(CuttingStage stage) async {
    final workflow = _workflow;
    final cutting = _cutting;
    if (workflow == null || cutting == null) return;
    await _run(
      () => workflow.changeStage(cuttingId: cutting.id, stage: stage),
      selectParent: cutting.parentId,
      selectCutting: cutting.id,
    );
  }

  Future<void> _recordOutcome(CuttingOutcome outcome) async {
    final workflow = _workflow;
    final cutting = _cutting;
    if (workflow == null || cutting == null) return;
    await _run(
      () => workflow.recordOutcome(cuttingId: cutting.id, outcome: outcome),
      selectParent: cutting.parentId,
      selectCutting: cutting.id,
    );
  }

  Future<void> _correct(CuttingEvent event) async {
    var replacement = event.note;
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Correct event note'),
        content: TextFormField(
          initialValue: event.note,
          onChanged: (value) => replacement = value,
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Replacement note',
            helperText: 'The original event remains in history.',
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, replacement),
            child: const Text('Save correction'),
          ),
        ],
      ),
    );
    final workflow = _workflow;
    final cutting = _cutting;
    if (note == null || workflow == null || cutting == null) return;
    await _run(
      () => workflow.correctEvent(original: event, note: note),
      selectParent: cutting.parentId,
      selectCutting: cutting.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    const policy = StartupPolicy();
    return Scaffold(
      appBar: AppBar(title: const Text('Cutting Log')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              Semantics(
                container: true,
                label: 'Private journal ready',
                child: Text(
                  'Observe each cutting over time',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Stored privately on this device. No account, network, or optional permission is needed.',
              ),
              if (_loading) ...<Widget>[
                const SizedBox(height: 24),
                Center(
                  child: Semantics(
                    label: 'Loading local journal',
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ] else if (_repository == null) ...<Widget>[
                const SizedBox(height: 24),
                _overview(policy),
              ] else ...<Widget>[
                if (_error != null) _errorPanel(),
                const SizedBox(height: 24),
                _reviewSection(),
                const SizedBox(height: 24),
                _parentSection(),
                if (_parent != null) ...<Widget>[
                  const SizedBox(height: 24),
                  _cuttingSection(),
                ],
                if (_cutting != null) ...<Widget>[
                  const SizedBox(height: 24),
                  _timelineSection(),
                ],
              ],
              const SizedBox(height: 24),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Cutting Log records your observations. It does not diagnose plants, prescribe treatment, or predict propagation success.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorPanel() => Semantics(
    liveRegion: true,
    child: MaterialBanner(
      content: Text(_error!),
      actions: <Widget>[
        TextButton(onPressed: _reload, child: const Text('Retry')),
      ],
    ),
  );

  Widget _parentSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text('Parent plants', style: Theme.of(context).textTheme.titleLarge),
      if (_error != null) Semantics(liveRegion: true, child: Text(_error!)),
      if (_parents.where((parent) => parent.archivedAtUtc == null).isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('No active parent plants yet. Create one below.'),
        )
      else
        for (final parent in _parents.where(
          (parent) => parent.archivedAtUtc == null,
        ))
          Card(
            child: ListTile(
              title: Text(parent.nickname),
              subtitle: parent.speciesText == null
                  ? null
                  : Text(parent.speciesText!),
              selected: _parent?.id == parent.id,
              onTap: () => _selectParent(parent),
              trailing: IconButton(
                tooltip: 'Archive ${parent.nickname}',
                onPressed: _saving
                    ? null
                    : () => _run(() => _workflow!.archiveParent(parent.id)),
                icon: const Icon(Icons.archive_outlined),
              ),
            ),
          ),
      const SizedBox(height: 12),
      Text('Create parent', style: Theme.of(context).textTheme.titleMedium),
      _field(
        _parentName,
        'Parent plant nickname',
        action: TextInputAction.next,
      ),
      _field(
        _parentSpecies,
        'Species text (optional)',
        action: TextInputAction.next,
      ),
      _field(_parentNotes, 'Parent notes (optional)', maxLines: 2),
      FilledButton.icon(
        key: const ValueKey<String>('create-parent'),
        onPressed: _saving ? null : _createParent,
        icon: const Icon(Icons.add),
        label: const Text('Create parent plant'),
      ),
    ],
  );

  Widget _cuttingSection() {
    final parent = _parent!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Cuttings for ${parent.nickname}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _parent = null),
              child: const Text('Change parent'),
            ),
          ],
        ),
        if (_cuttings.where((cutting) => cutting.archivedAtUtc == null).isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No active cuttings for this parent.'),
          )
        else
          for (final cutting in _cuttings.where(
            (cutting) => cutting.archivedAtUtc == null,
          ))
            Card(
              child: ListTile(
                title: Text(cutting.name),
                subtitle: Text(
                  '${cutting.method} • started ${_date(cutting.startedAtUtc)}',
                ),
                selected: _cutting?.id == cutting.id,
                onTap: () =>
                    _reload(selectParent: parent.id, selectCutting: cutting.id),
                trailing: IconButton(
                  tooltip: 'Archive ${cutting.name}',
                  onPressed: _saving
                      ? null
                      : () => _run(
                          () => _workflow!.archiveCutting(cutting.id),
                          selectParent: parent.id,
                        ),
                  icon: const Icon(Icons.archive_outlined),
                ),
              ),
            ),
        const SizedBox(height: 12),
        Text('Start a cutting', style: Theme.of(context).textTheme.titleMedium),
        _field(
          _cuttingName,
          'Unique cutting name',
          action: TextInputAction.next,
        ),
        _field(_method, 'Method', action: TextInputAction.next),
        _field(_medium, 'Medium (optional)', action: TextInputAction.next),
        _field(
          _location,
          'Location text (optional)',
          action: TextInputAction.next,
        ),
        _field(
          _tags,
          'Tags, comma separated (optional)',
          action: TextInputAction.next,
        ),
        _field(_initialNote, 'Initial observation (optional)', maxLines: 3),
        OutlinedButton.icon(
          onPressed: _saving ? null : _pickStartDate,
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text('Start date: ${_date(_startedAt)}'),
        ),
        OutlinedButton.icon(
          onPressed: _saving
              ? null
              : () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Photos are optional and will be available in a later update.',
                    ),
                  ),
                ),
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Add photo (optional)'),
        ),
        FilledButton(
          key: const ValueKey<String>('start-cutting'),
          onPressed: _saving ? null : _createCutting,
          child: const Text('Start cutting'),
        ),
      ],
    );
  }

  Widget _timelineSection() {
    final cutting = _cutting!;
    DerivedCuttingState? state;
    try {
      state = deriveCuttingState(_events);
    } on StateError {
      state = null;
    }
    final superseded = _events
        .map((event) => event.correctsEventId)
        .whereType<EntityId>()
        .toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '${cutting.name} timeline',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          state == null
              ? 'History needs review'
              : 'Stage: ${_label(state.stage.name)} • Outcome: ${_label(state.outcome.name)}',
        ),
        const SizedBox(height: 12),
        if (_events.isEmpty)
          const Text('No timeline events yet.')
        else
          for (final event in _events)
            Card(
              child: ListTile(
                leading: Icon(
                  _eventIcon(event),
                  semanticLabel: _eventTitle(event),
                ),
                title: Text(_eventTitle(event)),
                subtitle: Text(
                  '${_dateTime(event.occurredAtUtc)}${event.note.isEmpty ? '' : '\n${event.note}'}${superseded.contains(event.id) ? '\nCorrected — retained for history' : ''}',
                ),
                isThreeLine:
                    event.note.isNotEmpty || superseded.contains(event.id),
                trailing:
                    superseded.contains(event.id) ||
                        event.correctsEventId != null
                    ? null
                    : IconButton(
                        tooltip: 'Correct ${_eventTitle(event).toLowerCase()}',
                        onPressed: _saving ? null : () => _correct(event),
                        icon: const Icon(Icons.edit_note_outlined),
                      ),
              ),
            ),
        if (state?.outcome == CuttingOutcome.active) ...<Widget>[
          const SizedBox(height: 12),
          _field(_eventNote, 'New observation', maxLines: 3),
          FilledButton.icon(
            key: const ValueKey<String>('add-observation'),
            onPressed: _saving ? null : _addObservation,
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('Add observation'),
          ),
          MenuAnchor(
            builder: (context, controller, child) => OutlinedButton.icon(
              key: const ValueKey<String>('record-outcome'),
              onPressed: _saving ? null : controller.open,
              icon: const Icon(Icons.timeline_outlined),
              label: const Text('Record stage change'),
            ),
            menuChildren: CuttingStage.values
                .where(
                  (stage) => state == null || stage.index >= state.stage.index,
                )
                .map(
                  (stage) => MenuItemButton(
                    onPressed: () => _changeStage(stage),
                    child: Text(_label(stage.name)),
                  ),
                )
                .toList(),
          ),
          MenuAnchor(
            builder: (context, controller, child) => OutlinedButton.icon(
              onPressed: _saving ? null : controller.open,
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Record outcome'),
            ),
            menuChildren: CuttingOutcome.values
                .where((outcome) => outcome != CuttingOutcome.active)
                .map(
                  (outcome) => MenuItemButton(
                    onPressed: () => _recordOutcome(outcome),
                    child: Text(_label(outcome.name)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _reminderSection(cutting),
        ],
        const SizedBox(height: 12),
        _siblingSection(cutting),
      ],
    );
  }

  Widget _reviewSection() {
    final tags =
        _cuttingsForFilters.expand((cutting) => cutting.tags).toSet().toList()
          ..sort();
    return ExpansionTile(
      key: const ValueKey<String>('review-section'),
      initiallyExpanded: false,
      title: const Text('Review active cuttings'),
      subtitle: Text('${_reviewItems.length} matching, due first'),
      children: <Widget>[
        _field(_search, 'Search names, parent, method, place, or tag'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _filterDropdown<EntityId>(
              label: 'Parent',
              value: _reviewParent,
              values: _parents.map((parent) => parent.id),
              name: (id) => _parents.firstWhere((p) => p.id == id).nickname,
              onChanged: (value) => _setFilter(() => _reviewParent = value),
            ),
            _filterDropdown<CuttingStage>(
              label: 'Stage',
              value: _reviewStage,
              values: CuttingStage.values,
              name: (value) => _label(value.name),
              onChanged: (value) => _setFilter(() => _reviewStage = value),
            ),
            _filterDropdown<CuttingOutcome>(
              label: 'Outcome',
              value: _reviewOutcome,
              values: CuttingOutcome.values,
              name: (value) => _label(value.name),
              onChanged: (value) => _setFilter(() => _reviewOutcome = value),
            ),
            _filterDropdown<String>(
              label: 'Tag',
              value: _reviewTag,
              values: tags,
              name: (value) => value,
              onChanged: (value) => _setFilter(() => _reviewTag = value),
            ),
            DropdownButton<DueFilter>(
              value: _dueFilter,
              items: DueFilter.values
                  .map(
                    (value) => DropdownMenuItem<DueFilter>(
                      value: value,
                      child: Text('Due: ${_label(value.name)}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) _setFilter(() => _dueFilter = value);
              },
            ),
            FilterChip(
              label: const Text('Active in last 7 days'),
              selected: _recentOnly,
              onSelected: (value) => _setFilter(() => _recentOnly = value),
            ),
            OutlinedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.search),
              label: const Text('Apply search'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_reviewItems.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No active cuttings match these filters.'),
          )
        else
          for (final item in _reviewItems)
            Card(
              child: ListTile(
                title: Text(item.cutting.name),
                subtitle: Text(
                  '${item.parent.nickname} • ${_label(item.state.stage.name)} • ${_label(item.state.outcome.name)}\n'
                  '${item.pendingReminder == null ? 'No check-in due' : 'Check-in ${_dueLabel(item.pendingReminder!)}'} • Last activity ${_date(item.lastActivityUtc)}',
                ),
                isThreeLine: true,
                leading: Icon(
                  item.pendingReminder != null &&
                          !item.pendingReminder!.scheduledForUtc.isAfter(
                            DateTime.now().toUtc(),
                          )
                      ? Icons.notification_important_outlined
                      : Icons.eco_outlined,
                  semanticLabel: item.pendingReminder == null
                      ? 'No check-in due'
                      : _dueLabel(item.pendingReminder!),
                ),
                onTap: () => _reload(
                  selectParent: item.parent.id,
                  selectCutting: item.cutting.id,
                ),
              ),
            ),
      ],
    );
  }

  List<Cutting> get _cuttingsForFilters =>
      _reviewItems.map((item) => item.cutting).followedBy(_cuttings).toList();

  Widget _filterDropdown<T>({
    required String label,
    required T? value,
    required Iterable<T> values,
    required String Function(T) name,
    required ValueChanged<T?> onChanged,
  }) => DropdownButton<T?>(
    value: value,
    items: <DropdownMenuItem<T?>>[
      DropdownMenuItem<T?>(value: null, child: Text('$label: Any')),
      ...values.map(
        (item) => DropdownMenuItem<T?>(
          value: item,
          child: Text('$label: ${name(item)}'),
        ),
      ),
    ],
    onChanged: onChanged,
  );

  void _setFilter(VoidCallback update) {
    setState(update);
    _reload();
  }

  Widget _reminderSection(Cutting cutting) {
    final pending = _reminders
        .where((reminder) => reminder.status == ReminderStatus.pending)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Check-ins', style: Theme.of(context).textTheme.titleMedium),
        const Text(
          'Check-ins stay in this in-app due list even if notifications are denied or revoked.',
        ),
        if (pending.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No pending check-ins.'),
          )
        else
          for (final reminder in pending)
            Card(
              child: ListTile(
                title: Text(_dueLabel(reminder)),
                subtitle: Text(
                  '${_wallDateTime(ReminderWorkflow.wallClockFor(reminder.scheduledForUtc, reminder.timeZoneId))} (${reminder.timeZoneId})${reminder.platformNotificationId == null ? '\nIn-app only; notifications unavailable' : ''}',
                ),
                isThreeLine: reminder.platformNotificationId == null,
                trailing: PopupMenuButton<String>(
                  tooltip: 'Actions for check-in',
                  onSelected: (action) => _reminderAction(action, reminder),
                  itemBuilder: (context) => const <PopupMenuEntry<String>>[
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'complete', child: Text('Complete')),
                    PopupMenuItem(value: 'snooze', child: Text('Snooze 1 day')),
                    PopupMenuItem(value: 'remove', child: Text('Remove')),
                  ],
                ),
              ),
            ),
        FilledButton.icon(
          key: const ValueKey<String>('add-check-in'),
          onPressed: _saving ? null : () => _editReminder(cutting),
          icon: const Icon(Icons.add_alert_outlined),
          label: const Text('Add check-in'),
        ),
      ],
    );
  }

  Widget _siblingSection(Cutting selected) => ExpansionTile(
    title: const Text('Sibling timeline summary'),
    subtitle: const Text('Recorded dates, stages, and outcomes only'),
    children: _siblings
        .map(
          (summary) => ListTile(
            selected: summary.cutting.id == selected.id,
            title: Text(summary.cutting.name),
            subtitle: Text(
              'Started ${_date(summary.cutting.startedAtUtc)} • ${_label(summary.state.stage.name)} • ${_label(summary.state.outcome.name)} • ${summary.events.length} events',
            ),
            onTap: () => _reload(
              selectParent: summary.cutting.parentId,
              selectCutting: summary.cutting.id,
            ),
          ),
        )
        .toList(),
  );

  Future<void> _reminderAction(String action, Reminder reminder) async {
    final workflow = ReminderWorkflow(_repository!, widget.notificationGateway);
    switch (action) {
      case 'edit':
        await _editReminder(_cutting!, existing: reminder);
        return;
      case 'complete':
        await _run(
          () => workflow.complete(reminder),
          selectParent: _cutting!.parentId,
          selectCutting: _cutting!.id,
        );
      case 'snooze':
        await _run(
          () => workflow.snooze(reminder, const Duration(days: 1)),
          selectParent: _cutting!.parentId,
          selectCutting: _cutting!.id,
        );
      case 'remove':
        await _run(
          () => workflow.remove(reminder),
          selectParent: _cutting!.parentId,
          selectCutting: _cutting!.id,
        );
    }
  }

  Future<void> _editReminder(Cutting cutting, {Reminder? existing}) async {
    var zone = existing?.timeZoneId ?? 'UTC';
    var selected = existing == null
        ? DateTime.now().toUtc().add(const Duration(days: 1))
        : ReminderWorkflow.wallClockFor(existing.scheduledForUtc, zone);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add check-in' : 'Edit check-in'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Wall-clock time: ${_wallDateTime(selected)}'),
              OutlinedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selected,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setDialogState(
                      () => selected = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        selected.hour,
                        selected.minute,
                      ),
                    );
                  }
                },
                child: const Text('Choose date'),
              ),
              OutlinedButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selected),
                  );
                  if (time != null) {
                    setDialogState(
                      () => selected = DateTime(
                        selected.year,
                        selected.month,
                        selected.day,
                        time.hour,
                        time.minute,
                      ),
                    );
                  }
                },
                child: const Text('Choose time'),
              ),
              DropdownButtonFormField<String>(
                initialValue: zone,
                decoration: const InputDecoration(labelText: 'Timezone'),
                items:
                    const <String>[
                          'UTC',
                          'America/Los_Angeles',
                          'America/New_York',
                          'Europe/London',
                          'Australia/Sydney',
                        ]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                onChanged: (value) =>
                    setDialogState(() => zone = value ?? zone),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true || !mounted) return;
    final scheduled = ReminderWorkflow.resolveWallClock(
      year: selected.year,
      month: selected.month,
      day: selected.day,
      hour: selected.hour,
      minute: selected.minute,
      timeZoneId: zone,
    );
    final workflow = ReminderWorkflow(_repository!, widget.notificationGateway);
    ReminderResult? result;
    final saved = await _run(
      () async {
        if (existing == null) {
          result = await workflow.create(
            cuttingId: cutting.id,
            scheduledForUtc: scheduled,
            timeZoneId: zone,
          );
        } else {
          await workflow.edit(existing, scheduled, zone);
        }
      },
      selectParent: cutting.parentId,
      selectCutting: cutting.id,
    );
    if (saved && result?.notificationsEnabled == false && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification permission was not granted. Your check-in remains available in the app.',
          ),
        ),
      );
    }
  }

  String _dueLabel(Reminder reminder) {
    final now = DateTime.now().toUtc();
    if (reminder.scheduledForUtc.isBefore(now)) return 'Overdue check-in';
    return 'Upcoming check-in';
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputAction? action,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: action,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  Widget _overview(StartupPolicy policy) => Column(
    children: <Widget>[
      _StatusTile(
        label: 'Parent plants',
        value: widget.overview.parentPlantCount.toString(),
      ),
      _StatusTile(
        label: 'Active cuttings',
        value: widget.overview.activeCuttingCount.toString(),
      ),
      _StatusTile(
        label: 'Offline and account-free',
        value: policy.requiresNetwork || policy.requiresAccount
            ? 'Unavailable'
            : 'Ready',
      ),
    ],
  );

  IconData _eventIcon(CuttingEvent event) => switch (event.kind) {
    CuttingEventKind.observation => Icons.notes,
    CuttingEventKind.stage => Icons.timeline,
    CuttingEventKind.outcome => Icons.flag,
  };

  String _eventTitle(CuttingEvent event) => switch (event.kind) {
    CuttingEventKind.observation => 'Observation',
    CuttingEventKind.stage => 'Stage: ${_label(event.stage!.name)}',
    CuttingEventKind.outcome => 'Outcome: ${_label(event.outcome!.name)}',
  };

  String _label(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';

  String _date(DateTime value) =>
      value.toLocal().toIso8601String().substring(0, 10);

  String _dateTime(DateTime value) =>
      value.toLocal().toIso8601String().replaceFirst('T', ' ').substring(0, 16);

  String _wallDateTime(DateTime value) =>
      value.toIso8601String().replaceFirst('T', ' ').substring(0, 16);
}

final class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    excludeSemantics: true,
    child: ListTile(title: Text(label), trailing: Text(value)),
  );
}
