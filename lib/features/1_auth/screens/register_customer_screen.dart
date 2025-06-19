import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/2_customer/home/screens/customer_home_screen.dart';
import 'package:food_delivery_app/features/1_auth/screens/login_customer_screen.dart';
import 'register_driver_screen.dart';
import 'register_restaurant_screen.dart';

class RegisterPageUser extends StatefulWidget {
  const RegisterPageUser({super.key});

  @override
  State<RegisterPageUser> createState() => _RegisterPageUserState();
}

class _RegisterPageUserState extends State<RegisterPageUser> {
  bool _obscureText = true;
  bool _obscureConfirmPassword = true;

  Widget _inputkolom({
    required String labelText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        TextField(
          style: TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
              labelText: labelText,
              hintStyle: TextStyle(color: Colors.grey),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(19))),
        )
      ],
    );
  }

  Widget _inputpass({
    required String labelText,
    required bool obscureText,
    required VoidCallback toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        TextField(
          obscureText: obscureText,
          style: TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            labelText: labelText,
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(19)),
            suffixIcon: IconButton(
              onPressed: toggleVisibility,
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar Belakang Gambar
          Positioned.fill(
              child: Image.asset(
            'assets/background_welcome_page.png',
            fit: BoxFit.cover,
          )),

          // Konten Utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          Image.asset(
                            'assets/food_delivery.png',
                            height: 90,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Create an User Account',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          _inputkolom(labelText: 'Nama Lengkap'),
                          _inputkolom(labelText: 'Email'),
                          _inputkolom(labelText: 'Phone Number'),
                          _inputpass(
                              labelText: 'Password',
                              obscureText: _obscureText,
                              toggleVisibility: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              }),
                          _inputpass(
                              labelText: 'Confirm Password',
                              obscureText: _obscureConfirmPassword,
                              toggleVisibility: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              }),
                          SizedBox(height: 30),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: Size(330, 45),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(19))),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()),
                                );
                              },
                              child: Text(
                                'Register',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Do You have an Account? '),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginPageUser()),
                                  );
                                },
                                child: Text(
                                  'Back to Login',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPageDriver()),
                          );
                        },
                        child: Text(
                          'Driver?',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPageRestaurant()),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  }
