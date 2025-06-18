import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailPage extends StatelessWidget {
  final Map? job;

  const JobDetailPage({super.key, this.job});

  void _openMaps(String location) async {
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = job ?? ModalRoute.of(context)?.settings.arguments as Map?;

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text("Data order tidak tersedia")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: Text('Order #${data['orderId']}',style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, 
            ),
          ),
        backgroundColor: Color(0xFF88D66C), 
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Lokasi Penjemputan'),
            _locationCard(
              icon: Icons.store,
              label: data['pickup'],
              onTap: () => _openMaps(data['pickup']),
              buttonText: 'Navigasi ke Restoran',
              color: const Color(0xFF88D66C),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Lokasi Pengantaran'),
            _locationCard(
              icon: Icons.home,
              label: data['destination'],
              onTap: () => _openMaps(data['destination']),
              buttonText: 'Navigasi ke Pelanggan',
              color: const Color(0xFF73BBA3),
            ),
            const SizedBox(height: 32),
            _sectionTitle('Perbarui Status'),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                _statusButton('Sudah Diambil', const Color(0xFF88D66C)),
                _statusButton('Sudah Dikirim', const Color(0xFF73BBA3)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF264653),
      ),
    );
  }

  Widget _locationCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required String buttonText,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.map),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () {

      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }
}