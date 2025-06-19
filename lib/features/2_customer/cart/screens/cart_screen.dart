import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/backend_cart_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/order_summary_widget.dart';
import '../../checkout/screens/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCart();
    });
  }

  void _loadCart() {
    final cartProvider = context.read<BackendCartProvider>();
    debugPrint('🛒 Cart Screen - Initializing');
    cartProvider.debugPrintCartState();
    cartProvider.loadCart(); // Load any available cart
  }

  Future<void> _refreshCart() async {
    final cartProvider = context.read<BackendCartProvider>();
    debugPrint('🔄 Cart Screen - Refreshing cart');
    await cartProvider.loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCart,
            tooltip: 'Refresh Cart',
          ),
        ],
      ),
      body: Consumer<BackendCartProvider>(
        builder: (context, cartProvider, child) {
          debugPrint('🛒 Cart Screen Build:');
          debugPrint('   Loading: ${cartProvider.isLoading}');
          debugPrint('   Has Cart: ${cartProvider.hasCart}');
          debugPrint('   Item Count: ${cartProvider.itemCount}');
          debugPrint('   Error: ${cartProvider.error}');

          if (cartProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  SizedBox(height: 16),
                  Text('Loading cart...'),
                ],
              ),
            );
          }

          if (cartProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${cartProvider.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshCart,
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

          if (!cartProvider.hasCart || cartProvider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Keranjang Kosong',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Mulai berbelanja dan tambahkan item ke keranjang Anda',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: const Text('Mulai Berbelanja'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Restaurant info
              if (cartProvider.restaurant != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.restaurant, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartProvider.restaurant!['nama'] ?? 'Restoran',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (cartProvider.restaurant!['alamat'] != null)
                              Text(
                                cartProvider.restaurant!['alamat'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Cart items
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    debugPrint(
                      '🛒 Rendering cart item $index: ${item['menuItem']?['nama']}',
                    );

                    return CartItemWidget(
                      cartItem: item,
                      onQuantityChanged: (newQuantity) async {
                        debugPrint('🔄 Quantity change requested:');
                        debugPrint('   Cart Item ID: ${item['cartItemId']}');
                        debugPrint(
                          '   Cart Item ID type: ${item['cartItemId'].runtimeType}',
                        );
                        debugPrint('   Current Quantity: ${item['quantity']}');
                        debugPrint('   New Quantity: $newQuantity');

                        // Ensure cartItemId is properly converted to string
                        final cartItemId = item['cartItemId'].toString();

                        if (newQuantity <= 0) {
                          debugPrint('🗑️ Removing item from cart');
                          await cartProvider.removeFromCart(cartItemId);
                        } else {
                          debugPrint('🔄 Updating quantity');
                          await cartProvider.updateCartItem(
                            cartItemId: cartItemId,
                            quantity: newQuantity,
                          );
                        }
                      },
                      onRemove: () async {
                        debugPrint('🗑️ Remove button pressed:');
                        debugPrint('   Cart Item ID: ${item['cartItemId']}');
                        debugPrint(
                          '   Cart Item ID type: ${item['cartItemId'].runtimeType}',
                        );

                        // Ensure cartItemId is properly converted to string
                        final cartItemId = item['cartItemId'].toString();
                        await cartProvider.removeFromCart(cartItemId);
                      },
                    );
                  },
                ),
              ),

              // Order summary and checkout
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    OrderSummaryWidget(
                      subtotal: cartProvider.subtotal,
                      deliveryFee: cartProvider.deliveryFee,
                      serviceFee: cartProvider.serviceFee,
                      total: cartProvider.totalAmount,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CheckoutScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Lanjut ke Checkout (${_formatCurrency(cartProvider.totalAmount)})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
