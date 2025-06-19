import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/3_restaurant_owner/menu/screens/menu_management_screen.dart';
import 'package:food_delivery_app/features/3_restaurant_owner/menu/screens/new_order_screen.dart';
import 'package:food_delivery_app/features/3_restaurant_owner/menu/screens/update_order_screen.dart';
import 'package:food_delivery_app/features/3_restaurant_owner/settings/screens/order_history_screen.dart';
import 'package:food_delivery_app/features/3_restaurant_owner/settings/screens/restaurant_settings_screen.dart';


class RestaurantDashboardPage extends StatelessWidget {
  const RestaurantDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Restaurant Owner Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF88D66C),
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildDashboardButton(
              context,
              icon: Icons.receipt_long,
              label: "New Orders",
              page: const NewOrdersPage(),
            ),
            _buildDashboardButton(
              context,
              icon: Icons.check_box,
              label: "Update Order Status",
              page: const UpdateOrderStatusPage(),
            ),
            _buildDashboardButton(
              context,
              icon: Icons.menu_book,
              label: "Menu Management",
              page: const MenuManagementPage(),
            ),
            _buildDashboardButton(
              context,
              icon: Icons.access_time,
              label: "Set Business Hours",
              page: const BusinessHoursPage(),
            ),
            _buildDashboardButton(
              context,
              icon: Icons.analytics,
              label: "Order History / Analytics",
              page: const OrderHistoryPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
      ),
    );
  }
}
