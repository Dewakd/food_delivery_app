import 'package:flutter/material.dart';
import '../services/driver_service.dart';

enum DriverStatus { Offline, Online, Delivering }

class DriverProvider with ChangeNotifier {
  DriverStatus _status = DriverStatus.Offline;
  List<dynamic> _availableOrders = [];
  List<dynamic> _myDeliveries = [];
  Map<String, dynamic>? _currentDelivery;
  bool _isLoading = false;
  double? _currentLatitude;
  double? _currentLongitude;

  // Getters
  DriverStatus get status => _status;
  List<dynamic> get availableOrders => _availableOrders;
  List<dynamic> get myDeliveries => _myDeliveries;
  Map<String, dynamic>? get currentDelivery => _currentDelivery;
  bool get isLoading => _isLoading;
  bool get isOnline => _status == DriverStatus.Online;
  bool get isDelivering => _status == DriverStatus.Delivering;
  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;

  // Go Online
  Future<bool> goOnline() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await DriverService.goOnline();
      if (result != null) {
        _status = DriverStatus.Online;
        await loadAvailableOrders();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Go Offline
  Future<bool> goOffline() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await DriverService.goOffline();
      if (result != null) {
        _status = DriverStatus.Offline;
        _availableOrders.clear();
        _currentDelivery = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Available Orders
  Future<void> loadAvailableOrders() async {
    try {
      final orders = await DriverService.getAvailableOrders(limit: 20);
      _availableOrders = orders;
      notifyListeners();
    } catch (e) {
      // Handle error silently or show notification
      print('Failed to load available orders: $e');
    }
  }

  // Load My Deliveries
  Future<void> loadMyDeliveries() async {
    try {
      final deliveries = await DriverService.getMyDeliveries(limit: 10);
      _myDeliveries = deliveries;
      notifyListeners();
    } catch (e) {
      // Handle error silently or show notification
      print('Failed to load my deliveries: $e');
    }
  }

  // Accept Delivery
  Future<bool> acceptDelivery(String orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await DriverService.acceptDelivery(orderId);
      if (result != null) {
        _status = DriverStatus.Delivering;
        _currentDelivery = result;

        // Remove order from available orders
        _availableOrders.removeWhere((order) => order['pesananId'] == orderId);

        // Refresh my deliveries
        await loadMyDeliveries();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Complete Delivery
  Future<bool> completeDelivery(String orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await DriverService.completeDelivery(orderId);
      if (result != null) {
        _status = DriverStatus.Online;
        _currentDelivery = null;

        // Refresh both lists
        await loadAvailableOrders();
        await loadMyDeliveries();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Location
  Future<bool> updateLocation(double latitude, double longitude) async {
    try {
      final result = await DriverService.updateLocation(latitude, longitude);
      if (result != null) {
        _currentLatitude = latitude;
        _currentLongitude = longitude;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update location: $e');
      return false;
    }
  }

  // Refresh Data
  Future<void> refreshData() async {
    if (_status == DriverStatus.Online || _status == DriverStatus.Delivering) {
      await loadAvailableOrders();
    }
    await loadMyDeliveries();
  }
}
