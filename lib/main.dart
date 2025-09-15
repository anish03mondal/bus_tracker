import 'package:bus_tracking/screens/ticketing_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/sms_screen.dart';
//import 'screens/ticket_screen.dart';
import 'screens/seat_screen.dart';
import 'screens/alert_screen.dart';

void main() {
  runApp(const SmartBusApp());
}

class SmartBusApp extends StatelessWidget {
  const SmartBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Bus Prototype',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
      routes: {
        "/tracking": (context) => const TrackingScreen(),
        "/sms": (context) => const SmsScreen(),
        "/ticket": (context) => const TicketScreen(),
        "/seat": (context) => const SeatScreen(),
        "/alert": (context) => const AlertScreen(),
      },
    );
  }
}
