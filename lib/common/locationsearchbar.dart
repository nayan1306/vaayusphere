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
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 20),
            // Use TextButton for location search
            TextButton(
              onPressed: () => _openMapLocationPicker(context),
              child: Text(
                provider.selectedLocation,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.notifications,
                size: 40,
                color: Colors.white.withOpacity(0.5),
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                size: 40,
                color: Colors.white.withOpacity(0.5),
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.account_circle,
                size: 40,
                color: Colors.white.withOpacity(0.5),
              ),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }
}
