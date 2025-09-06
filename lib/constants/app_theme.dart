import 'package:flutter/material.dart';

// Global theme & constants for campus safety app
class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonAmber = Color(0xFFF5FF5A);
  static const Color neonRed = Color(0xFFFF3030);
  static const Color neonOrange = Color(0xFFFF8C1A);
  static const Color neonBlue = Color(0xFF27F3E3);
  static const Color inactiveGray = Color(0xFF6E6E6E);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static TextStyle neonTitle({Color color = AppColors.neonGreen}) => TextStyle(
    color: color,
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    shadows: neonGlow(color),
  );

  static TextStyle neonSubtitle({Color color = AppColors.neonGreen}) => TextStyle(
    color: color,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
    shadows: neonGlow(color),
  );

  static TextStyle neonButton({Color color = AppColors.neonGreen}) => TextStyle(
    color: color,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.8,
    shadows: neonGlow(color),
  );

  static TextStyle cctvText({Color color = AppColors.neonGreen}) => TextStyle(
    color: color.withOpacity(0.8),
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFamily: 'monospace',
  );

  static TextStyle bodyText({Color color = AppColors.white}) => TextStyle(
    color: color,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static TextStyle tabLabel({Color color = AppColors.inactiveGray}) => TextStyle(
    color: color,
    fontSize: 13,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    shadows: color == AppColors.inactiveGray ? null : neonGlow(color),
  );
}

// Helper function to create neon glow effect
List<Shadow> neonGlow(Color color, {double blur = 20}) {
  return [
    Shadow(
      color: color.withOpacity(0.8),
      blurRadius: blur,
    ),
    Shadow(
      color: color.withOpacity(0.4),
      blurRadius: blur * 2,
    ),
  ];
}

// CCTV Header Widget
class CctvHeader extends StatelessWidget {
  final String timestamp;
  final String coordinates;

  const CctvHeader({
    super.key,
    this.timestamp = "10:41",
    this.coordinates = "3.1225,-122.1697",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            Icons.videocam,
            color: AppColors.neonGreen.withOpacity(0.6),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            "$timestamp • $coordinates",
            style: AppTextStyles.cctvText(),
          ),
        ],
      ),
    );
  }
}

// Scanline background decoration
class ScanlineBackground extends StatelessWidget {
  final Widget child;

  const ScanlineBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background.withOpacity(0.0),
                    AppColors.background.withOpacity(0.4),
                    AppColors.background.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
