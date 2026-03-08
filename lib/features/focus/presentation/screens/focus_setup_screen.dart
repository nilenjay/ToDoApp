import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/focus_model.dart';
import '../bloc/focus_bloc/focus_bloc.dart';
import '../bloc/focus_bloc/focus_event.dart';


class FocusSetupScreen extends StatefulWidget {
  const FocusSetupScreen({super.key});

  @override
  State<FocusSetupScreen> createState() => _FocusSetupScreenState();
}

class _FocusSetupScreenState extends State<FocusSetupScreen> {
  final _nameController = TextEditingController(text: 'Focus Session');
  int _durationMinutes = 50;
  FocusType _selectedType = FocusType.deepWork;

  static const List<int> _durations = [15, 25, 30, 45, 50, 60, 90, 120];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breaks = calculateBreaks(_durationMinutes, _selectedType);

    return Scaffold(
      appBar: AppBar(title: const Text('Focus Session')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Session Name ────────────────────────────────────────────────
          Text('Session Name', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. Chapter 5 Review',
            ),
          ),

          const SizedBox(height: 28),

          // ── Focus Type ──────────────────────────────────────────────────
          Text('Focus Type', style: theme.textTheme.labelLarge),
          const SizedBox(height: 12),
          Row(
            children: FocusType.values.map((type) {
              final selected = _selectedType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(type.emoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          type.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: selected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // ── Duration ────────────────────────────────────────────────────
          Text('Duration', style: theme.textTheme.labelLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _durations.map((min) {
              final selected = _durationMinutes == min;
              return ChoiceChip(
                label: Text('${min}m'),
                selected: selected,
                onSelected: (_) => setState(() => _durationMinutes = min),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // ── Break Preview ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⏱', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text('Scheduled Breaks',
                        style: theme.textTheme.labelLarge),
                  ],
                ),
                const SizedBox(height: 10),
                if (breaks.isEmpty)
                  Text(
                    'No breaks — session is under 30 minutes.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  ...breaks.asMap().entries.map((e) {
                    final i = e.key;
                    final b = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Break ${i + 1}: after ${b.afterMinutes}m → ${b.breakMinutes}m rest',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Start Button ────────────────────────────────────────────────
          FilledButton(
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isEmpty) return;
              context.read<FocusBloc>().add(StartSession(
                sessionName: name,
                durationMinutes: _durationMinutes,
                focusType: _selectedType,
              ));
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Start Session',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}