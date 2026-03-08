import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/focus_bloc/focus_bloc.dart';
import '../bloc/focus_bloc/focus_state.dart';
import 'focus_active_screen.dart';
import 'focus_setup_screen.dart';
import 'focus_summary_screen.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusBloc, FocusState>(
      builder: (context, state) {
        if (state is FocusRunning) {
          return FocusActiveScreen(state: state);
        }
        if (state is FocusCompleted) {
          return FocusSummaryScreen(state: state);
        }
        return const FocusSetupScreen();
      },
    );
  }
}