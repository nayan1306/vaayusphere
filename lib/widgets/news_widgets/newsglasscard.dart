import 'dart:ui';
import 'package:flutter/material.dart';

class NewsGlassCard extends StatelessWidget {
  final String headline;
  final String description;
  final String imageUrl;

  const NewsGlassCard({
    super.key,
    required this.headline,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            spreadRadius: 5.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // News Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    imageUrl,
                    width: MediaQuery.of(context).size.width * 0.15,
                    height: MediaQuery.of(context).size.height * 0.25,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 10,
                  width: 20,
                ),

                // Headline and Description wrapped in Expanded
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 6,
                      ),
                      // Headline
                      Text(
                        headline,
                        style: const TextStyle(
                          fontSize:
                              18, // Reduced size to fit within constraints
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 242, 242),
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis, // Prevent overflow
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(182, 214, 214, 214),
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis, // Prevent overflow
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
