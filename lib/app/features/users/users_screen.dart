import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Radnici")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Radnik 1"),
            subtitle: const Text("worker"),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Admin"),
            subtitle: const Text("owner"),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Dodaj radnika"),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
