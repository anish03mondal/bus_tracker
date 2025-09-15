import 'dart:async';
import 'package:flutter/material.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String? source;
  String? destination;
  bool showRoute = false;

  final List<String> locations = [
    "Airport",
    "Tech Park",
    "City Center",
    "Central Mall",
    "Market Road",
    "University",
    "Railway Station",
    "Bus Terminal"
  ];

  Timer? timer;
  int currentStopIndex = 0;
  List<String> routeStops = [];
  double busTop = 0.0;

  int countdown = 30; // 30 sec per stop
  double distanceToNext = 2.0; // 2 km between stops

  void startTracking() {
    int start = locations.indexOf(source!);
    int end = locations.indexOf(destination!);

    if (start < 0 || end < 0) return;

    setState(() {
      showRoute = true;
      currentStopIndex = 0;
      routeStops = locations.sublist(start, end + 1);
      busTop = 20;
      countdown = 30;
      distanceToNext = 2.0; // reset distance
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown > 0) {
        setState(() {
          countdown--;
          distanceToNext = (distanceToNext - (2.0 / 30)).clamp(0.0, 2.0);
        });
      } else {
        if (currentStopIndex < routeStops.length - 1) {
          setState(() {
            currentStopIndex++;
            busTop = currentStopIndex * 120 + 20;
            countdown = 30;
            distanceToNext = 2.0; // reset distance for next stop
          });
        } else {
          t.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "$m:${s.toString().padLeft(2, '0')} min";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Bus Tracking"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: showRoute ? _buildRouteView() : _buildSelectionView(),
      ),
    );
  }

  Widget _buildSelectionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Source:", style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: source,
          hint: const Text("Choose Source"),
          items: locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
          onChanged: (val) => setState(() => source = val),
        ),
        const SizedBox(height: 16),
        const Text("Select Destination:", style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: destination,
          hint: const Text("Choose Destination"),
          items: locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
          onChanged: (val) => setState(() => destination = val),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: (source != null &&
                    destination != null &&
                    source != destination &&
                    locations.indexOf(source!) < locations.indexOf(destination!))
                ? startTracking
                : null,
            child: const Text("Track Bus"),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteView() {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Stops list
          ListView.builder(
            itemCount: routeStops.length,
            itemBuilder: (context, index) {
              bool reached = index < currentStopIndex;
              bool isNextStop = index == currentStopIndex + 1;

              return SizedBox(
                height: 120,
                child: Stack(
                  children: [
                    if (index < routeStops.length - 1)
                      Positioned(
                        left: 28,
                        top: 40,
                        bottom: 0,
                        child: Container(width: 3, color: Colors.grey.shade300),
                      ),
                    Positioned(
                      left: 10,
                      top: 20,
                      child: Icon(
                        Icons.location_on,
                        size: 30,
                        color: reached
                            ? Colors.blueAccent
                            : (isNextStop ? Colors.green : Colors.grey),
                      ),
                    ),
                    Positioned(
                      left: 60,
                      top: 25,
                      child: Text(
                        routeStops[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: reached
                              ? Colors.black
                              : (isNextStop ? Colors.green.shade800 : Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Bus icon + floating label
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            left: -5,
            top: busTop,
            child: Column(
              children: [
                const Icon(Icons.directions_bus,
                    size: 34, color: Colors.redAccent),
                if (currentStopIndex < routeStops.length - 1)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "🚍 ${distanceToNext.toStringAsFixed(1)} km to ${routeStops[currentStopIndex + 1]} | ETA ${formatTime(countdown)}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
