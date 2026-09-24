import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../colors/app_colors.dart';
import '../api_service.dart';
import 'home_screen.dart';
import 'package:app/models/anime/anime.dart';
import 'package:app/models/manga/manga.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  double _scale = 0.8;
  bool _mostrarCarregando = false;
  bool _erroCarregamento = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Configuração da animação de pulso
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _iniciarAnimacoes();
    _carregarDados();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _iniciarAnimacoes() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.2;
        });
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _mostrarCarregando = true;
        });
      }
    });
  }

  Future<void> _carregarDados() async {
    // Na versão 6 do connectivity_plus o retorno é uma lista de conexões;
    // comparar direto com ConnectivityResult.none nunca era verdadeiro.
    final conectividade = await Connectivity().checkConnectivity();

    if (conectividade.contains(ConnectivityResult.none)) {
      _mostrarErro();
      return;
    }

    try {
      final resultados = await Future.wait([
        ApiService.topAnimes().timeout(const Duration(seconds: 10)),
        ApiService.topMangas().timeout(const Duration(seconds: 10)),
      ]);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => HomeScreen(
                animes: resultados[0] as List<Anime>,
                mangas: resultados[1] as List<Manga>,
              ),
        ),
      );
    } on TimeoutException catch (_) {
      _mostrarErro(mensagem: 'Tempo esgotado ao carregar dados.');
    } catch (e) {
      _mostrarErro(mensagem: 'Erro inesperado: $e');
    }
  }

  void _mostrarErro({String mensagem = 'Sem conexão com a internet'}) {
    if (mounted) {
      setState(() {
        _erroCarregamento = true;
        _mostrarCarregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usando um gradiente sutil com a cor original como base
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cor5, AppColors.cor5.withOpacity(0.85)],
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 900),
            opacity: _opacity,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: _scale),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder:
                  (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Adicionando efeito de brilho ao redor do logo
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'assets/images/splash.png',
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Adicionando o nome do app com estilo
                  const Text(
                    "OtakuHub",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child:
                        _erroCarregamento
                            ? _erroWidget()
                            : _mostrarCarregando
                            ? _loadingWidget()
                            : const SizedBox(key: ValueKey('vazio'), height: 0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingWidget() {
    return Column(
      key: const ValueKey('carregando'),
      children: [
        // Indicador de carregamento com texto
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          "Carregando conteúdo...",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _erroWidget() {
    return Container(
      key: const ValueKey('erro'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          const Text(
            'Falha ao carregar os dados.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _erroCarregamento = false;
                _mostrarCarregando = true;
              });
              _carregarDados();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.cor5,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child: const Text(
              'Tentar novamente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
