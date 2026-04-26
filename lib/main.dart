import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/app_state.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TouristGuideApp());
}

class TouristGuideApp extends StatefulWidget {
  const TouristGuideApp({super.key});

  @override
  State<TouristGuideApp> createState() => _TouristGuideAppState();
}

class _TouristGuideAppState extends State<TouristGuideApp> {
  final AppState _appState = AppState();
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      appState: _appState,
      child: ThemeProvider(
        themeMode: _themeMode,
        onToggle: _toggleTheme,
        child: MaterialApp(
          title: 'Guide Nouakchott',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _themeMode,
          home: const MainScreen(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP STATE PROVIDER
// ─────────────────────────────────────────────────────────────────────────────

class AppStateProvider extends InheritedWidget {
  final AppState appState;

  const AppStateProvider({
    super.key,
    required this.appState,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final AppStateProvider? result =
        context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(result != null, 'No AppStateProvider found in context');
    return result!.appState;
  }

  @override
  bool updateShouldNotify(AppStateProvider oldWidget) =>
      appState != oldWidget.appState;
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME PROVIDER
// ─────────────────────────────────────────────────────────────────────────────

class ThemeProvider extends InheritedWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggle;

  const ThemeProvider({
    super.key,
    required this.themeMode,
    required this.onToggle,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    final ThemeProvider? result =
        context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(result != null, 'No ThemeProvider found in context');
    return result!;
  }

  bool get isDark => themeMode == ThemeMode.dark;

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) =>
      themeMode != oldWidget.themeMode;
}
