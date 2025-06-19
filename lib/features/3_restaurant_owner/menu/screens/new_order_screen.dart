import 'package:flutter/material.dart';

class NewOrdersPage extends StatelessWidget {
  const NewOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Orders")),
      body: ListView.builder(
        itemCount: 3, // Simulasi
        itemBuilder: (context, index) => Card(
          child: ListTile(
            title: Text("Order #$index"),
            subtitle: const Text("Customer Name"),
            trailing: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text("Accept")),
                OutlinedButton(onPressed: () {}, child: const Text("Reject")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
