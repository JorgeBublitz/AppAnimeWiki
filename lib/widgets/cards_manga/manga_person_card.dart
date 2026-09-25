// anime_person_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/manga/manga_person.dart';
import '../../colors/app_colors.dart';
import '../../screens/manga/manga_person_detail_screen.dart';

class MangaPersonCard extends StatelessWidget {
  final MangaPerson personManga;
  final bool compactMode;
  final VoidCallback? onTap;

  const MangaPersonCard({
    super.key,
    required this.personManga,
    this.compactMode = false,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final double cardWidth = compactMode ? 100 : 140;
    return SizedBox(
      width: cardWidth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap:
              onTap ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            MangaPersonDetailScreen(mangaPerson: personManga),
                  ),
                );
              },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: personManga.character.malId,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: personManga.character.images.jpg.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: AppColors.cor2),
                          errorWidget:
                              (_, __, ___) => Container(
                                color: AppColors.cor1,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black],
                              ),
                            ),
                            child: Text(
                              personManga.character.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
