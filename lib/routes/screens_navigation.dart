import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:vaayusphere/screens/dashboard.dart';
import 'package:vaayusphere/screens/weather.dart';

class ScreensExample extends StatelessWidget {
  const ScreensExample({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pageTitle = _getTitleByIndex(controller.selectedIndex);
        switch (controller.selectedIndex) {
          case 0:
            return Center(child: DashboardPlaceholder(controller: controller));
          case 1:
            return Center(
                child: WeatherScreenPlaceHolder(controller: controller));
          default:
            return Text(
              pageTitle,
              style: theme.textTheme.headlineSmall,
            );
        }
      },
    );
  }

  String _getTitleByIndex(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Weather';
      case 2:
        return 'Vote';
      case 3:
        return 'News';
      case 4:
        return 'Trends';
      case 5:
        return 'Leaderboard';
      case 6:
        return 'Settings';
      default:
        return 'Not found page';
    }
  }
}
