import 'dart:io';

import 'package:cutting_log/src/application/media_workflow.dart';
import 'package:cutting_log/src/application/portability_workflow.dart';
import 'package:cutting_log/src/data/app_private_media_store.dart';
import 'package:flutter/material.dart';

/// Low-frequency, high-impact data tools: local backup export, archive
/// restore (preview then apply), local media storage review/cleanup, and
/// full-library deletion. These live behind an explicit navigation step so
/// the everyday journaling flow on the home screen stays focused, while
/// every destructive or security-sensitive action remains reachable,
/// labeled, and confirmed in place.
final class AdvancedToolsPage extends StatefulWidget {
  const AdvancedToolsPage({
    required this.portabilityWorkflow,
    this.mediaWorkflow,
    required this.onLibraryChanged,
    super.key,
  });

  final PortabilityWorkflow? portabilityWorkflow;
  final MediaWorkflow? mediaWorkflow;

  /// Called after any mutation (export, restore, media cleanup, erase) so
  /// the home screen can reload its views.
  final VoidCallback onLibraryChanged;

  @override
  State<AdvancedToolsPage> createState() => _AdvancedToolsPageState();
}

final class _AdvancedToolsPageState extends State<AdvancedToolsPage> {
  final _restoreArchivePath = TextEditingController();

