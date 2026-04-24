import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/app_state.dart';
import 'screens/main_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      appState: _appState,
      child: MaterialApp(
        title: 'Nouakchott Guide',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

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
  bool updateShouldNotify(AppStateProvider oldWidget) => appState != oldWidget.appState;
}
