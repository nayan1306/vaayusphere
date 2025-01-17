import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/glasscard.dart';
import 'package:vaayusphere/providers/apidataprovider.dart'; // Adjust import path

class InfoTile extends StatelessWidget {
  const InfoTile({super.key});

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

class AqiPm10InfoTile extends StatelessWidget {
  const AqiPm10InfoTile({super.key});

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
                    airQualityData['hourly']['pm10'][0].toString(),
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

class AqiPm2InfoTile extends StatelessWidget {
  const AqiPm2InfoTile({super.key});

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
                    airQualityData['hourly']['pm2_5'][0].toString(),
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
              "AQI (PM 2.5)",
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

class NitrogenDioxideInfoTile extends StatelessWidget {
  const NitrogenDioxideInfoTile({super.key});

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
                    airQualityData['hourly']['nitrogen_dioxide'][0].toString(),
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
              "Nitorogen Dioxide",
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

class SulphurDioxideInfoTile extends StatelessWidget {
  const SulphurDioxideInfoTile({super.key});

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
                    airQualityData['hourly']['sulphur_dioxide'][0].toString(),
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
              "Sulphur Dioxide",
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
