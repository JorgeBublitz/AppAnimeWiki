import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/app_colors.dart';

/// Alternador em formato de pílula (Anime/Mangá), no lugar da TabBar padrão
/// do Material — visual mais distintivo e menos "Flutter genérico".
class PillTabSwitch extends StatelessWidget {
  final TabController controller;
  final List<String> labels;

  const PillTabSwitch({super.key, required this.controller, required this.labels});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          height: 40,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.cor2,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: List.generate(labels.length, (index) {
              final isSelected = controller.index == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.animateTo(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cor4 : Colors.transparent,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      labels[index],
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
