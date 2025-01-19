import 'package:flutter/material.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/glasscard.dart';

class TopPolluters extends StatelessWidget {
  const TopPolluters({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.83,
      height: MediaQuery.of(context).size.height * 0.42,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Column(
              children: [
                Column(
                  children: [
                    GlassCard(
                      child: Text(
                        "Top Polluted Locations",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.26,
                  height: MediaQuery.of(context).size.height * 0.29,
                  child: GlassCard(
                      child: Column(
                    children: [
                      const Text(
                        "GLOBAL",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                          height:
                              15), // Adds some spacing between the text and the list

                      ListBody(
                        children: List.generate(3, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 10.0), // Adds spacing between items
                            child: GlassCard(
                              child: Text("data ${index + 1}"),
                            ),
                          );
                        }),
                      )
                    ],
                  )),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.01,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.26,
                  height: MediaQuery.of(context).size.height * 0.29,
                  child: GlassCard(
                      child: Column(
                    children: [
                      const Text(
                        "NATIONAL",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                          height:
                              15), // Adds some spacing between the text and the list

                      ListBody(
                        children: List.generate(3, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 10.0), // Adds spacing between items
                            child: GlassCard(
                              child: Text("data ${index + 1}"),
                            ),
                          );
                        }),
                      )
                    ],
                  )),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.01,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.26,
                  height: MediaQuery.of(context).size.height * 0.29,
                  child: GlassCard(
                      child: Column(
                    children: [
                      const Text(
                        "CITY",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                          height:
                              15), // Adds some spacing between the text and the list

                      ListBody(
                        children: List.generate(3, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 10.0), // Adds spacing between items
                            child: GlassCard(
                              child: Text("data ${index + 1}"),
                            ),
                          );
                        }),
                      )
                    ],
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
