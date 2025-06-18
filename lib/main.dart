import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/presentation/auth/login_screen.dart';
import 'package:task_management/presentation/home/home_screen.dart';
import 'application/auth/auth_provider.dart';
import 'domain/auth/auth_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Task Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _buildHomeScreen(authState),
    );
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
}
