import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/anime/anime.dart';
import '../../colors/app_colors.dart';
import '../../api/api_service.dart';
import 'all_characters_screen_anime.dart';
import '../../widgets/cards_anime/anime_person_card.dart';
import '../../models/anime/anime_person.dart';

class AnimeDetailScreen extends StatefulWidget {
  final Anime anime;
  const AnimeDetailScreen({super.key, required this.anime});

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  bool _expandedDesc = false;
  late Future<List<AnimePerson>> _mainCharactersFuture;
  late Future<List<AnimePerson>> _allCharactersFuture;

  @override
  void initState() {
    super.initState();
    final animeId = widget.anime.malId;
    _mainCharactersFuture = ApiService.buscarPersonagens(animeId!);
    _allCharactersFuture = ApiService.buscarTodosPersonagens(animeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cor1,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeaderSliver(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoChips(),
                  const SizedBox(height: 24),
                  _buildMainCharacters(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildAllCharacters(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSliver(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Hero(
              tag: 'anime_${widget.anime.malId}',
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.anime.images.jpg.imageUrl,
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
                          AppColors.cor1.withValues(alpha: 0.15),
                          AppColors.cor1,
                        ],
                        stops: const [0.35, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: SafeArea(child: _BackButton()),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Text(
              widget.anime.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChips() {
    final chips = <_InfoChipData>[
      _InfoChipData(Icons.star_rounded, widget.anime.score.toString(), AppColors.accent3),
      _InfoChipData(Icons.local_movies_outlined, _translateType(widget.anime.type), null),
      if (widget.anime.episodes != null)
        _InfoChipData(Icons.video_library_outlined, '${widget.anime.episodes} eps', null),
      _InfoChipData(Icons.calendar_today_outlined, widget.anime.year.toString(), null),
      _InfoChipData(Icons.circle, _translateStatus(widget.anime.status), _statusColor()),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((c) => _InfoChip(data: c)).toList(),
    );
  }

  Color _statusColor() {
    switch (widget.anime.status.toLowerCase()) {
      case 'currently airing':
        return AppColors.success;
      case 'not yet aired':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _translateStatus(String status) =>
      {
        'finished airing': 'Finalizado',
        'currently airing': 'Em exibição',
        'airing': 'Em exibição',
        'finished': 'Finalizado',
        'not yet aired': 'Não lançado',
        'upcoming': 'Em breve',
      }[status.toLowerCase()] ??
      status;

  String _translateType(String type) =>
      {
        'tv': 'Anime',
        'movie': 'Filme',
        'ova': 'OVA',
        'ona': 'ONA',
        'special': 'Especial',
        'tv special': 'Especial de Anime',
      }[type.toLowerCase()] ??
      type;

  Widget _buildMainCharacters() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Personagens Principais'),
      const SizedBox(height: 14),
      SizedBox(
        height: 140,
        child: FutureBuilder<List<AnimePerson>>(
          future: _mainCharactersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.cor4));
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return _emptyCharacters();
            }

            final characters = snapshot.data!;
            final itemCount = characters.length > 8 ? 8 : characters.length;

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return AnimePersonCard(personAnime: characters[index], compactMode: true);
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
            );
          },
        ),
      ),
    ],
  );

  Widget _buildAllCharacters() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Todos os Personagens'),
      const SizedBox(height: 14),
      SizedBox(
        height: 190,
        child: FutureBuilder<List<AnimePerson>>(
          future: _allCharactersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.cor4));
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return _emptyCharacters();
            }

            final characters = snapshot.data!;
            final itemCount = characters.length > 8 ? 8 : characters.length;

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      return AnimePersonCard(personAnime: characters[index], compactMode: true);
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                  ),
                ),
                if (characters.length > 8)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _navigateToAllCharacters(context, characters),
                      child: Text(
                        "Ver todos",
                        style: GoogleFonts.inter(color: AppColors.accent3, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ],
  );

  Widget _emptyCharacters() => Center(
    child: Text(
      "Nenhum personagem disponível.",
      style: GoogleFonts.inter(color: AppColors.textSecondary),
    ),
  );

  Widget _buildDescription() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Sinopse'),
      const SizedBox(height: 12),
      _ExpandableDescription(
        widget.anime.synopsis ?? 'Sinopse não disponível.',
        _expandedDesc,
        () => setState(() => _expandedDesc = !_expandedDesc),
      ),
    ],
  );

  void _navigateToAllCharacters(BuildContext context, List<AnimePerson> personAnimes) {
    if (personAnimes.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllCharactersScreenAnime(listaPersonagens: personAnimes),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

class _InfoChipData {
  final IconData icon;
  final String label;
  final Color? color;
  _InfoChipData(this.icon, this.label, this.color);
}

class _InfoChip extends StatelessWidget {
  final _InfoChipData data;
  const _InfoChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cor2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 14, color: data.color ?? AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            data.label,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}

class _ExpandableDescription extends StatelessWidget {
  final String description;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ExpandableDescription(this.description, this.isExpanded, this.onToggle);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: _buildCollapsedDesc(),
          secondChild: _buildExpandedDesc(),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        TextButton(
          onPressed: onToggle,
          style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
          child: Text(
            isExpanded ? 'Mostrar menos' : 'Mostrar mais',
            style: GoogleFonts.inter(color: AppColors.accent3, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedDesc() => Text(
    description.isNotEmpty ? description : 'Descrição não disponível',
    maxLines: 4,
    overflow: TextOverflow.ellipsis,
    style: GoogleFonts.inter(color: AppColors.textSecondary, height: 1.5),
  );

  Widget _buildExpandedDesc() => Text(
    description,
    style: GoogleFonts.inter(color: AppColors.textSecondary, height: 1.5),
  );
}
