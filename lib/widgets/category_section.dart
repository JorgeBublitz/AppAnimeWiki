import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/anime/anime.dart';
import '../models/manga/manga.dart';
import '../colors/app_colors.dart';
import '../screens/anime/anime_detail_screen.dart';
import '../screens/manga/manga_detail_screen.dart';

class CategorySection extends StatelessWidget {
  final List<dynamic> items;
  final bool isAnime;

  const CategorySection({
    super.key,
    required this.items,
    required this.isAnime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildGridItem(context, item);
        },
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, dynamic item) {
    final title = isAnime ? (item as Anime).title : (item as Manga).title;
    final imageUrl =
        isAnime
            ? (item as Anime).images.jpg.imageUrl
            : (item as Manga).images.jpg.imageUrl;
    final score = isAnime ? (item as Anime).score : (item as Manga).score;

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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder:
                    (_, __) => Container(
                      color: AppColors.cor2,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.cor4,
                        ),
                      ),
                    ),
                errorWidget:
                    (_, __, ___) => Container(
                      color: AppColors.cor1,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      // Adicionado Flexible aqui
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          score.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cor4,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAnime ? 'Anime' : 'Mangá',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
