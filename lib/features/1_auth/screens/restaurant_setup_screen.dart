import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../3_restaurant_owner/dashboard/screens/restaurant_dashboard_screen.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/restaurant_owner_service.dart';

class RestaurantSetupScreen extends StatefulWidget {
  const RestaurantSetupScreen({super.key});

  @override
  State<RestaurantSetupScreen> createState() => _RestaurantSetupScreenState();
}

class _RestaurantSetupScreenState extends State<RestaurantSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantNameController = TextEditingController();
  final _restaurantAddressController = TextEditingController();
  final _cuisineTypeController = TextEditingController();
  final _openingHoursController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _restaurantAddressController.dispose();
    _cuisineTypeController.dispose();
    _openingHoursController.dispose();
    _deliveryFeeController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _inputField({
    required String labelText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
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

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateDeliveryFee(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Delivery fee is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  Future<void> _setupRestaurant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the actual GraphQL mutation to create restaurant
      await RestaurantOwnerService.createRestaurant(
        nama: _restaurantNameController.text.trim(),
        alamat: _restaurantAddressController.text.trim(),
        jenisMasakan: _cuisineTypeController.text.trim(),
        jamBuka: _openingHoursController.text.trim(),
        biayaAntar: double.parse(_deliveryFeeController.text.trim()),
        telepon: _phoneController.text.trim(),
        deskripsi: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      Fluttertoast.showToast(
        msg: "Restaurant setup successful! Welcome to Food Delivery!",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const RestaurantDashboardPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Restaurant setup failed: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background_welcome_page.png',
              fit: BoxFit.cover,
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Image.asset('assets/food_delivery.png', height: 80),
                      SizedBox(height: 20),
                      Text(
                        'Setup Your Restaurant',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Tell us about your restaurant to get started',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),

                      _inputField(
                        labelText: 'Restaurant Name',
                        controller: _restaurantNameController,
                        validator: (value) =>
                            _validateRequired(value, 'Restaurant name'),
                      ),

                      _inputField(
                        labelText: 'Restaurant Address',
                        controller: _restaurantAddressController,
                        validator: (value) =>
                            _validateRequired(value, 'Restaurant address'),
                        maxLines: 2,
                      ),

                      _inputField(
                        labelText:
                            'Cuisine Type (e.g., Italian, Asian, Fast Food)',
                        controller: _cuisineTypeController,
                        validator: (value) =>
                            _validateRequired(value, 'Cuisine type'),
                      ),

                      _inputField(
                        labelText: 'Opening Hours (e.g., 09:00 - 22:00)',
                        controller: _openingHoursController,
                        validator: (value) =>
                            _validateRequired(value, 'Opening hours'),
                      ),

                      _inputField(
                        labelText: 'Delivery Fee (IDR)',
                        controller: _deliveryFeeController,
                        validator: _validateDeliveryFee,
                        keyboardType: TextInputType.number,
                      ),

                      _inputField(
                        labelText: 'Restaurant Phone Number',
                        controller: _phoneController,
                        validator: (value) =>
                            _validateRequired(value, 'Phone number'),
                        keyboardType: TextInputType.phone,
                      ),

                      _inputField(
                        labelText: 'Restaurant Description (Optional)',
                        controller: _descriptionController,
                        validator: (value) => null, // Optional field
                        maxLines: 3,
                      ),

                      SizedBox(height: 40),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                        onPressed: _isLoading ? null : _setupRestaurant,
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Complete Restaurant Setup',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        'You can update these details later in your dashboard',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
