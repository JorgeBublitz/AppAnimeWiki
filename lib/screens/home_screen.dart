// lib/screens/home_screen.dart
import 'package:app/screens/anime/all_anime_screen.dart';
import 'package:app/screens/manga/all_manga_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anime/anime.dart';
import '../models/manga/manga.dart';
import '../widgets/cards_anime/anime_card.dart';
import '../widgets/cards_manga/manga_card.dart';
import '../widgets/pill_tab_switch.dart';
import '../colors/app_colors.dart';
import '../screens/anime/anime_detail_screen.dart';
import '../screens/manga/manga_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/feature_carousel.dart';
import '../widgets/category_section.dart';

class HomeScreen extends StatefulWidget {
  final List<Anime> animes;
  final List<Manga> mangas;

  const HomeScreen({super.key, required this.animes, required this.mangas});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late List<Anime> _filteredAnimes;
  late List<Manga> _filteredMangas;
  late List<Anime> _featuredAnimes;
  late List<Manga> _popularMangas;
  late List<Anime> _topAnimes;
  late List<Manga> _topMangas;
  late List<Anime> _discoverAnimes;
  late List<Manga> _discoverMangas;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      _filteredAnimes = widget.animes;
      _filteredMangas = widget.mangas;

      final sortedAnimesByPopularity = List<Anime>.from(_filteredAnimes)
        ..sort((a, b) => a.popularity.compareTo(b.popularity));
      _featuredAnimes = sortedAnimesByPopularity.take(5).toList();

      final sortedMangasByPopularity = List<Manga>.from(_filteredMangas)
        ..sort((a, b) => a.popularity.compareTo(b.popularity));
      _popularMangas = sortedMangasByPopularity.take(10).toList();

      final sortedAnimesByRank = List<Anime>.from(_filteredAnimes)
        ..sort((a, b) => a.rank.compareTo(b.rank));
      _topAnimes = sortedAnimesByRank.take(10).toList();

      final sortedMangasByRank = List<Manga>.from(_filteredMangas)
        ..sort((a, b) => a.rank.compareTo(b.rank));
      _topMangas = sortedMangasByRank.take(10).toList();

      // Descubra mais: o restante do catálogo, fora do Top 10.
      _discoverAnimes = sortedAnimesByRank.skip(10).take(9).toList();
      _discoverMangas = sortedMangasByRank.skip(10).take(9).toList();
    } catch (e) {
      debugPrint('Erro ao inicializar dados: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _openSearch() {
    final isAnimeTab = _tabController.index == 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                isAnimeTab
                    ? AllAnimeScreen(initialAnimes: _filteredAnimes)
                    : AllMangaScreen(initialMangas: _filteredMangas),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cor1,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingIndicator() : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.cor1,
      leadingWidth: 56,
      leading: IconButton(
        icon: const Icon(Icons.account_circle_rounded, color: Colors.white, size: 30),
        onPressed: _openProfile,
        tooltip: 'Perfil',
      ),
      title: Text(
        'AniCodex',
        style: GoogleFonts.baloo2(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
          onPressed: _openSearch,
          tooltip: 'Buscar',
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: PillTabSwitch(
            controller: _tabController,
            labels: const ['Animes', 'Mangás'],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.cor4),
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [_buildAnimeTab(), _buildMangaTab()],
    );
  }

  Widget _buildAnimeTab() {
    return RefreshIndicator(
      onRefresh: _initializeData,
      color: AppColors.cor4,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FeatureCarousel(animes: _featuredAnimes),
              const SizedBox(height: 28),
              _sectionHeader('Top 10 Animes', onSeeAll: _openSearch),
              const SizedBox(height: 12),
              _buildHorizontalList(_topAnimes, isAnime: true),
              const SizedBox(height: 28),
              _sectionHeader('Descubra mais', onSeeAll: _openSearch),
              const SizedBox(height: 12),
              CategorySection(items: _discoverAnimes, isAnime: true),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMangaTab() {
    return RefreshIndicator(
      onRefresh: _initializeData,
      color: AppColors.cor4,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              _sectionHeader('Top 10 Mangás', onSeeAll: _openSearch),
              const SizedBox(height: 12),
              _buildHorizontalList(_topMangas, isAnime: false),
              const SizedBox(height: 28),
              _sectionHeader('Mangás Populares', onSeeAll: _openSearch),
              const SizedBox(height: 12),
              _buildHorizontalList(_popularMangas, isAnime: false),
              const SizedBox(height: 28),
              _sectionHeader('Descubra mais', onSeeAll: _openSearch),
              const SizedBox(height: 12),
              CategorySection(items: _discoverMangas, isAnime: false),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ver tudo',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent3,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.accent3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<dynamic> lista, {required bool isAnime}) {
    return SizedBox(
      height: 258,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lista.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final item = lista[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
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
              child: SizedBox(
                width: 128,
                child:
                    isAnime
                        ? AnimeCard(anime: item as Anime, showRank: true)
                        : MangaCard(manga: item as Manga, showRank: true),
              ),
            ),
          );
        },
      ),
    );
  }
}
