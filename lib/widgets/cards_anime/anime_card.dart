import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/anime/anime.dart';
import '../../colors/app_colors.dart';

class AnimeCard extends StatefulWidget {
  final Anime anime;
  final bool showRank;

  const AnimeCard({super.key, required this.anime, this.showRank = false});

  @override
  State<AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends State<AnimeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.01,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });

    if (isHovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    _isHovering
                        ? AppColors.cor4.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.3),
                blurRadius: _isHovering ? 12 : 8,
                offset: const Offset(0, 5),
                spreadRadius: _isHovering ? 2 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Imagem do anime
                Positioned.fill(
                  child: Hero(
                    tag: 'anime_${widget.anime.malId}',
                    child: CachedNetworkImage(
                      imageUrl: widget.anime.images.jpg.imageUrl,
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
                  ),
                ),

                // Gradiente overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                          Colors.black.withValues(alpha: 0.9),
                        ],
                        stops: const [0.0, 0.6, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),

                // TÃ­tulo e informaÃ§Ãµes
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.anime.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.anime.score.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (widget.anime.episodes != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cor4.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${widget.anime.episodes} eps',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Status indicator
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.anime.status),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _getStatusText(widget.anime.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

                // Rank badge
                if (widget.showRank)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cor4,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '#${widget.anime.rank}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'currently airing':
        return Colors.green;
      case 'finished airing':
        return Colors.blue;
      case 'not yet aired':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'currently airing':
        return 'EM EXIBIÇÃO';
      case 'finished airing':
        return 'COMPLETO';
      case 'not yet aired':
        return 'EM BREVE';
      default:
        return status.toUpperCase();
    }
  }
}
