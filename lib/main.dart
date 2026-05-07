import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/date_symbol_data_local.dart';
import 'package:taskbuddy_new/core/theme/app_theme.dart';
import 'package:taskbuddy_new/features/splash/pages/splash_screen.dart';
import 'package:taskbuddy_new/features/auth/pages/login_page.dart';
import 'package:taskbuddy_new/features/auth/pages/register_page.dart';
import 'package:taskbuddy_new/features/home/pages/home_page.dart';
import 'package:taskbuddy_new/features/onboarding/pages/onboarding_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // inisialisasi locale Indonesia
  try {
    await Firebase.initializeApp(
      options: kIsWeb
          ? const FirebaseOptions(
              apiKey: 'AIzaSyBvbMwkOZbk0ac5ozek55zrzApdQWKL8E',
              appId: '1:214650731637:web:63d02f35accef054000c3c',
              messagingSenderId: '214650731637',
              projectId: 'finalwilly-8b446',
              authDomain: 'finalwilly-8b446.firebaseapp.com',
              storageBucket: 'finalwilly-8b446.firebasestorage.app',
              measurementId: 'G-FQ1DC4LYTX',
            )
          : const FirebaseOptions(
              apiKey: 'AIzaSyA7pRmhUfrESH3Bv3Vl_SprDv1Hl2f_m9Q',
              appId: '1:214650731637:android:d480540447c0eb44000c3c',
              messagingSenderId: '214650731637',
              projectId: 'finalwilly-8b446',
              storageBucket: 'finalwilly-8b446.firebasestorage.app',
            ),
    );
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _user;
  bool _isLoading = true;
  bool _hasBeenLoggedIn = false; // Tracks if user has logged in before

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint("[AUTH] State changed. User: ${user?.uid ?? 'null'}");
      if (mounted) {
        // Jika user logout (dari login ke tidak login), bersihkan navigation stack
        if (user == null && _user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
        }
        setState(() {
          if (user != null) _hasBeenLoggedIn = true;
          _user = user;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen(key: ValueKey('splash_loading'));
    }

    if (_user != null) {
      return const HomePage(key: ValueKey('home'));
    }

    // Jika sebelumnya sudah login lalu logout, langsung ke Login (skip Splash & Onboarding)
    return EntryFlow(
      key: const ValueKey('entry'),
      skipToLogin: _hasBeenLoggedIn,
    );
  }
}

/// Manages Splash -> Onboarding -> Login / Register flow for unauthenticated users
class EntryFlow extends StatefulWidget {
  final bool skipToLogin;
  const EntryFlow({super.key, this.skipToLogin = false});

  @override
  State<EntryFlow> createState() => _EntryFlowState();
}

enum EntryState { splash, onboarding, login, register }

class _EntryFlowState extends State<EntryFlow> {
  EntryState _currentState = EntryState.splash;

  @override
  void initState() {
    super.initState();
    if (widget.skipToLogin) {
      // Langsung ke Login jika ini setelah logout
      _currentState = EntryState.login;
    } else {
      // Mulai dari Splash untuk first launch
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _currentState = EntryState.onboarding;
          });
        }
      });
    }
  }

  void _navigateTo(EntryState state) {
    setState(() {
      _currentState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case EntryState.splash:
        return const SplashScreen();
      case EntryState.onboarding:
        return OnboardingWrapper(onFinish: () => _navigateTo(EntryState.login));
      case EntryState.login:
        return LoginPage(onShowRegister: () => _navigateTo(EntryState.register));
      case EntryState.register:
        return RegisterPage(onShowLogin: () => _navigateTo(EntryState.login));
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
