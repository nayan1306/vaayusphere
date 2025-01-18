import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';
import 'package:vaayusphere/widgets/appraisal_widgets/maplocationpicker.dart';

class LocationSearchBar extends StatelessWidget {
  const LocationSearchBar({super.key});

  void _openMapLocationPicker(BuildContext context) {
    if (kIsWeb) {
      // Show as a popup on the web
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: SizedBox(
              width: 800, // Set desired width for the popup
              height: 600, // Set desired height for the popup
              child: MapLocationPicker(),
            ),
          );
        },
      );
    } else {
      // Navigate to a new page for other platforms
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MapLocationPicker()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiDataProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white60,
            borderRadius:
                BorderRadius.circular(10), // Rounded borders applied here
          ),
          margin: const EdgeInsets.all(1),
          width: 100,
          height: 45,
          child: Row(
            children: [
              const SizedBox(width: 20),
              // Use TextButton for location search
              const Icon(
                Icons.search,
                color: Colors.black,
              ),
              TextButton(
                onPressed: () => _openMapLocationPicker(context),
                child: Text(
                  provider.selectedLocation,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 36, 36, 36),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
