import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../4_driver/dashboard/screens/driver_dashboard_screen.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/driver_profile_service.dart';

class DriverSetupScreen extends StatefulWidget {
  const DriverSetupScreen({super.key});

  @override
  State<DriverSetupScreen> createState() => _DriverSetupScreenState();
}

class _DriverSetupScreenState extends State<DriverSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _driverNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleBrandController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _currentLocationController = TextEditingController();

  bool _isLoading = false;
  String _selectedVehicleType = 'Motorcycle';

  @override
  void dispose() {
    _driverNameController.dispose();
    _phoneController.dispose();
    _vehicleBrandController.dispose();
    _vehicleModelController.dispose();
    _plateNumberController.dispose();
    _vehicleColorController.dispose();
    _currentLocationController.dispose();
    super.dispose();
  }

  Widget _inputField({
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

  Widget _vehicleTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: _selectedVehicleType,
          decoration: InputDecoration(
            labelText: 'Vehicle Type',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(19)),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(19),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          items: ['Motorcycle', 'Car', 'Bicycle']
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedVehicleType = value!;
            });
          },
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

  String? _validatePlateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vehicle plate number is required';
    }
    if (value.trim().length < 5) {
      return 'Please enter a valid plate number';
    }
    return null;
  }

  Future<void> _setupDriver() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the vehicle detail string in the format: Brand Model - Plate Number
      final vehicleDetail =
          "${_vehicleBrandController.text.trim()} ${_vehicleModelController.text.trim()} - ${_plateNumberController.text.trim()}";

      // Call the actual GraphQL mutation to create driver profile
      await DriverProfileService.createDriverProfile(
        namaPengemudi: _driverNameController.text.trim(),
        telepon: _phoneController.text.trim(),
        detailKendaraan: vehicleDetail,
        lokasiSaatIni: _currentLocationController.text.trim(),
      );

      Fluttertoast.showToast(
        msg: "Driver setup successful! Welcome to Food Delivery!",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DriverDashboard()),
        (route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Driver setup failed: ${e.toString()}",
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
                        'Setup Your Driver Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Complete your profile to start delivering',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),

                      _inputField(
                        labelText: 'Driver Name',
                        controller: _driverNameController,
                        validator: (value) =>
                            _validateRequired(value, 'Driver name'),
                      ),

                      _inputField(
                        labelText: 'Phone Number',
                        controller: _phoneController,
                        validator: (value) =>
                            _validateRequired(value, 'Phone number'),
                        keyboardType: TextInputType.phone,
                      ),

                      _vehicleTypeDropdown(),

                      _inputField(
                        labelText: 'Vehicle Brand (e.g., Honda, Toyota)',
                        controller: _vehicleBrandController,
                        validator: (value) =>
                            _validateRequired(value, 'Vehicle brand'),
                      ),

                      _inputField(
                        labelText: 'Vehicle Model (e.g., Vario, Avanza)',
                        controller: _vehicleModelController,
                        validator: (value) =>
                            _validateRequired(value, 'Vehicle model'),
                      ),

                      _inputField(
                        labelText: 'Vehicle Plate Number',
                        controller: _plateNumberController,
                        validator: _validatePlateNumber,
                      ),

                      _inputField(
                        labelText: 'Vehicle Color',
                        controller: _vehicleColorController,
                        validator: (value) =>
                            _validateRequired(value, 'Vehicle color'),
                      ),

                      _inputField(
                        labelText: 'Current Location',
                        controller: _currentLocationController,
                        validator: (value) =>
                            _validateRequired(value, 'Current location'),
                      ),

                      SizedBox(height: 40),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                        onPressed: _isLoading ? null : _setupDriver,
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
                                'Complete Driver Setup',
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
