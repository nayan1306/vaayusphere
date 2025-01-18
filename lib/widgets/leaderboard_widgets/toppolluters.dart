import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/glasscard.dart';
import 'package:vaayusphere/providers/apidataprovider.dart'; // Adjust import path

class TopPolluters extends StatelessWidget {
  const TopPolluters({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the air quality data from the provider
    final airQualityData = Provider.of<ApiDataProvider>(context).airQualityData;
    // log("Air quality data: $airQualityData");

    return SizedBox(
      width: 200,
      height: 200,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            airQualityData != null
                ? Text(
                    airQualityData['hourly']['us_aqi'][0].toString(),
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : Image.asset(
                    "./assets/gifs/air.gif",
                    width: 150,
                  ), // Show a loader while data is being fetched
            const SizedBox(height: 10),
            const Text(
              "AQI (PM10)",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
