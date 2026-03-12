import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/focus/data/models/focus_model.dart';
import 'package:todo_app/features/focus/presentation/bloc/focus_bloc/focus_bloc.dart';
import 'package:todo_app/features/focus/presentation/bloc/focus_bloc/focus_event.dart';
import 'app_theme.dart';

class FocusSetupScreen extends StatefulWidget {
  const FocusSetupScreen({super.key});

  @override
  State<FocusSetupScreen> createState() => _FocusSetupScreenState();
}

class _FocusSetupScreenState extends State<FocusSetupScreen> {
  final _nameController =
  TextEditingController(text: 'Focus Session');
  int _durationMinutes = 50;
  FocusType _selectedType = FocusType.deepWork;

  static const List<int> _durations = [
    15, 25, 30, 45, 50, 60, 90, 120
  ];

  static const _typeConfig = {
    FocusType.study: (
    emoji: '📚',
    label: 'Study',
    color: Color(0xFF60A5FA), // blue-400
    ),
    FocusType.deepWork: (
    emoji: '💼',
    label: 'Deep Work',
    color: Color(0xFF818CF8), // indigo-400
    ),
    FocusType.creative: (
    emoji: '🎨',
    label: 'Creative',
    color: Color(0xFFA78BFA), // violet-400
    ),
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breaks =
    calculateBreaks(_durationMinutes, _selectedType);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Focus Session',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + kToolbarHeight + 8,
            20,
            kBottomNavigationBarHeight +
                MediaQuery.of(context).padding.bottom +
                24,
          ),
          children: [
            // ── Session name ────────────────────────────────────────
            _sectionLabel('Session Name'),
            const SizedBox(height: 8),
            Container(
              decoration: AppTheme.glassCard(radius: 14),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'e.g. Chapter 5 Review',
                  hintStyle: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 14),
                  prefixIcon: const Icon(Icons.edit_outlined,
                      color: AppTheme.textMuted, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Focus type ──────────────────────────────────────────
            _sectionLabel('Focus Type'),
            const SizedBox(height: 12),
            Row(
              children: FocusType.values.map((type) {
                final cfg = _typeConfig[type]!;
                final selected = _selectedType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: FocusType.values.last == type
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? cfg.color.withOpacity(0.18)
                            : AppTheme.glassFill,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? cfg.color.withOpacity(0.6)
                              : AppTheme.glassBorder,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(cfg.emoji,
                              style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 6),
                          Text(
                            cfg.label,
                            style: TextStyle(
                              color: selected
                                  ? cfg.color
                                  : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
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

            // ── Duration ────────────────────────────────────────────
            _sectionLabel('Duration'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _durations.map((min) {
                final selected = _durationMinutes == min;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _durationMinutes = min),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.accent.withOpacity(0.2)
                          : AppTheme.glassFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppTheme.accent
                            : AppTheme.glassBorder,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      '${min}m',
                      style: TextStyle(
                        color: selected
                            ? AppTheme.accent
                            : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ── Break preview ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCard(radius: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('⏱',
                          style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      const Text(
                        'Scheduled Breaks',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGlow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${breaks.length}',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (breaks.isEmpty)
                    const Text(
                      'No breaks — session under 30 minutes.',
                      style: TextStyle(
                          color: AppTheme.textMuted, fontSize: 13),
                    )
                  else
                    ...breaks.asMap().entries.map((e) {
                      final i = e.key;
                      final b = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Break ${i + 1}:  after ${b.afterMinutes}m  →  ${b.breakMinutes}m rest',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Start button ────────────────────────────────────────
            GestureDetector(
              onTap: () {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;
                context.read<FocusBloc>().add(StartSession(
                  sessionName: name,
                  durationMinutes: _durationMinutes,
                  focusType: _selectedType,
                ));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Start Session',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: AppTheme.textMuted,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    ),
  );
}