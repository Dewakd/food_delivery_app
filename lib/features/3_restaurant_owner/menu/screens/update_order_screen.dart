import 'package:flutter/material.dart';

class UpdateOrderStatusPage extends StatelessWidget {
  const UpdateOrderStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Order Status")),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            title: Text("Order #$index"),
            subtitle: const Text("Current: Preparing"),
            trailing: DropdownButton<String>(
              value: "Preparing",
              items: const [
                DropdownMenuItem(value: "Preparing", child: Text("Preparing")),
                DropdownMenuItem(value: "Ready", child: Text("Ready")),
                DropdownMenuItem(value: "Completed", child: Text("Completed")),
              ],
              onChanged: (value) {},
            ),
          ),
        ),
      ),
    );
  }
}
