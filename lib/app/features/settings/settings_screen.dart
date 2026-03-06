import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Postavke")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text("Cijena pranja po m²"),
            subtitle: Text("3 KM"),
            trailing: Icon(Icons.edit),
          ),

          Divider(),

          ListTile(
            title: Text("Dropoff popust"),
            subtitle: Text("10%"),
            trailing: Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
