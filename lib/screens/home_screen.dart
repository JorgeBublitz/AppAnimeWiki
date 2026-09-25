// lib/screens/home_screen.dart
import 'package:app/screens/anime/all_anime_screen.dart';
import 'package:app/screens/manga/all_manga_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anime/anime.dart';
import '../models/manga/manga.dart';
import '../widgets/cards_anime/anime_card.dart';
import '../widgets/cards_manga/manga_card.dart';
import '../colors/app_colors.dart';
import '../screens/anime/anime_detail_screen.dart';
import '../screens/manga/manga_detail_screen.dart';
import '../widgets/feature_carousel.dart';
import '../widgets/category_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late List<Anime> _actionAnimes;
  late List<Manga> _popularMangas;
  late List<Anime> _topAnimes;
  late List<Manga> _topMangas;
  bool _isAdultContentEnabled = false;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPreferences();
    _initializeData();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAdultContentEnabled = prefs.getBool('adultContentEnabled') ?? false;
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Filtrar animes e mangás com base na configuração de conteúdo adulto
      _filteredAnimes = _filterContent(widget.animes);
      _filteredMangas = _filterContent(widget.mangas);

      // Obter animes em destaque (top 5 por popularidade)
      final sortedAnimesByPopularity = List<Anime>.from(_filteredAnimes)
        ..sort((a, b) => a.popularity.compareTo(b.popularity));
      _featuredAnimes = sortedAnimesByPopularity.take(5).toList();

      // Obter animes de ação
      _actionAnimes =
          _filteredAnimes
              .where(
                (anime) => anime.genres.any(
                  (genre) => genre.name.toLowerCase().contains('action'),
                ),
              )
              .take(10)
              .toList();

      // Obter mangás populares
      final sortedMangasByPopularity = List<Manga>.from(_filteredMangas)
        ..sort((a, b) => a.popularity.compareTo(b.popularity));
      _popularMangas = sortedMangasByPopularity.take(10).toList();

      // Obter Top 10 animes e mangás por rank (sem mutar as listas filtradas)
      final sortedAnimesByRank = List<Anime>.from(_filteredAnimes)
        ..sort((a, b) => a.rank.compareTo(b.rank));
      _topAnimes = sortedAnimesByRank.take(10).toList();

      final sortedMangasByRank = List<Manga>.from(_filteredMangas)
        ..sort((a, b) => a.rank.compareTo(b.rank));
      _topMangas = sortedMangasByRank.take(10).toList();
    } catch (e) {
      debugPrint('Erro ao inicializar dados: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<T> _filterContent<T>(List<T> items) {
    if (_isAdultContentEnabled) {
      return items;
    } else {
      if (T == Anime) {
        return items
            .where(
              (item) =>
                  (item as Anime).rating != 'R+ - Mild Nudity' &&
                  (item as Anime).rating != 'Rx - Hentai',
            )
            .toList();
      } else if (T == Manga) {
        return items;
      }
      return items;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cor1,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingIndicator() : _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.cor1,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_circle_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          Text(
            'OtakuHub',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 26,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.cor4,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade400,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        tabs: const [Tab(text: 'Animes'), Tab(text: 'Mangás')],
      ),
    );
  }

  /// Navegação persistente: dá um ponto fixo pra "Início" e um atalho direto
  /// para a busca (antes só existia como um link pequeno "Ver mais" dentro
  /// de cada seção, o que deixava a navegação confusa).
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: AppColors.cor2,
      selectedItemColor: AppColors.cor4,
      unselectedItemColor: Colors.grey.shade500,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) _openSearch();
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Buscar'),
      ],
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
              // Banner de destaque
              FeatureCarousel(animes: _featuredAnimes),

              const SizedBox(height: 24),

              // Seção Top 10 Animes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _sectionTitle("Top 10 Animes"),
                    const Spacer(),
                    _buttonSection("Ver mais", isAnime: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildHorizontalList(_topAnimes, isAnime: true),

              const SizedBox(height: 24),

              // Seção Animes de Ação
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionTitle("Animes de Ação"),
              ),
              const SizedBox(height: 12),
              _buildHorizontalList(_actionAnimes, isAnime: true),

              const SizedBox(height: 24),

              // Seção Lançamentos da Temporada
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionTitle("Lançamentos da Temporada"),
              ),
              const SizedBox(height: 12),
              CategorySection(
                items:
                    _filteredAnimes
                        .where((anime) => anime.status == "Currently Airing")
                        .take(6)
                        .toList(),
                isAnime: true,
              ),

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
              // Seção Top 10 Mangás
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _sectionTitle("Top 10 Mangás"),
                    const Spacer(),
                    _buttonSection("Ver mais", isAnime: false),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildHorizontalList(_topMangas, isAnime: false),

              const SizedBox(height: 24),

              // Seção Mangás Populares
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionTitle("Mangás Populares"),
              ),
              const SizedBox(height: 12),
              _buildHorizontalList(_popularMangas, isAnime: false),

              const SizedBox(height: 24),

              // Seção Em Publicação
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionTitle("Em Publicação"),
              ),
              const SizedBox(height: 12),
              CategorySection(
                items:
                    _filteredMangas
                        .where((manga) => manga.publishing)
                        .take(6)
                        .toList(),
                isAnime: false,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buttonSection(String title, {required bool isAnime}) {
    return InkWell(
      onTap: () {
        if (isAnime) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AllAnimeScreen(initialAnimes: _filteredAnimes),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AllMangaScreen(initialMangas: _filteredMangas),
            ),
          );
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<dynamic> lista, {required bool isAnime}) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lista.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final item = lista[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
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
                width: 140,
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
