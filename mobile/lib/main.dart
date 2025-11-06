import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/sleep_tracker_screen.dart';
import 'screens/sounds_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: DefaultFirebaseOptions.firebaseConfig['apiKey']!,
      appId: DefaultFirebaseOptions.firebaseConfig['appId']!,
      messagingSenderId: DefaultFirebaseOptions.firebaseConfig['messagingSenderId']!,
      projectId: DefaultFirebaseOptions.firebaseConfig['projectId']!,
      storageBucket: DefaultFirebaseOptions.firebaseConfig['storageBucket']!,
    ),
  );
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const SleepApp());
}

class SleepApp extends StatelessWidget {
  const SleepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Tracker',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _pages = const [SleepTrackerScreen(), SoundsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Tracker')),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.nights_stay), label: 'Track'),
          NavigationDestination(icon: Icon(Icons.music_note), label: 'Sounds'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
