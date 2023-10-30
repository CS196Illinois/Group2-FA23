// importing packages
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
// importing local files in the same directory
import 'supabase_credentials.dart';
import 'login_screen.dart';
import 'home_screen.dart';

Future<void> main() async {
  // Ensuring that widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initializing Supabase with the provided URL and anonymous key (You will need to change this in `supabase_credentials.dart`)
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  // Running the app with MyApp as the root widget
  runApp(const MyApp());
}

// main app widget
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  @override
  State<MyApp> createState() => _MyAppState();
}

// state class for MyApp
class _MyAppState extends State<MyApp> {
  // A subscription to listen to authentication state changes
  late final StreamSubscription<AuthState> _authSubscription;
  bool _isSignedIn = false; // track if the user is signed in

  // functions that will run at the start of state class
  @override
  void initState() {
    super.initState();
    _initializeSupabase();
    _checkAuthStatus(); // Checking the current authentication status
    _setupAuthChangeListener(); // Setting up a listener for authentication state changes
  }

  // initialize Supabase
  Future<void> _initializeSupabase() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // checks Authentication status of user
  void _checkAuthStatus() {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _isSignedIn = user != null;
    });
  }

/**
 * Here's a breakdown of this function:
 * Stream Subscription:
    - authSubscription is a StreamSubscription of type AuthState. It's used to subscribe to the authentication state changes stream provided by Supabase.
    - Supabase.instance.client.auth.onAuthStateChange returns a stream of AuthState events, which occur whenever there's a change in the authentication state of the user.
 * Event Listener:
    - The listen method is used to attach a listener to the stream. This listener is a function that takes an AuthState object as a parameter, referred to as data in this context.
    - Inside the listener, data.event gives us the specific type of authentication event that has occurred, which is of type AuthChangeEvent.
 * Handling Different Events:
    - The function checks the type of AuthChangeEvent and updates the _isSignedIn state variable accordingly.
    - If the event is AuthChangeEvent.signedIn or AuthChangeEvent.tokenRefreshed, it means the user has successfully signed in or their authentication token has been refreshed. In this case, _isSignedIn is set to true.
    - If the event is AuthChangeEvent.signedOut, it means the user has signed out, and _isSignedIn is set to false.
 * Updating the UI:
    - setState is called to ensure that the UI is rebuilt with the updated _isSignedIn value. 
    This will result in the build method being called again, and the UI will reflect the current authentication state.
 */
  void _setupAuthChangeListener() {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        setState(() {
          _isSignedIn = true;
        });
      } else if (event == AuthChangeEvent.signedOut) {
        setState(() {
          _isSignedIn = false;
        });
      }
    });
  }

  // Dispose resources when the widget is destroyed
  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  // Build the widget tree
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // theme of your application
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Show HomeScreen if signed in, otherwise show LoginScreen
      home: _isSignedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
