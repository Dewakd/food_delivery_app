import 'package:flutter/material.dart';

class BusinessHoursPage extends StatefulWidget {
  const BusinessHoursPage({super.key});

  @override
  State<BusinessHoursPage> createState() => _BusinessHoursPageState();
}

class _BusinessHoursPageState extends State<BusinessHoursPage> {
  TimeOfDay openTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay closeTime = const TimeOfDay(hour: 22, minute: 0);

  Future<void> _selectTime(bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? openTime : closeTime,
    );

    if (picked != null) {
      setState(() {
        if (isOpening) {
          openTime = picked;
        } else {
          closeTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Business Hours")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Open Time"),
              subtitle: Text(openTime.format(context)),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () => _selectTime(true),
              ),
            ),
            ListTile(
              title: const Text("Close Time"),
              subtitle: Text(closeTime.format(context)),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () => _selectTime(false),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // simpan atau kirim ke backend nanti di sini
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Jam operasional diperbarui")),
                );
              },
              child: const Text("Simpan Jam Operasional"),
            ),
          ],
        ),
      ),
    );
  }
}
