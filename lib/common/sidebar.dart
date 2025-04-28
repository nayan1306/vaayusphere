import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class ExampleSidebarX extends StatefulWidget {
  const ExampleSidebarX({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  State<ExampleSidebarX> createState() => _ExampleSidebarXState();
}

class _ExampleSidebarXState extends State<ExampleSidebarX> {
  bool isFullyExtended = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleSidebarChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleSidebarChange);
    super.dispose();
  }

  void _handleSidebarChange() {
    if (mounted) {
      setState(() {
        isFullyExtended = widget.controller.extended;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: widget.controller,
      headerDivider: const Divider(
        color: Colors.white10,
      ),
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor,
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 300,
        decoration: BoxDecoration(
          color: canvasColor,
        ),
      ),
      footerDivider: divider,
      footerBuilder: (context, extended) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                extended ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (extended)
                const Text(
                  'Developed by Nayan Verma',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 4),
              if (extended)
                Row(
                  children: [
                    Text(
                      '© 2025 TuringSphere',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Image.asset(
                      "assets/AppIcons/turingsphere.png",
                      width: 20,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
      headerBuilder: (context, extended) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:
                extended ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isFullyExtended ? 80 : 40,
                height: isFullyExtended ? 80 : 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/logo/logond.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if (extended) const SizedBox(width: 12),
              if (extended)
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "YΛΛYU",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 10,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "sphere",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 10,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.dashboard,
          label: 'D A S H B O A R D',
          onTap: () {
            debugPrint('Home');
          },
        ),
        const SidebarXItem(
          icon: Icons.cloud_queue,
          label: 'A Q I',
        ),
        const SidebarXItem(
          icon: Icons.wb_sunny,
          label: 'W E A T H E R',
        ),
        const SidebarXItem(
          icon: Icons.thumb_up_alt_outlined,
          label: 'A P P R A I S A L',
        ),
        const SidebarXItem(
          icon: Icons.how_to_vote,
          label: 'C O M P L A I N T S',
        ),
        const SidebarXItem(
          icon: Icons.leaderboard_outlined,
          label: 'L E A D E R B O A R D',
        ),
        const SidebarXItem(
          icon: Icons.article,
          label: 'N E W S',
        ),
        const SidebarXItem(
          icon: Icons.park_outlined,
          label: 'P L A N T A T I O N',
        ),
      ],
    );
  }
}

// Colors and Constants
const primaryColor = Color.fromARGB(255, 32, 31, 51);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);
