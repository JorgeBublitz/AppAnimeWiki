import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/manga/manga.dart';
import '../../colors/app_colors.dart';

/// Card de mangá no mesmo padrão "pôster" do AnimeCard, para manter os dois
/// tipos de conteúdo visualmente consistentes em todo o app.
class MangaCard extends StatelessWidget {
  final Manga manga;
  final bool showRank;

  const MangaCard({super.key, required this.manga, this.showRank = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 2 / 3,
          child: Hero(
            tag: 'manga_${manga.malId}',
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: manga.images.jpg.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.cor2),
                    errorWidget:
                        (_, __, ___) => Container(
                          color: AppColors.cor2,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                  ),
                ),
                Positioned(top: 8, left: 8, child: _ScorePill(score: manga.score)),
                if (showRank)
                  Positioned(top: 8, right: 8, child: _RankBadge(rank: manga.rank)),
                if (manga.publishing)
                  const Positioned(bottom: 8, left: 8, child: _PublishingDot()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Altura fixa para o bloco de texto: evita que o título de 2 linhas
        // empurre o autor para fora da área visível do card.
        SizedBox(
          height: 32,
          child: Text(
            manga.title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          manga.author.isNotEmpty ? manga.author : ' ',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ScorePill extends StatelessWidget {
  final double score;
  const _ScorePill({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.accent3, size: 13),
          const SizedBox(width: 3),
          Text(
            score.toString(),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.cor4,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '#$rank',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PublishingDot extends StatelessWidget {
  const _PublishingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.4), width: 1.5),
      ),
    );
  }
}
