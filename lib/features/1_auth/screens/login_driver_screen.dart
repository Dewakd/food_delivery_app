import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/4_driver/dashboard/screens/driver_dashboard_screen.dart';
import 'login_customer_screen.dart';
import 'login_restaurant_screen.dart';
import 'register_driver_screen.dart';

class LoginPageDriver extends StatefulWidget {
  const LoginPageDriver({super.key});

  @override
  State<LoginPageDriver> createState() => _LoginPageDriverState();
}

class _LoginPageDriverState extends State<LoginPageDriver> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Langsung me-return CupertinoPageScaffold,
    // TIDAK ADA MaterialApp di sini.
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background_welcome_page.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Image.asset(
                      'assets/food_delivery.png',
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    child: const Text('Login as Driver'),
                  ),
                  const SizedBox(height: 40),
                  CupertinoTextField(
                    controller: emailController,
                    placeholder: 'Email',
                    padding: const EdgeInsets.all(16),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: CupertinoColors.black),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(color: CupertinoColors.systemGrey2),
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CupertinoTextField(
                    controller: passwordController,
                    placeholder: 'Password',
                    obscureText: _obscurePassword,
                    padding: const EdgeInsets.all(16),
                    keyboardType: TextInputType.visiblePassword,
                    style: const TextStyle(color: CupertinoColors.black),
                    suffix: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(color: CupertinoColors.systemGrey2),
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                  const SizedBox(height: 80),
                  CupertinoButton(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(19),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: CupertinoColors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DriverDashboard()),
                      );
                    },
                  ),
                  CupertinoButton(
                    child: const Text("Don't have an account? Sign up",
                        style: TextStyle(color: Colors.blueAccent)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPageDriver()),
                      );
                    },
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPageUser()),
                            );
                        },
                        child: Text(
                          'User?',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPageRestaurant()),
                            );
                        },
                        child: Text(
                          'Restaurant Owner?',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}