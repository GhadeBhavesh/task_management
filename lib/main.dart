import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/pages/auth/login_screen.dart';
import 'package:task_management/pages/home/home_screen.dart';
import 'package:task_management/pages/onboarding/onboarding_screen.dart';
import 'application/auth/auth_provider.dart';
import 'domain/auth/auth_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(ProviderScope(child: MyApp(hasSeenOnboarding: hasSeenOnboarding)));
}

class MyApp extends ConsumerWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:
          hasSeenOnboarding
              ? authState is AuthenticatedState
                  ? const HomeScreen()
                  : const LoginScreen()
              : const OnboardingScreen(),
    );
  }
}

Widget _buildHomeScreen(AuthState state) {
  if (state is AuthenticatedState) {
    return const HomeScreen();
  } else if (state is LoadingAuthState) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  } else {
    return const LoginScreen();
  }
}