  RestorePreview? _restorePreview;
  RestoreConflictPolicy _restorePolicy = RestoreConflictPolicy.keepExisting;
  String? _latestExportPath;
  MediaStorageReport? _mediaReport;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshMediaReport();
  }

  @override
  void dispose() {
    _restoreArchivePath.dispose();
    super.dispose();
  }

  Future<bool> _run(
    Future<void> Function() action, {
    bool notifyLibrary = true,
  }) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return false;
      setState(() => _busy = false);
      if (notifyLibrary) widget.onLibraryChanged();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      setState(() {
        _busy = false;
        _error = _message(error);
      });
      return false;
    }
  }

  String _message(
    Object error, {
    String fallback = 'Could not complete the action.',
  }) {
    if (error is PortabilityException) return error.message;
    if (error is MediaImportException) return error.message;
    if (error is StateError) return error.message;
    return fallback;
  }

  Future<void> _refreshMediaReport() async {
    final workflow = widget.mediaWorkflow;
    if (workflow == null) return;
    try {
      final report = await workflow.inspectStorage();
      if (!mounted) return;
      setState(() => _mediaReport = report);
    } on Object {
      // Media inspection is informational; never block the data tools.
    }
  }

  Future<void> _exportLocalBackup() async {
    final workflow = widget.portabilityWorkflow;
    if (workflow == null) return;

    PortabilityExportResult? result;
    final saved = await _run(() async {
      result = await workflow.exportLibrary(includeMedia: true);
    }, notifyLibrary: false);
    if (!saved || !mounted || result == null) return;

    setState(() {
      _latestExportPath = result!.archiveFile.path;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved backup ZIP and CSV exports to app-private storage at ${result!.archiveFile.path}.',
        ),
      ),
    );
  }

  Future<void> _previewRestore() async {
    final workflow = widget.portabilityWorkflow;
    if (workflow == null) return;
    final archivePath = _restoreArchivePath.text.trim();
    if (archivePath.isEmpty) {
      setState(() {
        _error = 'Enter a local backup ZIP path before previewing restore.';
      });
      return;
    }

    RestorePreview? preview;
    final saved = await _run(() async {
      preview = await workflow.previewRestoreArchive(File(archivePath));
    }, notifyLibrary: false);
    if (!saved || !mounted || preview == null) return;
    setState(() {
      _restorePreview = preview;
    });
  }

  Future<void> _applyRestore() async {
    final workflow = widget.portabilityWorkflow;
    final preview = _restorePreview;
    if (workflow == null || preview == null) {
      setState(() {
        _error = 'Preview a restore archive first so additions/conflicts can be reviewed.';
      });
      return;
    }

    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply restore?'),
        content: Text(
          'Policy: ${_restorePolicy.name}. '
          'Additions: ${preview.totalAdditions}. Conflicts: ${preview.totalConflicts}.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply restore'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;

    RestoreApplyResult? result;
    final saved = await _run(() async {
      result = await workflow.applyRestorePreview(
        preview: preview,
        conflictPolicy: _restorePolicy,
      );
    });
    if (!saved || !mounted || result == null) return;

    setState(() {
      _restorePreview = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Restore complete: ${result!.appliedParents} parents, '
          '${result!.appliedCuttings} cuttings, ${result!.appliedEvents} events, '
          '${result!.appliedMediaAssets} media assets, ${result!.appliedReminders} reminders.',
        ),
      ),
    );
  }

  Future<void> _clearAllLocalMedia() async {
    final workflow = widget.mediaWorkflow;
    if (workflow == null) return;
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove all local media?'),
        content: const Text(
          'This deletes all locally stored photo files and media references from this device.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove all'),
          ),
        ],
      ),
    );
    if (approved != true) return;
    await _run(() => workflow.clearAllLocalMedia());
    await _refreshMediaReport();
  }

  Future<void> _eraseLibrary() async {
    final workflow = widget.portabilityWorkflow;
    if (workflow == null) return;

    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete full local library?'),
        content: const Text(
          'This erases local database records, copied media files, reminder links, and temporary cache data. '
          'Some OS-level backups created outside this app may still exist until removed by the user.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete local library'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;

    EraseLibraryResult? result;
    final saved = await _run(() async {
      result = await workflow.eraseLibrary();
    });
    if (!saved || !mounted || result == null) return;

    setState(() {
      _restorePreview = null;
      _latestExportPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deleted ${result!.parentsDeleted} parents, ${result!.cuttingsDeleted} cuttings, '
          '${result!.eventsDeleted} events, ${result!.mediaAssetsDeleted} media assets, '
          '${result!.remindersDeleted} reminders and ${result!.mediaFilesDeleted} media files.',
        ),
      ),
    );
    await _refreshMediaReport();
  }

  @override
  Widget build(BuildContext context) {
    final workflowAvailable = widget.portabilityWorkflow != null;
    final preview = _restorePreview;
    final potentialSkips = preview == null
        ? 0
        : preview.parents.potentialSkips +
              preview.cuttings.potentialSkips +
              preview.events.potentialSkips +
              preview.mediaAssets.potentialSkips +
              preview.reminders.potentialSkips;
    final report = _mediaReport;

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced data tools')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            if (_error != null) _errorPanel(),
            Text(
              'Your data, always user-owned',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Backups can contain sensitive notes and photos. Cutting Log never uploads backups automatically; sharing/export is always user-initiated.',
            ),
            const SizedBox(height: 24),
            if (!workflowAvailable)
              const Text(
                'Portability controls are unavailable in this runtime.',
              )
            else ...<Widget>[
              FilledButton.icon(
                key: const ValueKey<String>('export-backup'),
                onPressed: _busy ? null : _exportLocalBackup,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Create local backup (ZIP + CSV)'),
              ),
              if (_latestExportPath != null) ...<Widget>[
                const SizedBox(height: 8),
                SelectableText('Latest export: $_latestExportPath'),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _restoreArchivePath,
                enabled: !_busy,
                decoration: const InputDecoration(
                  labelText: 'Restore archive path (.zip)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RestoreConflictPolicy>(
                initialValue: _restorePolicy,
                decoration: const InputDecoration(
                  labelText: 'Conflict policy',
                  border: OutlineInputBorder(),
                ),
                items: RestoreConflictPolicy.values
                    .map(
                      (value) => DropdownMenuItem<RestoreConflictPolicy>(
                        value: value,
                        child: Text(value.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _busy
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _restorePolicy = value);
                      },
              ),
              if (preview != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  'Restore preview — additions: ${preview.totalAdditions}, conflicts: ${preview.totalConflicts}, potential skips: $potentialSkips.',
                ),
                Text(
                  'Parents +${preview.parents.additions}/${preview.parents.conflicts} conflicts · '
                  'Cuttings +${preview.cuttings.additions}/${preview.cuttings.conflicts} · '
                  'Events +${preview.events.additions}/${preview.events.conflicts} · '
                  'Media +${preview.mediaAssets.additions}/${preview.mediaAssets.conflicts} · '
                  'Reminders +${preview.reminders.additions}/${preview.reminders.conflicts}',
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  OutlinedButton.icon(
                    key: const ValueKey<String>('preview-restore'),
                    onPressed: _busy ? null : _previewRestore,
                    icon: const Icon(Icons.preview_outlined),
                    label: const Text('Preview restore'),
                  ),
                  FilledButton.icon(
                    key: const ValueKey<String>('apply-restore'),
                    onPressed: _busy || preview == null ? null : _applyRestore,
                    icon: const Icon(Icons.system_update_alt_outlined),
                    label: const Text('Apply restore'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Restore hardening: archive paths are validated (no absolute/traversal/symlink entries), size limits guard decompression bombs, and record/hash validation happens before mutation.',
              ),
            ],
            if (widget.mediaWorkflow != null) ...<Widget>[
              const SizedBox(height: 24),
              Text(
                'Local media storage',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (report == null)
                const Text('Media storage summary is unavailable.')
              else ...<Widget>[
                Text(
                  'Local media: ${report.assetCount} assets • ${report.trackedBytes} bytes',
                ),
                if (report.missingReferences.isNotEmpty)
                  Text('Missing files: ${report.missingReferences.length}'),
                if (report.orphanedFiles.isNotEmpty)
                  Text('Orphan files: ${report.orphanedFiles.length}'),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const ValueKey<String>('clear-all-media'),
                onPressed: _busy ? null : _clearAllLocalMedia,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Remove all local media'),
              ),
            ],
            const SizedBox(height: 24),
            if (workflowAvailable)
              OutlinedButton.icon(
                key: const ValueKey<String>('erase-library'),
                onPressed: _busy ? null : _eraseLibrary,
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Delete full local library'),
              ),
            const SizedBox(height: 12),
            const Text(
              'Platform note: deleting local data cannot retroactively remove copies that may already exist in external OS/cloud backups.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _errorPanel() => Semantics(
    liveRegion: true,
    child: MaterialBanner(
      content: Text(_error!),
      actions: <Widget>[
        TextButton(
          onPressed: () => setState(() => _error = null),
          child: const Text('Dismiss'),
        ),
      ],
    ),
  );
}
