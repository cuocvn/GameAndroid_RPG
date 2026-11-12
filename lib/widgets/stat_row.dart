import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StatRow extends StatefulWidget {
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
  State<StatRow> createState() => _StatRowState();
}

class _StatRowState extends State<StatRow> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.canAllocate) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StatRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.canAllocate && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.canAllocate && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bonus = widget.totalValue - widget.baseValue;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppTheme.surfaceGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.canAllocate
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
              color: widget.color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.color.withOpacity(0.8), width: 1.5),
            ),
            child: Text(
              widget.label,
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: widget.color,
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
                      widget.fullName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.baseValue}',
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
                  widget.description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          // Allocate "+" button with gentle pulse animation
          if (widget.canAllocate)
            ScaleTransition(
              scale: _pulseScale,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onAllocate?.call();
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldButtonGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldAccent.withOpacity(0.45),
                        blurRadius: 10,
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
            ),
        ],
      ),
    );
  }
}
