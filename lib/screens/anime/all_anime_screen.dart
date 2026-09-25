import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/colors/app_colors.dart';
import 'package:app/widgets/cards_anime/anime_card.dart';
import 'package:app/models/anime/anime.dart';
import 'package:app/screens/anime/anime_detail_screen.dart';
import 'package:app/api_service.dart';

class AllAnimeScreen extends StatefulWidget {
  final List<Anime> initialAnimes;

  const AllAnimeScreen({super.key, required this.initialAnimes});

  @override
  State<AllAnimeScreen> createState() => _AllAnimeScreenState();
}

class _AllAnimeScreenState extends State<AllAnimeScreen> {
  List<Anime> _animes = [];
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 24;
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;

  Future<void> _fetchPage(int page, {String query = ''}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.fetchAnimes(
        page: page,
        limit: _itemsPerPage,
        query: query,
        sfw: true,
      );

      if (mounted) {
        setState(() {
          _animes = result['animes'];
          _totalPages = result['totalPages'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != query) {
        _searchQuery = query;
        _currentPage = 1;
        _scrollController.jumpTo(0);
        _fetchPage(_currentPage, query: query);
      }
    });
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    _scrollController.jumpTo(0);
    setState(() => _currentPage = page);
    _fetchPage(page, query: _searchQuery);
  }

  @override
  void initState() {
    super.initState();
    _fetchPage(_currentPage);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cor1,
      appBar: AppBar(
        title: const Text('Catálogo de Animes'),
        backgroundColor: AppColors.cor4,
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar anime...',
                        filled: true,
                        fillColor: AppColors.cor2,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchQuery = '';
                            _fetchPage(1);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(color: Colors.white54),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: _onSearchChanged,
                      onSubmitted:
                          (_) =>
                              _searchQuery.isNotEmpty
                                  ? _fetchPage(1, query: _searchQuery)
                                  : null,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildContent()),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return _buildLoadingScreen();
    if (_animes.isEmpty) return _buildEmptyScreen();
    return _buildAnimeGrid();
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Carregando animes...', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return const Center(
      child: Text(
        'Nenhum anime encontrado.',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }

  Widget _buildAnimeGrid() {
    return RefreshIndicator(
      onRefresh: () => _fetchPage(_currentPage, query: _searchQuery),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: _animes.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _animes.length) {
              return const Center(child: CircularProgressIndicator());
            }
            final anime = _animes[index];
            return GestureDetector(
              onTap: () {
                if (anime.malId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnimeDetailScreen(anime: anime),
                    ),
                  );
                }
              },
              child: AnimeCard(anime: anime, showRank: false),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppColors.cor3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed:
                _currentPage > 1 && !_isLoading
                    ? () => _goToPage(_currentPage - 1)
                    : null,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed:
                    !_isLoading && _currentPage > 1 ? () => _goToPage(1) : null,
              ),
              Text(
                '$_currentPage / $_totalPages',
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed:
                    !_isLoading && _currentPage < _totalPages
                        ? () => _goToPage(_totalPages)
                        : null,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            color: Colors.white,
            onPressed:
                !_isLoading && _currentPage < _totalPages
                    ? () => _goToPage(_currentPage + 1)
                    : null,
          ),
        ],
      ),
    );
  }
}
