import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TelemedIAApp());
}

class TelemedIAApp extends StatelessWidget {
  const TelemedIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TelemedIA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
