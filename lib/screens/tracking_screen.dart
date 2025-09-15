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
    "Bus Terminal",
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
      busTop = 20; // initial bus position
      countdown = 30;
      distanceToNext = 2.0;
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown > 0) {
        setState(() {
          countdown--;
          distanceToNext = (distanceToNext - (2.0 / 30)).clamp(0.0, 2.0);

          // 👇 Jump bus to middle when countdown hits 15 sec (halfway)
          if (countdown == 15) {
            busTop = currentStopIndex * 120 + 20 + 60; // mid position
          }
        });
      } else {
        if (currentStopIndex < routeStops.length - 1) {
          setState(() {
            currentStopIndex++;
            busTop = currentStopIndex * 120 + 20; // snap to next stop
            countdown = 30;
            distanceToNext = 2.0;
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
        elevation: 0,
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
        // Source card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.my_location, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: source,
                    hint: const Text("Choose Source"),
                    underline: const SizedBox(),
                    items: locations
                        .map(
                          (loc) => DropdownMenuItem(
                            value: loc,
                            child: Text(
                              loc,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => source = val),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Swap button
        Center(
          child: IconButton(
            icon: const Icon(
              Icons.swap_vert_circle,
              size: 36,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              if (source != null && destination != null) {
                setState(() {
                  final temp = source;
                  source = destination;
                  destination = temp;
                });
              }
            },
          ),
        ),
        const SizedBox(height: 12),

        // Destination card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: destination,
                    hint: const Text("Choose Destination"),
                    underline: const SizedBox(),
                    items: locations
                        .map(
                          (loc) => DropdownMenuItem(
                            value: loc,
                            child: Text(
                              loc,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => destination = val),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Track button
        Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.directions_bus),
            label: const Text("Track Bus", style: TextStyle(fontSize: 16)),
            onPressed:
                (source != null &&
                        destination != null &&
                        source != destination &&
                        locations.indexOf(source!) <
                            locations.indexOf(destination!))
                    ? startTracking
                    : null,
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
                              : (isNextStop
                                  ? Colors.green.shade800
                                  : Colors.grey),
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
              crossAxisAlignment: CrossAxisAlignment.start, // align left
              children: [
                const Icon(
                  Icons.directions_bus,
                  size: 34,
                  color: Colors.redAccent,
                ),

                if (currentStopIndex < routeStops.length - 1)
                  Container(
                    margin: const EdgeInsets.only(top: 6, left: 40),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
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
