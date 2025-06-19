import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/2_customer/cart/screens/cart_screen.dart';
import 'package:food_delivery_app/features/0_splash/screens/splash_screen.dart';
import 'package:food_delivery_app/features/4_driver/dashboard/screens/driver_dashboard_screen.dart';
import 'package:food_delivery_app/features/3_restaurant_owner/dashboard/screens/restaurant_dashboard_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CartScreen(),
    );
  }
}
