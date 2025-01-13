import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:vaayusphere/common/appbar.dart';

class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CommonAppBar(title: "VAAYU sphere"),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final pageTitle = _getTitleByIndex(controller.selectedIndex);
          switch (controller.selectedIndex) {
            case 0:
              return ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemBuilder: (context, index) => Container(
                  height: 100,
                  width: double.infinity,
                  margin:
                      const EdgeInsets.only(bottom: 10, right: 10, left: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).canvasColor,
                    boxShadow: const [BoxShadow()],
                  ),
                ),
              );
            default:
              return Center(
                child: Text(
                  pageTitle,
                  style: theme.textTheme.headlineSmall,
                ),
              );
          }
        },
      ),
    );
  }

  String _getTitleByIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'People';
      case 3:
        return 'Favorites';
      case 4:
        return 'Custom iconWidget';
      case 5:
        return 'Profile';
      case 6:
        return 'Settings';
      default:
        return 'Not found page';
    }
  }
}
