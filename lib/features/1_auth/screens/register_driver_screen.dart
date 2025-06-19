import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'driver_setup_screen.dart';
import 'login_screen.dart';
import '../../../providers/auth_provider.dart';
import 'register_customer_screen.dart';
import 'register_restaurant_screen.dart';

class RegisterPageDriver extends StatefulWidget {
  const RegisterPageDriver({super.key});

  @override
  State<RegisterPageDriver> createState() => _RegisterPageDriverState();
}

class _RegisterPageDriverState extends State<RegisterPageDriver> {
  bool _obscureText = true;
  bool _obscureConfirmPassword = true;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _inputkolom({
    required String labelText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            labelText: labelText,
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(19)),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(19),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _inputpass({
    required String labelText,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            labelText: labelText,
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(19)),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(19),
              borderSide: BorderSide(color: Colors.red),
            ),
            suffixIcon: IconButton(
              onPressed: toggleVisibility,
              icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // Validation methods
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.trim().length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Register method
  Future<void> _registerDriver() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: 'Driver', // Fixed role for driver registration
        namaPengguna: _nameController.text.trim(),
        telepon: _phoneController.text.trim(),
      );

      if (success) {
        Fluttertoast.showToast(
          msg: "Account created! Now let's setup your vehicle!",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Navigate to driver setup screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriverSetupScreen()),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Registration failed: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
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
            ),
          ),

          // Konten Utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            Image.asset('assets/food_delivery.png', height: 90),
                            SizedBox(height: 10),
                            Text(
                              'Create Driver Account',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Step 1 of 2: Create your driver account',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            _inputkolom(
                              labelText: 'Full Name',
                              controller: _nameController,
                              validator: _validateName,
                            ),
                            _inputkolom(
                              labelText: 'Email',
                              controller: _emailController,
                              validator: _validateEmail,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            _inputkolom(
                              labelText: 'Phone Number',
                              controller: _phoneController,
                              validator: _validatePhone,
                              keyboardType: TextInputType.phone,
                            ),
                            _inputpass(
                              labelText: 'Password',
                              obscureText: _obscureText,
                              controller: _passwordController,
                              validator: _validatePassword,
                              toggleVisibility: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            _inputpass(
                              labelText: 'Confirm Password',
                              obscureText: _obscureConfirmPassword,
                              controller: _confirmPasswordController,
                              validator: _validateConfirmPassword,
                              toggleVisibility: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            SizedBox(height: 30),
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    minimumSize: Size(330, 45),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(19),
                                    ),
                                  ),
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _registerDriver,
                                  child: authProvider.isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Create Driver Account',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Do You have an Account? '),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Back to Login',
                                    style: TextStyle(color: Colors.blueAccent),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                            MaterialPageRoute(
                              builder: (context) => const RegisterPageUser(),
                            ),
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterPageRestaurant(),
                            ),
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
