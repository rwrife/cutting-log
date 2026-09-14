import 'package:flutter/material.dart';

/// Detailed in-app instructions, linked from the explainer card on the home
/// screen. The guide is shipped inside the app so it stays readable offline —
/// consistent with the local-first promise — and never depends on a network
/// request or an external site being reachable.
final class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('How to use Cutting Log')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Text(
              'Cutting Log is a private observation journal for plant '
              'propagation. You record what you see over time; the app keeps '
              'the dates, lineage, and photos organized for you.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text('Basic flow', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const _StepRow(
              step: '1',
              text:
                  'Create a parent plant: the mature plant you take '
                  'cuttings from. Give it a nickname and optionally pick a '
                  'plant icon so you can spot it in the list.',
            ),
            const _StepRow(
              step: '2',
              text:
                  'Start a cutting from that parent. The name is '
                  'pre-filled for you, and method and medium are dropdowns '
                  'with the most common choices, so you can usually just tap '
                  'Start cutting.',
            ),
            const _StepRow(
              step: '3',
              text:
                  'Log observations whenever you check on it: new roots, a '
                  'leaf unfurling, or anything you just want to remember. '
                  'You can also record stage changes and a final outcome.',
            ),
            const _StepRow(
              step: '4',
              text:
                  'Optionally attach photos to the latest event. Camera '
                  'and photo permissions are only asked for when you try '
                  'this, and saying no changes nothing else.',
            ),
            const _StepRow(
              step: '5',
              text:
                  'Add a check-in reminder if you want a nudge. Without '
                  'notification permission, check-ins still appear in the '
                  'in-app due list.',
            ),
            const _StepRow(
              step: '6',
              text:
                  'Use "Review active cuttings" to search and filter '
                  'everything at once, due check-ins first. Sibling '
                  'summaries show how cuttings from the same parent are '
                  'doing side by side.',
            ),
            const _StepRow(
              step: '7',
              text:
                  'Advanced data tools (the tools icon at the top) hold '
                  'backups: create a local ZIP + CSV export, preview and '
                  'apply a restore, review local media storage, or delete '
                  'the whole local library. Nothing is ever uploaded '
                  'automatically.',
            ),
            const SizedBox(height: 24),
            Text('Privacy', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Everything stays in this app\'s private storage on this '
              'device. There is no account, no network requirement, no '
              'analytics, and no automatic upload of any kind. Export and '
              'sharing are always user-initiated from Advanced data tools.',
            ),
            const SizedBox(height: 24),
            Text(
              'What Cutting Log does not do',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'It records your observations. It does not diagnose plants, '
              'prescribe treatment, recommend pesticides, assess toxicity or '
              'food safety, or predict propagation success.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

final class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.text});

  final String step;
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Step $step',
    child: Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Text(
              step,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    ),
  );
}
