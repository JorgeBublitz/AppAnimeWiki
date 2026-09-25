import 'package:app/colors/app_colors.dart';
import 'package:app/models/anime/anime.dart';
import 'package:app/routes.dart';
import 'package:app/screens/anime/anime_detail_screen.dart';
import 'package:app/screens/profile_screen.dart';
import 'package:app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.dark();
    var textTheme = GoogleFonts.interTextTheme(baseTheme.textTheme);

    // Poppins para títulos de destaque (telas, seções, marca); Inter no corpo.
    textTheme = textTheme.copyWith(
      headlineLarge: GoogleFonts.poppins(
        textStyle: textTheme.headlineLarge,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: textTheme.headlineMedium,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: textTheme.titleLarge,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.poppins(
        textStyle: textTheme.titleMedium,
        fontWeight: FontWeight.w600,
      ),
    );

    return MaterialApp(
      title: 'AniCodex',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: AppColors.cor1,
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: AppColors.cor4,
          secondary: AppColors.accent1,
          surface: AppColors.cor2,
          error: AppColors.error,
        ),
        textTheme: textTheme,
        primaryTextTheme: textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cor1,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
      // Exemplo de rotas nomeadas (ver lib/routes.dart): 2 casos, um sem
      // argumento (profile) e um com argumento tipado (animeDetail). O
      // resto do app ainda navega direto via MaterialPageRoute.
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.profile:
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case AppRoutes.animeDetail:
            final anime = settings.arguments as Anime;
            return MaterialPageRoute(
              builder: (_) => AnimeDetailScreen(anime: anime),
            );
          default:
            return null;
        }
      },
    );
  }
}
