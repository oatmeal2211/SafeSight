import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/map_page.dart';
import 'pages/report_page.dart';
import 'pages/circle_page.dart';
import 'pages/resources_page.dart';
import 'pages/sos_fullscreen.dart';

void main() {
  runApp(const SafeSightApp());
}

class SafeSightApp extends StatelessWidget {
  const SafeSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeSight',
      theme: _buildTheme(),
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000),
      colorScheme: const ColorScheme.dark(
        background: const Color(0xFF000000),
        surface: const Color(0xFF000000),
        primary: Color(0xFF39FF14),
        secondary: Color(0xFF6E6E6E),
        error: Color(0xFFFF1A1A),
      ),
      textTheme: const TextTheme(
        labelSmall: TextStyle(
          color: Color(0xFF6E6E6E),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        foregroundColor: Color(0xFF39FF14),
        elevation: 0,
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;



  final List<TabInfo> _tabs = [
    TabInfo('MAP', Icons.map_outlined, Color(0xFF39FF14)),
    TabInfo('REPORT', Icons.report_outlined, Color(0xFFFF8C1A)),
    TabInfo('SOS', Icons.emergency, Color(0xFFFF1A1A)), // Won't be used directly
    TabInfo('CIRCLE', Icons.group_outlined, Color(0xFF27F3E3)),
    TabInfo('RESOURCES', Icons.library_books_outlined, Color(0xFF39FF14)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex > 2 ? _currentIndex - 1 : _currentIndex,
        children: [
          const MapPage(),
          const ReportPage(),
          const CirclePage(),
          const ResourcesPage(),
        ],
      ),
      floatingActionButton: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF1A1A).withValues(alpha: 0.6),
              blurRadius: 25,
              spreadRadius: 8,
            ),
            BoxShadow(
              color: const Color(0xFFFF1A1A).withValues(alpha: 0.4),
              blurRadius: 50,
              spreadRadius: 3,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _onSOSPressed,
          backgroundColor: const Color(0xFFFF1A1A),
          elevation: 0,
          child: const Icon(
            Icons.emergency,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF000000),
        height: 110,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(0),
              _buildNavItem(1),
              const SizedBox(width: 60), // Space for FAB
              _buildNavItem(3),
              _buildNavItem(4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final tab = _tabs[index];
    final isActive = _currentIndex == index;
    final color = isActive ? tab.activeColor : const Color(0xFF6E6E6E);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: NeonIconLabel(
          icon: tab.icon,
          label: tab.label,
          color: color,
          isActive: isActive,
        ),
      ),
    );
  }

  void _onSOSPressed() {
    HapticFeedback.heavyImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SOSFullscreenPage()),
    );
  }
}

class TabInfo {
  final String label;
  final IconData icon;
  final Color activeColor;

  TabInfo(this.label, this.icon, this.activeColor);
}

class NeonIconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;

  const NeonIconLabel({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70, // Increased from 64 to 70
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4), // Reduced from 6 to 4
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: isActive
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  shadows: isActive
                      ? [
                          Shadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
