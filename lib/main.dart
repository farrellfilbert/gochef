import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'screens/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zhfiufwbecvdwkdotgie.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpoZml1ZndiZWN2ZHdrZG90Z2llIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2MTU5NTMsImV4cCI6MjA5NzE5MTk1M30.QBqqxSCY76OXo040CPgLa6RmOjyUhNKE10HpXwpRFAo',
  );

  runApp(
    const ProviderScope(
      child: GoChefApp(),
    ),
  );
}

class GoChefApp extends StatelessWidget {
  const GoChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoChef',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const RoleSelectionScreen(),
    );
  }
}
