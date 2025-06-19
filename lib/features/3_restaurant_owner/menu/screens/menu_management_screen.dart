import 'package:flutter/material.dart';

class MenuManagementPage extends StatelessWidget {
  const MenuManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu Management")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Nasi Goreng"),
            subtitle: const Text("Rp 20.000"),
            trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          ),
          // Tambah tombol tambah menu di bawah
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
