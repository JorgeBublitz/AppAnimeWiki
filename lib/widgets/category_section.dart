import 'package:flutter/material.dart';
import '../models/anime/anime.dart';
import '../models/manga/manga.dart';
import '../widgets/cards_anime/anime_card.dart';
import '../widgets/cards_manga/manga_card.dart';
import '../screens/anime/anime_detail_screen.dart';
import '../screens/manga/manga_detail_screen.dart';

/// Grade de descoberta usada na Home: reaproveita o mesmo AnimeCard/MangaCard
/// "pôster" das outras seções, em vez de um estilo de card próprio — reduz a
/// quantidade de padrões visuais diferentes na mesma tela.
class CategorySection extends StatelessWidget {
  final List<dynamic> items;
  final bool isAnime;

  const CategorySection({super.key, required this.items, required this.isAnime});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.56,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          isAnime
                              ? AnimeDetailScreen(anime: item as Anime)
                              : MangaDetailScreen(manga: item as Manga),
                ),
              );
            },
            child: isAnime ? AnimeCard(anime: item as Anime) : MangaCard(manga: item as Manga),
          );
        },
      ),
    );
  }
}
