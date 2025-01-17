import 'package:flutter/material.dart';
import 'package:animated_cards_carousel/animated_cards_carousel.dart';
import 'package:vaayusphere/widgets/news_widgets/newsglasscard.dart';

class NewsList extends StatelessWidget {
  const NewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.8,
      child: AnimatedCardsCarousel(
        cardAspectRatio: 6,
        cardsList: List.generate(
            100,
            (index) => const NewsGlassCard(
                  headline: 'Breaking News: Flutter Rocks!',
                  description:
                      'Flutter continues to revolutionize the mobile development world with its rich set of features and cross-platform capabilities,Flutter continues to revolutionize the mobile development world with its rich set of features and cross-platform capabilities,Flutter continues to revolutionize the mobile development world with its rich set of features and cross-platform capabilities',
                  imageUrl:
                      'https://plus.unsplash.com/premium_photo-1707080369554-359143c6aa0b?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTd8fG5ld3N8ZW58MHx8MHx8fDA%3D', // Dummy image URL
                )),
      ),
    );
  }
}
