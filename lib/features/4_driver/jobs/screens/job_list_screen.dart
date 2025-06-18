import 'package:flutter/material.dart';
import 'active_job_details_screen.dart';

class JobListPage extends StatefulWidget {
  const JobListPage({super.key});

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  List<Map<String, String>> jobs = [
    {'orderId': '1', 'pickup': 'Restoran A', 'destination': 'Jl. Melati 12'},
    {'orderId': '2', 'pickup': 'Restoran B', 'destination': 'Jl. Mawar 9'},
    {'orderId': '3', 'pickup': 'Restoran C', 'destination': 'Jl. Merpati 4'},
    {'orderId': '4', 'pickup': 'Restoran D', 'destination': 'Jl. Anggrek 20'},
  ];

  void _editJob(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit Order #${jobs[index]['orderId']}')),
    );
  }

  void _deleteJob(int index) {
    final orderId = jobs[index]['orderId'];
    setState(() {
      jobs.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order #$orderId telah dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pekerjaan Tersedia',
        style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, 
              ),
        ),
        backgroundColor: Color(0xFF88D66C),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: jobs.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada pekerjaan saat ini.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  color: const Color(0xFF88D66C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailPage(job: job),
                        ),
                      );
                    },
                    title: Text(
                      'Order #${job['orderId']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Ambil: ${job['pickup']} → Antar: ${job['destination']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Wrap(
                      spacing: 10,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFFF6FB7A)),
                          onPressed: () => _editJob(index),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteJob(index),
                          tooltip: 'Hapus',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}