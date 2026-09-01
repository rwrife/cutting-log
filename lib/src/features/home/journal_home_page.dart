import 'package:cutting_log/src/domain/journal_overview.dart';
import 'package:cutting_log/src/domain/startup_policy.dart';
import 'package:flutter/material.dart';

final class JournalHomePage extends StatelessWidget {
  const JournalHomePage({required this.overview, super.key});

  final JournalOverview overview;

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
            _StatusTile(
              icon: Icons.eco_outlined,
              label: 'Parent plants',
              value: overview.parentPlantCount.toString(),
            ),
            _StatusTile(
              icon: Icons.content_cut,
              label: 'Active cuttings',
              value: overview.activeCuttingCount.toString(),
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
