import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StatRow extends StatelessWidget {
  final String label;
  final String fullName;
  final int baseValue;
  final int totalValue;
  final String description;
  final Color color;
  final bool canAllocate;
  final VoidCallback? onAllocate;

  const StatRow({
    super.key,
    required this.label,
    required this.fullName,
    required this.baseValue,
    required this.totalValue,
    required this.description,
    required this.color,
    this.canAllocate = false,
    this.onAllocate,
  });

  @override
  Widget build(BuildContext context) {
    final bonus = totalValue - baseValue;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppTheme.surfaceGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canAllocate
              ? AppTheme.goldAccent.withOpacity(0.4)
              : Colors.white.withOpacity(0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Stat Badge (e.g. STR, INT)
          Container(
            width: 48,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.8), width: 1.5),
            ),
            child: Text(
              label,
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name, Values and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      fullName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$baseValue',
                      style: GoogleFonts.cinzel(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                    if (bonus > 0)
                      Text(
                        ' (+$bonus)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.greenAccent,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          // Allocate "+" button
          if (canAllocate)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                HapticFeedback.lightImpact();
                onAllocate?.call();
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppTheme.goldButtonGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldAccent.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
