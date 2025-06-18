import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/2_customer/checkout/screens/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final ValueChanged<List<Map<String, dynamic>>> onUpdate;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onUpdate,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> _items;
  final double deliveryFee = 10000; // Contoh ongkos kirim tetap

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.cartItems);
  }

  void increment(int index) {
    setState(() {
      _items[index]['quantity']++;
    });
  }

  void decrement(int index) {
    setState(() {
      if (_items[index]['quantity'] > 1) {
        _items[index]['quantity']--;
      } else {
        _items.removeAt(index);
      }
    });
  }

  void remove(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void updateInstructions(int index, String newInstructions) {
    setState(() {
      _items[index]['instructions'] = newInstructions;
    });
  }

  double get subtotal {
    double total = 0;
    for (var item in _items) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  double get total {
    return subtotal + (_items.isNotEmpty ? deliveryFee : 0);
  }

  @override
  void dispose() {
    widget.onUpdate(_items);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF88D66C),
      ),
      body: _items.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        var item = _items[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade100,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['name'],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: Colors.redAccent,
                                    iconSize: 28,
                                    tooltip: 'Kurangi',
                                    onPressed: () => decrement(index),
                                  ),
                                  Text(
                                    '${item['quantity']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Color(0xFF88D66C),
                                    iconSize: 28,
                                    tooltip: 'Tambah',
                                    onPressed: () => increment(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.grey.shade700,
                                    iconSize: 28,
                                    tooltip: 'Hapus',
                                    onPressed: () => remove(index),
                                  ),
                                ],
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Catatan khusus',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                ),
                                maxLines: 2,
                                controller: TextEditingController.fromValue(
                                  TextEditingValue(
                                    text: item['instructions'] ?? '',
                                    selection: TextSelection.collapsed(offset: (item['instructions'] ?? '').length),
                                  ),
                                ),
                                onChanged: (value) => updateInstructions(index, value),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
                // ----- Order summary -----
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal',
                              style: TextStyle(fontSize: 16)),
                          Text('Rp ${subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Biaya Pengiriman',
                              style: TextStyle(fontSize: 16)),
                          Text(_items.isNotEmpty ? 'Rp ${deliveryFee.toStringAsFixed(0)}' : 'Rp 0',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('Rp ${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _items.isEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutScreen(
                                      cartItems: _items,
                                      deliveryFee: deliveryFee,
                                      subtotal: subtotal,
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 26),
                          backgroundColor: Color(0xFF88D66C),
                        ),
                        child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold , color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}