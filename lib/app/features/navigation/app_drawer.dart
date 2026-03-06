import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final Function(String route) onNavigate;

  const AppDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text("Carpet Service", style: TextStyle(fontSize: 22)),
          ),

          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("Narudžbe"),
            onTap: () => onNavigate("orders"),
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Postavke"),
            onTap: () => onNavigate("settings"),
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Radnici"),
            onTap: () => onNavigate("users"),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () => onNavigate("logout"),
          ),
        ],
      ),
    );
  }
}
