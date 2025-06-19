import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order History / Analytics")),
      body: ListView(
        children: const [
          ListTile(title: Text("Order #1 - Completed")),
          ListTile(title: Text("Order #2 - Canceled")),
          ListTile(title: Text("Order #3 - Completed")),
        ],
      ),
    );
  }
}
