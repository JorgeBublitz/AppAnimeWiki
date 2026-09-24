import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/anime/anime.dart';
import '../../colors/app_colors.dart';
import '../../api_service.dart';
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
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverSection(_buildHeader()),
            _buildSliverSection(_buildMainCharacters()),
            _buildSliverSection(_buildDescription()),
            _buildSliverSection(_buildAllCharacters()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    elevation: 0,
    backgroundColor: AppColors.cor4,
    flexibleSpace: _buildAppBarGradient(),
    title: const Text(
      'Detalhes do Anime',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    centerTitle: true,
  );

  Widget _buildAppBarGradient() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.cor2],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  );

  Widget _buildSliverSection(Widget child) => SliverToBoxAdapter(
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  Widget _buildHeader() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _AnimeImage(widget.anime),
      const SizedBox(width: 16),
      Expanded(child: _AnimeBasicInfo(widget.anime)),
    ],
  );

  Widget _buildMainCharacters() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Personagens Principais'),
      const SizedBox(height: 14),
      SizedBox(
        height: 140, // Ajustado para o novo tamanho do card
        child: FutureBuilder<List<AnimePerson>>(
          future: _mainCharactersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Nenhum personagem disponível.",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final characters = snapshot.data!;
            final itemCount = characters.length > 8 ? 8 : characters.length;

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return AnimePersonCard(
                  personAnime: characters[index],
                  compactMode: true,
                );
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
        height: 190, // Ajustado para o novo tamanho do card
        child: FutureBuilder<List<AnimePerson>>(
          future: _allCharactersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Nenhum personagem disponível.",
                  style: TextStyle(color: Colors.white70),
                ),
              );
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
                      return AnimePersonCard(
                        personAnime: characters[index],
                        compactMode: true,
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                  ),
                ),
                if (characters.length > 8)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          () => _navigateToAllCharacters(context, characters),
                      child: const Text(
                        "Ver todos",
                        style: TextStyle(color: Colors.amber),
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

  Widget _buildDescription() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionTitle('Sinopse'),
      const SizedBox(height: 12),
      _ExpandableDescription(
        widget.anime.synopsis ?? 'Sinopse não disponível.',
        _expandedDesc,
        () => setState(() => _expandedDesc = !_expandedDesc),
      ),
    ],
  );

  void _navigateToAllCharacters(
    BuildContext context,
    List<AnimePerson> personAnimes,
  ) {
    if (personAnimes.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AllCharactersScreenAnime(listaPersonagens: personAnimes),
      ),
    );
  }
}

class _AnimeImage extends StatelessWidget {
  final Anime anime;
  const _AnimeImage(this.anime);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: anime.images.jpg.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[800]),
              errorWidget:
                  (_, __, ___) => Container(
                    color: const Color.fromARGB(255, 71, 71, 71),
                    child: const Icon(Icons.error, color: Colors.white),
                  ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    anime.score.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimeBasicInfo extends StatelessWidget {
  final Anime anime;
  const _AnimeBasicInfo(this.anime);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          anime.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        _InfoRow('Episódios', anime.episodes.toString()),
        _InfoRow('Tipo', _translateType(anime.type)),
        _InfoRow('Lançamento', anime.year.toString()),
        _InfoRow('Temporada', _translateSeason(anime.season ?? 'N/A')),
        _InfoRow('Status', _translateStatus(anime.status)),
      ],
    );
  }

  String _translateSeason(String? season) =>
      {
        'winter': 'Inverno',
        'spring': 'Primavera',
        'summer': 'Verao',
        'fall': 'Outono',
      }[season?.toLowerCase()] ??
      season ??
      'N/A';

  String _translateStatus(String status) =>
      {
        'finished airing': 'Finalizado',
        'currently airing': 'Em exibição',
        'airing': 'Em exibição',
        'finished': 'Finalizado',
        'not_yet_aired': 'Não lançado',
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
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 24,
          width: 4,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ExpandableDescription extends StatelessWidget {
  final String description;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ExpandableDescription(
    this.description,
    this.isExpanded,
    this.onToggle,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: _buildCollapsedDesc(),
          secondChild: _buildExpandedDesc(),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        TextButton(
          onPressed: onToggle,
          child: Text(
            isExpanded ? 'Mostrar menos' : 'Mostrar mais',
            style: TextStyle(color: Colors.amber[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedDesc() => Text(
    description.isNotEmpty ? description : 'Descrição não disponível',
    maxLines: 4,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(color: Colors.white70, height: 1.5),
  );

  Widget _buildExpandedDesc() => Text(
    description,
    style: const TextStyle(color: Colors.white70, height: 1.5),
  );
}
