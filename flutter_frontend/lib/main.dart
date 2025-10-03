import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BeautyLMSApp());
}

class BeautyLMSApp extends StatelessWidget {
  const BeautyLMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beauty LMS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
