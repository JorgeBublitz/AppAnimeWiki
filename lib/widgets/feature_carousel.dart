import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anime/anime.dart';
import '../colors/app_colors.dart';
import '../screens/anime/anime_detail_screen.dart';

/// Carrossel de destaque da Home: visual cinematográfico, um único CTA e
/// indicador em barras finas (em vez de bolinhas), mais discreto.
class FeatureCarousel extends StatefulWidget {
  final List<Anime> animes;

  const FeatureCarousel({super.key, required this.animes});

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      final next = _currentPage < widget.animes.length - 1 ? _currentPage + 1 : 0;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animes.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.animes.length,
            itemBuilder: (context, index) => _HeroSlide(anime: widget.animes[index]),
          ),
        ),
        const SizedBox(height: 10),
        _Indicators(count: widget.animes.length, current: _currentPage),
      ],
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final Anime anime;
  const _HeroSlide({required this.anime});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AnimeDetailScreen(anime: anime)),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: anime.images.jpg.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.cor2),
                errorWidget:
                    (_, __, ___) => Container(
                      color: AppColors.cor2,
                      child: const Icon(Icons.broken_image_outlined, color: Colors.white54),
                    ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.accent3, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          anime.score.toString(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          anime.type,
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      anime.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

class _Indicators extends StatelessWidget {
  final int count;
  final int current;
  const _Indicators({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 6,
          height: 4,
          decoration: BoxDecoration(
            color: isActive ? AppColors.cor4 : AppColors.cor3,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
