import 'package:cutting_log/src/application/capture_workflow.dart';
import 'package:cutting_log/src/domain/journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:cutting_log/src/domain/journal_overview.dart';
import 'package:cutting_log/src/domain/startup_policy.dart';
import 'package:flutter/material.dart';

final class JournalHomePage extends StatefulWidget {
  const JournalHomePage({
    required this.overview,
    this.dataRepository,
    super.key,
  });

  final JournalOverview overview;
  final JournalDataRepository? dataRepository;

  @override
  State<JournalHomePage> createState() => _JournalHomePageState();
}

final class _JournalHomePageState extends State<JournalHomePage> {
  final _parentName = TextEditingController();
  final _cuttingName = TextEditingController();
  final _method = TextEditingController(text: 'Stem');
  final _note = TextEditingController();
  ParentPlant? _parent;
  Cutting? _cutting;
  String? _error;

  @override
  void dispose() {
    _parentName.dispose();
    _cuttingName.dispose();
    _method.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _createParent() async {
    final repository = widget.dataRepository;
    if (repository == null) return;
    try {
      final parent = await CaptureWorkflow(repository)
          .createParent(nickname: _parentName.text);
      setState(() {
        _parent = parent;
        _error = null;
      });
    } on ArgumentError catch (error) {
      setState(
        () => _error = error.message?.toString() ?? 'Check the parent name.',
      );
    } on JournalRepositoryException catch (error) {
      setState(() => _error = error.message);
    }
  }

  Future<void> _createCutting() async {
    final repository = widget.dataRepository;
    final parent = _parent;
    if (repository == null || parent == null) return;
    try {
      final cutting = await CaptureWorkflow(repository).startCutting(
        parentId: parent.id,
        name: _cuttingName.text,
        method: _method.text,
        startedAtUtc: DateTime.now().toUtc(),
        initialNote: _note.text,
      );
      setState(() {
        _cutting = cutting;
        _error = null;
      });
    } on ArgumentError catch (error) {
      setState(
        () =>
            _error = error.message?.toString() ?? 'Check the cutting details.',
      );
    } on JournalRepositoryException catch (error) {
      setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    const policy = StartupPolicy();

    return Scaffold(
      appBar: AppBar(title: const Text('Cutting Log')),
      body: SafeArea(
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
            const SizedBox(height: 12),
            const Text(
              'Your useful core stays on this device. No account or optional '
              'permission is needed to open the journal.',
            ),
            const SizedBox(height: 24),
            if (widget.dataRepository != null) ...<Widget>[
              Text(
                'Capture a record',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (_parent == null) ...<Widget>[
                TextField(
                  controller: _parentName,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Parent plant nickname',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _createParent,
                  child: const Text('Create parent plant'),
                ),
              ] else if (_cutting == null) ...<Widget>[
                Text('Selected parent: ${_parent!.nickname}'),
                const SizedBox(height: 8),
                TextField(
                  controller: _cuttingName,
                  decoration: const InputDecoration(
                    labelText: 'Unique cutting name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _method,
                  decoration: const InputDecoration(
                    labelText: 'Method',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Initial observation (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _createCutting,
                  child: const Text('Start cutting'),
                ),
              ] else
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'Cutting ${_cutting!.name} was saved. Add observations and stage changes in the next journal update.',
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
            _StatusTile(
              icon: Icons.eco_outlined,
              label: 'Parent plants',
              value: widget.overview.parentPlantCount.toString(),
            ),
            _StatusTile(
              icon: Icons.content_cut,
              label: 'Active cuttings',
              value: widget.overview.activeCuttingCount.toString(),
            ),
            _StatusTile(
              icon: Icons.cloud_off_outlined,
              label: 'Offline and account-free',
              value: policy.requiresNetwork || policy.requiresAccount
                  ? 'Unavailable'
                  : 'Ready',
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Cutting Log records your observations. It does not diagnose '
                  'plants, prescribe treatment, or predict propagation success.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(value),
      ),
    );
  }
}
