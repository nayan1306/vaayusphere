import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YΛΛYU sphere'),
      ),
      body: Column(
        children: [
          Image.asset(
            "assets/logo/logo.png",
            width: 150,
          ),
          const Center(
            child: Text('Welcome to YΛΛYU sphere!'),
          ),
        ],
      ),
    );
  }
}
