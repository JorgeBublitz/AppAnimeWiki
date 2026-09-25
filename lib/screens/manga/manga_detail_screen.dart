import 'package:app/screens/manga/all_characters_screen_manga.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../colors/app_colors.dart';
import '../../models/manga/manga.dart';
import '../../models/manga/manga_person.dart';
import '../../widgets/cards_manga/manga_person_card.dart';
import '../../api_service.dart';

class MangaDetailScreen extends StatefulWidget {
  final Manga manga;
  const MangaDetailScreen({super.key, required this.manga});

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  bool _expandedDesc = false;
  late Future<List<MangaPerson>> _mainCharactersFuture;
  late Future<List<MangaPerson>> _allCharactersFuture;

  @override
  void initState() {
    super.initState();
    final mangaId = widget.manga.malId;
    _mainCharactersFuture = ApiService.buscarPersonagensM(mangaId!);
    _allCharactersFuture = ApiService.buscarTodosPersonagensM(mangaId);
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
                  if (widget.manga.author.isNotEmpty && widget.manga.author != 'Autor desconhecido') ...[
                    Text(
                      widget.manga.author,
                      style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                  ],
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
              tag: 'manga_${widget.manga.malId}',
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.manga.images.jpg.imageUrl,
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
          Positioned(top: 8, left: 8, child: SafeArea(child: _BackButton())),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Text(
              widget.manga.title,
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
      _InfoChipData(Icons.star_rounded, widget.manga.score.toString(), AppColors.accent3),
      _InfoChipData(Icons.menu_book_outlined, _translateType(widget.manga.type), null),
      if (widget.manga.chapters != null)
        _InfoChipData(Icons.bookmark_outline_rounded, '${widget.manga.chapters} caps', null),
      if (widget.manga.volumes != null)
        _InfoChipData(Icons.library_books_outlined, '${widget.manga.volumes} vols', null),
      _InfoChipData(Icons.circle, _translateStatus(widget.manga.status), _statusColor()),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((c) => _InfoChip(data: c)).toList(),
    );
  }

  Color _statusColor() {
    switch (widget.manga.status.toLowerCase()) {
      case 'publishing':
        return AppColors.success;
      case 'on hiatus':
        return AppColors.warning;
      case 'discontinued':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _translateStatus(String status) =>
      {
        'publishing': 'Publicando',
        'finished': 'Finalizado',
        'on hiatus': 'Hiato',
        'discontinued': 'Cancelado',
      }[status.toLowerCase()] ??
      status;

  String _translateType(String type) =>
      {
        'manga': 'Mangá',
        'novel': 'Novel',
        'light_novel': 'Light Novel',
        'one_shot': 'One-shot',
        'doujinshi': 'Doujinshi',
        'manhwa': 'Manhwa',
        'manhua': 'Manhua',
      }[type.toLowerCase()] ??
      type;

  Widget _buildMainCharacters() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Personagens Principais'),
      const SizedBox(height: 14),
      SizedBox(
        height: 140,
        child: FutureBuilder<List<MangaPerson>>(
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
                return MangaPersonCard(personManga: characters[index], compactMode: true);
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
        child: FutureBuilder<List<MangaPerson>>(
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
                      return MangaPersonCard(personManga: characters[index], compactMode: true);
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
        widget.manga.synopsis ?? 'Sinopse não disponível.',
        _expandedDesc,
        () => setState(() => _expandedDesc = !_expandedDesc),
      ),
    ],
  );

  void _navigateToAllCharacters(BuildContext context, List<MangaPerson> personManga) {
    if (personManga.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllCharactersScreenManga(listaPersonagens: personManga),
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
