import 'package:flutter/material.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/glasscard.dart';
import 'package:animated_list_item/animated_list_item.dart';

class InfoFocusCard extends StatefulWidget {
  const InfoFocusCard({super.key});

  @override
  _InfoFocusCardState createState() => _InfoFocusCardState();
}

class _InfoFocusCardState extends State<InfoFocusCard>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  List list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );
    animationController.forward();
  }

  ClipRRect item(int index) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(10), // Rounded corners for the container
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(151, 197, 199, 198),
          borderRadius: BorderRadius.circular(10), // Same radius as ClipRRect
        ),
        margin: const EdgeInsets.all(8),
        padding:
            const EdgeInsets.all(16), // Adjusted padding for better spacing
        alignment: Alignment.center,
        child: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align items to the start
          mainAxisSize: MainAxisSize.min, // Minimize the height of the column
          children: [
            // Headline Text
            Text(
              "Focus News !!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 45, 42, 42),
              ),
            ),
            SizedBox(height: 8), // Spacing between headline and description

            // Description Text
            Text(
              "Random text about the news which is going to come in here, this is going to be a super cool headline",
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(179, 0, 0, 0),
              ),
              maxLines: 2, // Limit the number of lines
              overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width * 0.3,
      height: height * 0.8,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "IN FOCUS",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 10),
            ),
            const Divider(),
            SizedBox(
              height: height * 0.71,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return AnimatedListItem(
                    index: index,
                    length: 20,
                    aniController: animationController,
                    animationType: AnimationType.zoom,
                    child: item(index),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
