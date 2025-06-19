import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../services/restaurant_service.dart';
import '../../../../providers/backend_cart_provider.dart';
import '../../cart/screens/cart_screen.dart';

class RestaurantProfileScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantProfileScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantProfileScreen> createState() =>
      _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState extends State<RestaurantProfileScreen> {
  Map<String, dynamic>? _restaurant;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> menuItems = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  void _reloadCartState() {
    final cartProvider = context.read<BackendCartProvider>();
    debugPrint('🍽️ Restaurant Profile - Reloading cart state');
    cartProvider.loadCart(restaurantId: widget.restaurantId);
  }

  Future<void> _loadRestaurantData() async {
    setState(() => _isLoading = true);

    try {
      // Load restaurant details and menu
      final restaurantData = await RestaurantService.getRestaurantDetails(
        widget.restaurantId,
      );

      setState(() {
        _restaurant = restaurantData;
        final rawMenuItems = restaurantData['menuItems'] as List?;
        menuItems = rawMenuItems?.cast<Map<String, dynamic>>() ?? [];
        _isLoading = false;
      });

      // Load cart for this restaurant only once after successful restaurant load
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _reloadCartState();
        });
      }
    } catch (e) {
      debugPrint('Error loading restaurant data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
          ? _buildErrorState()
          : _buildRestaurantProfile(),
      floatingActionButton: Consumer<BackendCartProvider>(
        builder: (context, cart, child) {
          if (!cart.hasCart || cart.itemCount == 0)
            return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            backgroundColor: Colors.orange,
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: Text(
              '${cart.itemCount} items - ${cart.formatCurrency(cart.totalPrice)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load restaurant',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRestaurantData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantProfile() {
    final restaurant = _restaurant!;

    return CustomScrollView(
      slivers: [
        // Restaurant Header
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl:
                      restaurant['urlGambar'] ??
                      'https://via.placeholder.com/400x300?text=Restaurant',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Restaurant Info
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant['nama'] ?? 'Unknown Restaurant',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurant['jenisMasakan'] ?? 'Various Cuisine',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            (restaurant['averageRating']?.toString() ??
                                restaurant['rating']?.toString() ??
                                '0.0'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (restaurant['deskripsi'] != null) ...[
                  Text(
                    restaurant['deskripsi'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildInfoRow(
                  Icons.location_on,
                  restaurant['alamat'] ?? 'Address not available',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.access_time,
                  restaurant['jamBuka'] ?? 'Hours not available',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.delivery_dining,
                  'Delivery: ${_formatCurrency(restaurant['biayaAntar'] ?? 0)}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.phone,
                  restaurant['telepon'] ?? 'Phone not available',
                ),
              ],
            ),
          ),
        ),

        // Menu Section Header
        SliverToBoxAdapter(
          child: Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              'Menu (${menuItems.length} items)',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),

        // Menu Items
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final menuItem = menuItems[index];
            return BackendMenuItemCard(
              menuItem: menuItem,
              restaurant: restaurant,
            );
          }, childCount: menuItems.length),
        ),

        // Bottom padding for floating action button
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}

class BackendMenuItemCard extends StatelessWidget {
  final Map<String, dynamic> menuItem;
  final Map<String, dynamic> restaurant;

  const BackendMenuItemCard({
    super.key,
    required this.menuItem,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = menuItem['isAvailable'] ?? true;
    final price = menuItem['harga'] ?? 0;
    final itemMenuId = menuItem['itemMenuId'].toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Menu item image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl:
                    menuItem['urlGambar'] ??
                    'https://via.placeholder.com/80x80?text=Food',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Menu item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem['nama'] ?? 'Unknown Item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (menuItem['deskripsi'] != null) ...[
                    Text(
                      menuItem['deskripsi'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isAvailable
                            ? Colors.grey[600]
                            : Colors.grey[400],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatCurrency(price),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? Colors.orange : Colors.grey,
                        ),
                      ),
                      if (isAvailable)
                        Consumer<BackendCartProvider>(
                          builder: (context, cart, child) {
                            final quantity = cart.getItemQuantity(itemMenuId);

                            if (quantity == 0) {
                              return ElevatedButton(
                                onPressed: () => _addToCart(context, cart),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Add',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            } else {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _updateQuantity(
                                      context,
                                      cart,
                                      quantity - 1,
                                    ),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    color: Colors.orange,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                  Text(
                                    quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _updateQuantity(
                                      context,
                                      cart,
                                      quantity + 1,
                                    ),
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.orange,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Not Available',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(
    BuildContext context,
    BackendCartProvider cart,
  ) async {
    try {
      final restaurantId = restaurant['restoranId']?.toString();
      if (restaurantId == null) {
        throw Exception('Restaurant ID not found');
      }

      final menuItemId = menuItem['itemMenuId']?.toString();
      if (menuItemId == null) {
        throw Exception('Menu item ID not found');
      }

      debugPrint('🍽️ Restaurant Profile - Adding item to cart:');
      debugPrint('   Restaurant ID: $restaurantId');
      debugPrint('   Menu Item ID: $menuItemId');
      debugPrint('   Menu Item Name: ${menuItem['nama']}');

      // Check if cart exists and is from different restaurant
      if (cart.hasCart && cart.isDifferentRestaurant(restaurantId)) {
        // Different restaurant - show confirmation dialog
        final shouldSwitchRestaurant = await _showRestaurantSwitchDialog(
          context,
          cart.restaurant!['nama'],
        );

        if (!shouldSwitchRestaurant) {
          return; // User cancelled
        }
      }

      // Add item to cart (auto-handles restaurant switching)
      final success = await cart.addToCart(
        restaurantId: restaurantId,
        menuItemId: menuItemId,
        quantity: 1,
      );

      if (success) {
        debugPrint('✅ Item added successfully to cart');
        Fluttertoast.showToast(
          msg: "${menuItem['nama']} added to cart",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        final errorMsg = cart.error ?? "Unknown error occurred";
        debugPrint('❌ Failed to add item to cart: $errorMsg');
        Fluttertoast.showToast(
          msg: "Failed to add item to cart: $errorMsg",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      debugPrint('❌ Exception in _addToCart: $e');
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<void> _updateQuantity(
    BuildContext context,
    BackendCartProvider cart,
    int newQuantity,
  ) async {
    try {
      final cartItem = cart.getCartItem(menuItem['itemMenuId'].toString());
      if (cartItem == null) {
        debugPrint(
          '❌ Cart item not found for menu item: ${menuItem['itemMenuId']}',
        );
        return;
      }

      // Ensure cartItemId is properly converted to string
      final cartItemId = cartItem['cartItemId'].toString();

      debugPrint('🔄 Restaurant Profile - Updating quantity:');
      debugPrint('   Cart Item ID: ${cartItem['cartItemId']}');
      debugPrint('   Cart Item ID type: ${cartItem['cartItemId'].runtimeType}');
      debugPrint('   Converted ID: $cartItemId');
      debugPrint('   Current Quantity: ${cartItem['quantity']}');
      debugPrint('   New Quantity: $newQuantity');

      bool success = false;

      if (newQuantity <= 0) {
        // Remove item from cart
        debugPrint('🗑️ Removing item from cart');
        success = await cart.removeFromCart(cartItemId);
      } else {
        // Update quantity
        debugPrint('🔄 Updating item quantity');
        success = await cart.updateCartItem(
          cartItemId: cartItemId,
          quantity: newQuantity,
        );
      }

      if (success) {
        debugPrint('✅ Quantity update successful');
      } else {
        debugPrint('❌ Quantity update failed: ${cart.error}');
        Fluttertoast.showToast(
          msg: "Failed to update quantity: ${cart.error ?? 'Unknown error'}",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      debugPrint('❌ Exception in _updateQuantity: $e');
      Fluttertoast.showToast(
        msg: "Error updating quantity: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<bool> _showRestaurantSwitchDialog(
    BuildContext context,
    String currentRestaurantName,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Switch Restaurant?'),
              content: Text(
                'You have items from "$currentRestaurantName" in your cart. Adding items from a different restaurant will clear your current cart. Do you want to continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Clear Cart & Continue'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}
