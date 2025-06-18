import 'package:flutter/material.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double deliveryFee;
  final double subtotal;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.deliveryFee,
    required this.subtotal,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController promoController = TextEditingController();
  String selectedPaymentMethod = 'Cash on Delivery';
  double discount = 0;

  double get total {
    return widget.subtotal + widget.deliveryFee - discount;
  }

  void applyPromo() {
    String code = promoController.text.trim().toUpperCase();
    if (code == 'PROMO10') {
      setState(() {
        discount = 0.1 * widget.subtotal; // Diskon 10%
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode promo berhasil diterapkan!')),
      );
    } else {
      setState(() {
        discount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode promo tidak valid')),
      );
    }
  }

  void confirmOrder() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(
          cartItems: widget.cartItems,
          deliveryFee: widget.deliveryFee,
          subtotal: widget.subtotal,
          discount: discount,
          total: total,
          paymentMethod: selectedPaymentMethod,
        ),
      ),
    );
  }

  @override
  void dispose() {
    promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF88D66C)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Ringkasan Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  ...widget.cartItems.map(
                    (item) => ListTile(
                      title: Text(item['name']),
                      trailing: Text(
                          '${item['quantity']} x Rp ${item['price']} = Rp ${item['quantity'] * item['price']}'),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Subtotal'),
                    trailing: Text('Rp ${widget.subtotal.toStringAsFixed(0)}'),
                  ),
                  ListTile(
                    title: const Text('Biaya Pengiriman'),
                    trailing: Text('Rp ${widget.deliveryFee.toStringAsFixed(0)}'),
                  ),
                  ListTile(
                    title: const Text('Diskon'),
                    trailing: Text('Rp ${discount.toStringAsFixed(0)}'),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text('Rp ${total.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: promoController,
                    decoration: InputDecoration(
                      labelText: 'Kode Promo',
                      suffixIcon: TextButton(
                        child: const Text('Gunakan'),
                        onPressed: applyPromo,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Metode Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  RadioListTile<String>(
                    title: const Text('Cash on Delivery (COD)'),
                    value: 'Cash on Delivery',
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: confirmOrder,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Color(0xFF88D66C),
                    ),
                    child: const Text('Konfirmasi Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold , color: Colors.black)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}