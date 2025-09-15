import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final List<String> stops = [
    "Central Mall",
    "Market Road",
    "City Hospital",
    "Station",
    "Airport"
  ];

  String? source;
  String? destination;
  double fare = 0;

  final List<Map<String, dynamic>> ticketHistory = [];

  void _calculateFare() {
    if (source != null && destination != null) {
      int sIndex = stops.indexOf(source!);
      int dIndex = stops.indexOf(destination!);

      if (sIndex != -1 && dIndex != -1 && dIndex > sIndex) {
        setState(() {
          fare = (dIndex - sIndex) * 10; // ₹10 per stop
        });
      } else {
        setState(() {
          fare = 0;
        });
      }
    }
  }

  void _bookTicket() {
    if (fare > 0) {
      final ticket = {
        "source": source,
        "destination": destination,
        "fare": fare,
        "time": TimeOfDay.now().format(context),
      };

      setState(() {
        ticketHistory.insert(0, ticket);
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("✅ Payment Successful"),
          content: Text(
              "Ticket booked from $source to $destination\nFare: ₹$fare"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dummyPaymentLink =
        "upi://pay?pa=test@upi&pn=SmartBus&am=$fare&cu=INR";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Ticketing"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Source & Destination
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: source,
                      hint: const Text("Select Source"),
                      items: stops
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          source = val;
                        });
                        _calculateFare();
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Source",
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: destination,
                      hint: const Text("Select Destination"),
                      items: stops
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          destination = val;
                        });
                        _calculateFare();
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Destination",
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fare > 0 ? "Fare: ₹$fare" : "Select valid route",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: fare > 0 ? Colors.green : Colors.red,
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // QR Code
            if (fare > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: dummyPaymentLink,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),

            const SizedBox(height: 20),

            // Book Button
            ElevatedButton.icon(
              onPressed: _bookTicket,
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text("Book Ticket"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Ticket History
            if (ticketHistory.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🎟️ Your Last Tickets",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...ticketHistory.map((t) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.directions_bus),
                          title: Text("${t['source']} → ${t['destination']}"),
                          subtitle:
                              Text("Fare: ₹${t['fare']} • Time: ${t['time']}"),
                        ),
                      )),
                ],
              )
          ],
        ),
      ),
    );
  }
}
