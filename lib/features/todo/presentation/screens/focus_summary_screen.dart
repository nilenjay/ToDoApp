import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/focus_model.dart';
import '../bloc/focus_bloc/focus_bloc.dart';
import '../bloc/focus_bloc/focus_event.dart';
import '../bloc/focus_bloc/focus_state.dart';

class FocusSummaryScreen extends StatelessWidget {
  final FocusCompleted state;
  const FocusSummaryScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = state.session;
    final completionPct =
    (session.actualFocusMinutes / session.plannedMinutes).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Summary'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Completion card ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  completionPct >= 1.0 ? '🎉' : '⏹',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 12),
                Text(
                  session.sessionName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.focusType.emoji} ${session.focusType.label}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                    theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: completionPct,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor:
                  theme.colorScheme.onPrimaryContainer.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(completionPct * 100).round()}% completed',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Stats ───────────────────────────────────────────────────────
          Row(
            children: [
              _StatCard(
                  label: 'Planned',
                  value: '${session.plannedMinutes}m',
                  icon: Icons.schedule),
              const SizedBox(width: 12),
              _StatCard(
                  label: 'Focused',
                  value: '${session.actualFocusMinutes}m',
                  icon: Icons.bolt),
              const SizedBox(width: 12),
              _StatCard(
                  label: 'Breaks',
                  value: '${session.breaksCompleted}',
                  icon: Icons.coffee),
            ],
          ),

          const SizedBox(height: 28),

          // ── Rating ──────────────────────────────────────────────────────
          Text('Rate this session', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          BlocBuilder<FocusBloc, FocusState>(
            builder: (context, s) {
              final rating =
              s is FocusCompleted ? s.session.rating : session.rating;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () =>
                        context.read<FocusBloc>().add(RateSession(rating: i + 1)),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: 32),

          // ── New Session ─────────────────────────────────────────────────
          FilledButton(
            onPressed: () =>
                context.read<FocusBloc>().add(const ResetSession()),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'New Session',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}