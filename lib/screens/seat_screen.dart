import 'package:flutter/material.dart';

class SeatScreen extends StatefulWidget {
  @override
  _SeatAvailabilityScreenState createState() => _SeatAvailabilityScreenState();
}

class _SeatAvailabilityScreenState extends State<SeatScreen> {
  final int rows = 8;

  // 0 = available, 1 = booked, 2 = selected
  late List<List<int>> seats;

  @override
  void initState() {
    super.initState();
    seats = List.generate(rows, (i) => List.generate(4, (j) => 0));

    // Mock booked seats
    seats[0][1] = 1;
    seats[2][2] = 1;
    seats[4][0] = 1;
  }

  void toggleSeat(int i, int j) {
    setState(() {
      if (seats[i][j] == 0) {
        seats[i][j] = 2; // select
      } else if (seats[i][j] == 2) {
        seats[i][j] = 0; // unselect
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int selectedCount = seats.fold(
      0,
      (prev, row) => prev + row.where((s) => s == 2).length,
    );
    int fare = selectedCount * 50; // ₹50 per seat

    return Scaffold(
      appBar: AppBar(title: Text("Seat Availability")),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text("Tap a seat to select", style: TextStyle(fontSize: 16)),

          SizedBox(height: 20),

          // Driver seat
          Icon(Icons.event_seat, size: 40, color: Colors.black),
          Text("Driver", style: TextStyle(fontSize: 12)),

          SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: rows,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildSeat(i, 0),
                      SizedBox(width: 10),
                      buildSeat(i, 1),
                      SizedBox(width: 30), // aisle gap
                      buildSeat(i, 2),
                      SizedBox(width: 10),
                      buildSeat(i, 3),
                    ],
                  ),
                );
              },
            ),
          ),

          // 🔵 Legend Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                legendItem(Colors.green, "Available"),
                legendItem(Colors.red, "Booked"),
                legendItem(Colors.blue, "Selected"),
              ],
            ),
          ),

          // Bottom fare summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Text("Selected: $selectedCount | Fare: ₹$fare",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: selectedCount > 0 ? () {} : null,
                  child: Text("Confirm Booking"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildSeat(int i, int j) {
    int state = seats[i][j];

    Color color;
    if (state == 0) color = Colors.green; // available
    else if (state == 1) color = Colors.red; // booked
    else color = Colors.blue; // selected

    return GestureDetector(
      onTap: state != 1 ? () => toggleSeat(i, j) : null,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            "${i + 1}${String.fromCharCode(65 + j)}",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
