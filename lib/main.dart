import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaayusphere/providers/air_quality_provider.dart';
import 'package:vaayusphere/screens/homescreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures proper initialization
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiDataProvider()),
      ],
      child: HomeScreen(), // Your root widget
    ),
  );
}
