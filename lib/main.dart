import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://salgnwxzcnwjdjozrhyt.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNhbGdud3h6Y253amRqb3pyaHl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxNDA4MTgsImV4cCI6MjA4NzcxNjgxOH0.n13pUON2azZu_-lj7chVixfle12jzQa7ChS-LFNn7o8",
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Service Management',
      theme: ThemeData(useMaterial3: true),
      home: const AuthGate(),
    );
  }
}


