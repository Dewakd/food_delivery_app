import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double deliveryFee;
  final double subtotal;
  final double discount;
  final double total;
  final String paymentMethod;
  final String orderId;

  const OrderConfirmationScreen({
    super.key,
    required this.cartItems,
    required this.deliveryFee,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    this.orderId = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF88D66C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.lightBlue,
              size: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              'Terima kasih atas pesanan Anda!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (orderId.isNotEmpty) ...[
              Text(
                'Order ID: $orderId',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Metode Pembayaran: $paymentMethod',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Rincian Pesanan:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...cartItems.map(
                    (item) => ListTile(
                      title: Text(item['name']),
                      trailing: Text(
                        '${item['quantity']} x Rp ${item['price']} = Rp ${item['quantity'] * item['price']}',
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Subtotal'),
                    trailing: Text('Rp ${subtotal.toStringAsFixed(0)}'),
                  ),
                  ListTile(
                    title: const Text('Biaya Pengiriman'),
                    trailing: Text('Rp ${deliveryFee.toStringAsFixed(0)}'),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      'Rp ${total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF88D66C),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 40,
                ),
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
