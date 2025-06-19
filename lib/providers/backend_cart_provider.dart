import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class BackendCartProvider with ChangeNotifier {
  Map<String, dynamic>? _cart;
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCart => _cart != null;

  // Cart details getters
  String? get cartId => _cart?['cartId'];
  String? get restaurantId => _cart?['restoranId'];
  List<Map<String, dynamic>> get items =>
      (_cart?['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  int get itemCount => _cart?['itemCount'] ?? 0;
  double get subtotal => (_cart?['subtotal'] ?? 0).toDouble();
  double get deliveryFee => (_cart?['deliveryFee'] ?? 0).toDouble();
  double get serviceFee => (_cart?['serviceFee'] ?? 0).toDouble();
  double get totalAmount => (_cart?['totalAmount'] ?? 0).toDouble();

  // Restaurant details
  Map<String, dynamic>? get restaurant => _cart?['restoran'];
  String? get restaurantName => restaurant?['nama'];

  // Load cart for specific restaurant or any available cart
  Future<void> loadCart({String? restaurantId}) async {
    _setLoading(true);
    _error = null;

    try {
      debugPrint('🛒 Loading cart for restaurant: $restaurantId');

      final cartData = await CartService.getMyCart(restaurantId: restaurantId);

      if (cartData != null) {
        _cart = cartData;
        debugPrint('✅ Cart loaded successfully: ${cartData['cartId']}');
        debugPrint('   Restaurant: ${cartData['restoran']?['nama']}');
        debugPrint('   Item count: ${cartData['itemCount']}');
        debugPrint('   Total: ${cartData['totalAmount']}');
      } else {
        _cart = null;
        debugPrint('📭 No cart found for restaurant: $restaurantId');
      }

      debugPrintCartState();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading cart: $e');
    } finally {
      _setLoading(false);
      // Don't call notifyListeners here as _setLoading already does it
    }
  }

  // Add item to cart (auto-handles restaurant switching)
  Future<bool> addToCart({
    required String restaurantId,
    required String menuItemId,
    required int quantity,
    String? instructions,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      debugPrint('🛒 Adding to cart:');
      debugPrint('   Restaurant: $restaurantId');
      debugPrint('   Menu Item: $menuItemId');
      debugPrint('   Quantity: $quantity');

      final result = await CartService.addToCart(
        restaurantId: restaurantId,
        menuItemId: menuItemId,
        quantity: quantity,
        instructions: instructions,
      );

      if (result != null) {
        debugPrint('✅ Item added successfully - reloading cart');

        // Immediately reload the cart to update UI
        await loadCart(restaurantId: restaurantId);

        debugPrint('✅ Cart reloaded after adding item');
        debugPrintCartState();
        return true;
      }

      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error adding to cart: $e');
      return false;
    } finally {
      _setLoading(false);
      // Don't call notifyListeners here as _setLoading already does it
    }
  }

  // Update cart item quantity
  Future<bool> updateCartItem({
    required String cartItemId,
    int? quantity,
    String? instructions,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      debugPrint('🔄 Updating cart item: $cartItemId to quantity: $quantity');
      debugPrint('   CartItemId type: ${cartItemId.runtimeType}');

      final result = await CartService.updateCartItem(
        cartItemId: cartItemId,
        quantity: quantity,
        instructions: instructions,
      );

      if (result != null) {
        debugPrint('✅ Cart item updated successfully - reloading cart');

        // Immediately reload the cart to update UI
        await loadCart(restaurantId: restaurantId);

        debugPrint('✅ Cart reloaded after updating item');
        debugPrintCartState();
        return true;
      }

      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error updating cart item: $e');

      // Try to reload cart even on error to sync state
      try {
        await loadCart(restaurantId: restaurantId);
      } catch (reloadError) {
        debugPrint('❌ Failed to reload cart after error: $reloadError');
      }

      return false;
    } finally {
      _setLoading(false);
      // Don't call notifyListeners here as _setLoading already does it
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String cartItemId) async {
    _setLoading(true);
    _error = null;

    try {
      debugPrint('🗑️ Removing cart item: $cartItemId');
      debugPrint('   CartItemId type: ${cartItemId.runtimeType}');
      debugPrint('   Current cart ID: $cartId');
      debugPrint('   Current restaurant ID: $restaurantId');

      final success = await CartService.removeFromCart(cartItemId);

      if (success) {
        debugPrint('✅ Item removed successfully - reloading cart');

        // Reload cart to get updated data
        await loadCart(restaurantId: restaurantId);

        debugPrint('✅ Cart reloaded after removing item');
        return true;
      } else {
        debugPrint('❌ Remove operation returned false');
        return false;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error removing cart item: $e');

      // Try to reload cart even on error to sync state
      try {
        await loadCart(restaurantId: restaurantId);
      } catch (reloadError) {
        debugPrint('❌ Failed to reload cart after error: $reloadError');
      }

      return false;
    } finally {
      _setLoading(false);
      // Don't call notifyListeners here as _setLoading already does it
    }
  }

  // Update cart info (address, payment, notes)
  Future<bool> updateCartInfo({
    String? address,
    String? paymentMethod,
    String? notes,
  }) async {
    if (cartId == null) return false;

    _setLoading(true);
    _error = null;

    try {
      debugPrint('📝 Updating cart info for cart: $cartId');

      final result = await CartService.updateCart(
        cartId: cartId!,
        address: address,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      if (result != null) {
        // Update local cart data
        _cart!.addAll(result);
        debugPrint('✅ Cart info updated successfully');
        debugPrintCartState();
        return true;
      }

      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error updating cart info: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear cart
  Future<bool> clearCart() async {
    if (cartId == null) return false;

    _setLoading(true);
    _error = null;

    try {
      debugPrint('🧹 Clearing cart: $cartId');

      final success = await CartService.clearCart(cartId!);

      if (success) {
        _cart = null;
        debugPrint('✅ Cart cleared successfully');
        return true;
      }

      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error clearing cart: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Checkout cart
  Future<Map<String, dynamic>?> checkoutCart() async {
    if (cartId == null) return null;

    _setLoading(true);
    _error = null;

    try {
      debugPrint('💳 Checking out cart: $cartId');

      final order = await CartService.checkoutCart(cartId!);

      if (order != null) {
        _cart = null; // Clear cart after successful checkout
        debugPrint(
          '✅ Checkout successful, order created: ${order['pesananId']}',
        );
        return order;
      }

      return null;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error during checkout: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Check if switching to a different restaurant
  bool isDifferentRestaurant(String newRestaurantId) {
    return restaurantId != null && restaurantId != newRestaurantId;
  }

  // Check if item exists in cart
  bool isItemInCart(String menuItemId) {
    debugPrint('🔍 Checking if item is in cart: $menuItemId');
    debugPrint('   Comparing with cart items:');
    for (var item in items) {
      debugPrint(
        '     Cart item menuItemId: ${item['itemMenuId']} (${item['itemMenuId'].runtimeType})',
      );
    }
    return items.any((item) => item['itemMenuId'].toString() == menuItemId);
  }

  // Get item quantity in cart
  int getItemQuantity(String menuItemId) {
    try {
      debugPrint('🔍 Getting quantity for menu item: $menuItemId');
      debugPrint('   Cart items count: ${items.length}');

      final item = items.firstWhere(
        (item) => item['itemMenuId'].toString() == menuItemId,
      );

      final quantity = item['quantity'] ?? 0;
      debugPrint('   Found quantity: $quantity');
      return quantity;
    } catch (e) {
      debugPrint('   Item not found in cart, returning 0');
      return 0;
    }
  }

  // Get cart item by menu item ID
  Map<String, dynamic>? getCartItem(String menuItemId) {
    try {
      debugPrint('🔍 Getting cart item for menu item: $menuItemId');

      final item = items.firstWhere(
        (item) => item['itemMenuId'].toString() == menuItemId,
      );

      debugPrint('   Found cart item: ${item['cartItemId']}');
      return item;
    } catch (e) {
      debugPrint('   Cart item not found for menu item: $menuItemId');
      return null;
    }
  }

  // Get cart item by cart item ID
  Map<String, dynamic>? getCartItemById(String cartItemId) {
    try {
      return items.firstWhere((item) => item['cartItemId'] == cartItemId);
    } catch (e) {
      return null;
    }
  }

  // Format currency helper (for backward compatibility)
  String formatCurrency(double amount) {
    return 'Rp ${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Alias for totalAmount (for backward compatibility)
  double get totalPrice => totalAmount;

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void debugPrintCartState() {
    debugPrint('🛒 Current Cart State:');
    debugPrint('   Cart ID: $cartId');
    debugPrint('   Restaurant ID: $restaurantId');
    debugPrint('   Restaurant Name: $restaurantName');
    debugPrint('   Item Count: $itemCount');
    debugPrint('   Subtotal: $subtotal');
    debugPrint('   Total Amount: $totalAmount');
    debugPrint('   Items: ${items.length}');
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      debugPrint('     Item $i:');
      debugPrint(
        '       cartItemId: ${item['cartItemId']} (${item['cartItemId'].runtimeType})',
      );
      debugPrint(
        '       itemMenuId: ${item['itemMenuId']} (${item['itemMenuId'].runtimeType})',
      );
      debugPrint(
        '       quantity: ${item['quantity']} (${item['quantity'].runtimeType})',
      );
      debugPrint('       menuItem name: ${item['menuItem']?['nama']}');
      debugPrint('       totalPrice: ${item['totalPrice']}');
      debugPrint('       Raw item data: $item');
    }
  }
}
