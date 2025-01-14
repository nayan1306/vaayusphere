import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:vaayusphere/common/appbar.dart';
import 'package:vaayusphere/providers/air_quality_provider.dart';
import 'package:vaayusphere/widgets/aqigaugecard.dart';
import 'package:vaayusphere/widgets/aqilinechart.dart';
import 'package:vaayusphere/widgets/infotile.dart';

class DashboardPlaceholder extends StatefulWidget {
  const DashboardPlaceholder({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  State<DashboardPlaceholder> createState() => _DashboardPlaceholderState();
}

class _DashboardPlaceholderState extends State<DashboardPlaceholder> {
  @override
  void initState() {
    super.initState();

    // Fetch air quality data when the widget is initialized
    Future.delayed(Duration.zero, () {
      final provider = Provider.of<ApiDataProvider>(context, listen: false);
      provider.fetchAndSetAirQualityData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CommonAppBar(
        title: _getTitleByIndex(widget.controller.selectedIndex),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          return const Padding(
            padding: EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AqiPm10InfoTile(),
                    SizedBox(width: 20),
                    AqiPm2InfoTile(),
                    SizedBox(width: 20),
                    SulphurDioxideInfoTile(),
                    SizedBox(width: 20),
                    NitrogenDioxideInfoTile(),
                    SizedBox(width: 30),
                    AqiGaugeCard()
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                AqiLineChart(),
              ],
            ),
          );
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
        return 'Custom Icon';
      case 5:
        return 'Profile';
      case 6:
        return 'Settings';
      default:
        return 'Not Found';
    }
  }
}
