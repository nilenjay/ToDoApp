import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/focus_model.dart';
import '../bloc/focus_bloc/focus_bloc.dart';
import '../bloc/focus_bloc/focus_event.dart';
import '../bloc/focus_bloc/focus_state.dart';

class FocusActiveScreen extends StatelessWidget {
  final FocusRunning state;
  const FocusActiveScreen({super.key, required this.state});

  static const List<String> _breakTips = [
    'Stand up and stretch 🧘',
    'Grab some water 💧',
    'Look 20 ft away for 20 seconds 👀',
    'Take 5 deep breaths 🌬️',
    'Walk around for a minute 🚶',
  ];

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int _currentPhaseTotalSeconds() {
    final breaks = calculateBreaks(state.totalSeconds ~/ 60, state.focusType);

    if (state.phase == SessionPhase.breakTime) {
      if (state.currentBreakIndex < breaks.length) {
        return breaks[state.currentBreakIndex].breakMinutes * 60;
      }
    }

    if (state.currentBreakIndex < breaks.length) {
      final breakAt = breaks[state.currentBreakIndex].afterMinutes * 60;
      final prevBreakEnd = state.currentBreakIndex > 0
          ? (breaks[state.currentBreakIndex - 1].afterMinutes +
          breaks[state.currentBreakIndex - 1].breakMinutes) *
          60
          : 0;
      return breakAt - prevBreakEnd;
    }

    return state.totalSeconds - state.elapsedSeconds + state.phaseSecondsLeft;
  }

  void _confirmEnd(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text(
            'Your progress will be saved and you\'ll see a summary.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<FocusBloc>().add(const EndSession());
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFocus = state.phase == SessionPhase.focus;
    final phaseColor =
    isFocus ? theme.colorScheme.primary : Colors.green.shade600;

    final overallProgress =
    (state.elapsedSeconds / state.totalSeconds).clamp(0.0, 1.0);

    final phaseTotalSeconds = _currentPhaseTotalSeconds();
    final phaseProgress = phaseTotalSeconds > 0
        ? (1 - state.phaseSecondsLeft / phaseTotalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.sessionName),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => _confirmEnd(context),
            child:
            Text('End', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Overall progress bar ──────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Overall progress',
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    Text(
                      '${state.elapsedSeconds ~/ 60}m / ${state.totalSeconds ~/ 60}m',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: overallProgress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ── Phase label ───────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                isFocus ? '🎯 Focus Time' : '☕ Break Time',
                key: ValueKey(state.phase),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: phaseColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Circular timer ────────────────────────────────────────────
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: _CircleTimerPainter(
                      progress: phaseProgress,
                      color: phaseColor,
                      backgroundColor: phaseColor.withOpacity(0.12),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _format(state.phaseSecondsLeft),
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: phaseColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (state.isPaused)
                        Text(
                          'Paused',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Break tip ─────────────────────────────────────────────────
            if (!isFocus)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _breakTips[state.currentBreakIndex % _breakTips.length],
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.green.shade800),
                  textAlign: TextAlign.center,
                ),
              ),

            // ── Breaks indicator ──────────────────────────────────────────
            if (state.totalBreaks > 0) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(state.totalBreaks, (i) {
                  final done = i < state.currentBreakIndex;
                  final active = i == state.currentBreakIndex &&
                      state.phase == SessionPhase.breakTime;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? Colors.green
                          : active
                          ? Colors.green.shade300
                          : theme.colorScheme.surfaceVariant,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Text(
                '${state.currentBreakIndex} of ${state.totalBreaks} breaks taken',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ],

            const Spacer(),

            // ── Pause / Resume ────────────────────────────────────────────
            FloatingActionButton.large(
              heroTag: 'pause_resume',
              onPressed: () {
                if (state.isPaused) {
                  context.read<FocusBloc>().add(const ResumeSession());
                } else {
                  context.read<FocusBloc>().add(const PauseSession());
                }
              },
              backgroundColor: phaseColor,
              child: Icon(
                state.isPaused ? Icons.play_arrow : Icons.pause,
                size: 36,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Circular timer painter ───────────────────────────────────────────────────

class _CircleTimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CircleTimerPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleTimerPainter old) =>
      old.progress != progress || old.color != color;
}