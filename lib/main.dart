import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/notifications/notification_service.dart';
import 'features/focus/data/datasourses/focus_local_datasourse.dart';
import 'features/focus/data/models/focus_model.dart';
import 'features/focus/presentation/bloc/focus_bloc/focus_bloc.dart';
import 'features/focus/presentation/bloc/focus_bloc/focus_state.dart';
import 'features/focus/presentation/screens/focus_screen.dart';
import 'features/todo/data/datasources/todo_local_datasource.dart';
import 'features/todo/data/models/todo_model.dart';
import 'features/todo/presentation/bloc/todo_bloc/todo_bloc.dart';
import 'features/todo/presentation/screens/calendar_screen.dart';
import 'features/todo/presentation/screens/todo_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  await Hive.initFlutter();
  Hive.registerAdapter(TodoModelAdapter());
  Hive.registerAdapter(FocusTypeAdapter());
  Hive.registerAdapter(SessionLogAdapter());
  await Hive.openBox<TodoModel>('todosBox');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TodoBloc(TodoLocalDataSource())),
        BlocProvider(create: (_) => FocusBloc(FocusLocalDataSource())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const AppShell(),
    );
  }
}

// ─── AppShell ─────────────────────────────────────────────────────────────────

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TodoScreen(),
    const CalendarScreen(),
    const FocusScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Watch FocusBloc — rebuilds AppShell when focus state changes so the
    // nav bar updates immediately when a session starts or ends.
    final focusState = context.watch<FocusBloc>().state;
    final isFocusRunning =
        _currentIndex == 2 && focusState is FocusRunning;

    return Scaffold(
      // extendBody: true lets the page content draw behind the nav bar,
      // so the gradient bleeds through when it's transparent.
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: isFocusRunning
            ? NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          // Selection indicator: subtle white circle
          indicatorColor: Colors.white.withOpacity(0.18),
          // Icons
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? Colors.white : Colors.white60,
              size: 24,
            );
          }),
          // Labels
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected ? Colors.white : Colors.white60,
              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.normal,
              fontSize: 12,
            );
          }),
        )
            : const NavigationBarThemeData(), // default theme for all other screens
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.check_box_outline_blank),
              selectedIcon: Icon(Icons.check_box),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Focus',
            ),
          ],
        ),
      ),
    );
  }
}