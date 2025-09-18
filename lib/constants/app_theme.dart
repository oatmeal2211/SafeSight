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

  static TextStyle onboardingTitle({Color color = AppColors.neonGreen}) => TextStyle(
    color: color,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    shadows: neonGlow(color),
  );

  static TextStyle onboardingSubtitle({Color color = AppColors.inactiveGray}) => TextStyle(
    color: color,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle smallText({Color color = AppColors.inactiveGray}) => TextStyle(
    color: color,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
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

// Neon Button Widget
class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool isPrimary;
  final bool isOutlined;
  final double? width;
  final EdgeInsets? padding;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.neonGreen,
    this.isPrimary = true,
    this.isOutlined = false,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: isPrimary && !isOutlined ? color.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color: color,
          width: isOutlined ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              text.toUpperCase(),
              style: AppTextStyles.neonButton(color: color),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// Neon Input Field Widget
class NeonInputField extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLength;
  final Function(String)? onChanged;

  const NeonInputField({
    super.key,
    required this.hintText,
    this.labelText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!.toUpperCase(),
            style: AppTextStyles.onboardingSubtitle(color: AppColors.neonGreen),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neonGreen.withOpacity(0.5), width: 1),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLength: maxLength,
            onChanged: onChanged,
            style: AppTextStyles.bodyText(color: AppColors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.bodyText(color: AppColors.inactiveGray),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              counterText: "",
            ),
          ),
        ),
      ],
    );
  }
}

// Role Selection Button Widget
class RoleSelectionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const RoleSelectionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.neonGreen : AppColors.inactiveGray;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.neonGreen.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color: color,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected ? [
          BoxShadow(
            color: AppColors.neonGreen.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(width: 16),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.neonButton(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
