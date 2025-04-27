import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({
    super.key,
    required SidebarXController controller,
  }) : _controller = controller;

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
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
            color: actionColor.withOpacity(0.37),
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
      headerBuilder: (context, extended) {
        return Row(
          children: [
            SizedBox(
              height: extended ? 100 : 70,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Image.asset('./assets/logo/logond.png'),
              ),
            ),
            if (extended)
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "VΛΛYU",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 10,
                        fontSize: 20),
                  ),
                  Text(
                    "sphere",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 10),
                  ),
                ],
              )
          ],
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
          icon: Icons.cloud_queue, // Icon for weather
          label: 'A Q I',
        ),
        const SidebarXItem(
          icon: Icons.wb_sunny, // Icon for weather
          label: 'W E A T H E R',
        ),
        const SidebarXItem(
          icon: Icons.thumb_up_alt_outlined, // Icon for Appraisal
          label: 'A P P R A I S A L',
        ),
        const SidebarXItem(
          icon: Icons.how_to_vote, // Icon for Vote
          label: 'C O M P L A I N T S',
        ),
        const SidebarXItem(
          icon: Icons.leaderboard_outlined, // Icon for Vote
          label: 'L E A D E R B O A R D',
        ),
        const SidebarXItem(
          icon: Icons.article, // Icon for News
          label: 'N E W S',
          // selectable: false,
          // onTap: () => _showDisabledAlert(context),
        ),
        const SidebarXItem(
          icon: Icons.trending_up_sharp, // Icon for Vote
          label: 'T R E N D S',
        ),
      ],
    );
  }

  // void _showDisabledAlert(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text(
  //         'Item disabled for selecting',
  //         style: TextStyle(color: Colors.black),
  //       ),
  //       backgroundColor: Colors.white,
  //     ),
  //   );
  // }
}

const primaryColor = Color.fromARGB(255, 32, 31, 51);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);
