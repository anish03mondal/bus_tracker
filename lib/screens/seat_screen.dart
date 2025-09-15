import 'package:flutter/material.dart';

class SeatScreen extends StatelessWidget {
  const SeatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seat Availability"),
        backgroundColor: Colors.purple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _seatStatus("Bus 12A", "Low Occupancy", Colors.green),
          _seatStatus("Bus 18B", "Medium Occupancy", Colors.orange),
          _seatStatus("Bus 22C", "Full", Colors.red),
        ],
      ),
    );
  }

  Widget _seatStatus(String bus, String status, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.directions_bus, size: 32),
        title: Text(bus, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(status),
        trailing: CircleAvatar(
          backgroundColor: color,
          radius: 10,
        ),
      ),
    );
  }
}
