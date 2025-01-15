import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/glasscard.dart';
import 'package:vaayusphere/providers/apidataprovider.dart'; // Adjust import path
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationCard extends StatefulWidget {
  const LocationCard({super.key});

  @override
  _LocationCardState createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  String _address = "Fetching location...";
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    fetchAddress(); // Start fetching address on initialization
  }

  Future<void> fetchAddress() async {
    final apiProvider = Provider.of<ApiDataProvider>(context, listen: false);
    final location = apiProvider.currentLocation;

    if (location != null) {
      setState(() {
        _isFetching = true;
      });

      try {
        const apiKey =
            "a891126c33364916a6eb3ce37611d32d"; // Replace with your OpenCage API key
        final url =
            "https://api.opencagedata.com/geocode/v1/json?q=${location.latitude},${location.longitude}&key=$apiKey";

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            setState(() {
              _address = data['results'][0]['formatted'];
            });
          } else {
            setState(() {
              _address = "Address not found";
            });
          }
        } else {
          setState(() {
            _address = "Error fetching address";
          });
        }
      } catch (e) {
        setState(() {
          _address = "Error fetching address";
        });
      } finally {
        setState(() {
          _isFetching = false;
        });
      }
    } else {
      setState(() {
        _address = "Location unavailable";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiDataProvider>(context);
    final airQualityData = apiProvider.airQualityData;

    return SizedBox(
      width: 300,
      height: 150,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display reverse-geocoded address or status message
            _isFetching
                ? const CircularProgressIndicator()
                : Text(
                    _address,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
