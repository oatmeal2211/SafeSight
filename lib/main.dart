import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/map_page.dart';
import 'pages/report_page.dart';
import 'pages/circle_page.dart';
import 'pages/resources_page.dart';
import 'pages/sos_fullscreen.dart';
import 'report/report_home.dart';
import 'report/mode_amber_confirm.dart';
import 'report/mode_amber_details.dart';
import 'report/mode_witness_form.dart';
import 'report/mode_quick_pin.dart';
import 'report/witness_success_page.dart';
import 'constants/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Warning: .env file not found. Using system environment variables.');
  }
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
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.background,
        primary: AppColors.neonGreen,
        secondary: AppColors.inactiveGray,
        error: AppColors.neonRed,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.neonTitle(),
        titleLarge: AppTextStyles.neonSubtitle(),
        bodyLarge: AppTextStyles.bodyText(),
        labelSmall: AppTextStyles.tabLabel(),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.neonGreen,
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

  // Navigator keys for each tab
  final GlobalKey<NavigatorState> _mapNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _reportNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _circleNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _resourcesNavKey = GlobalKey<NavigatorState>();

  final List<TabInfo> _tabs = [
    const TabInfo('MAP', Icons.map_outlined, AppColors.neonGreen),
    const TabInfo('REPORT', Icons.report_outlined, AppColors.neonOrange),
    const TabInfo('SOS', Icons.emergency, AppColors.neonRed), // Won't be used directly
    const TabInfo('CIRCLE', Icons.group_outlined, AppColors.neonBlue),
    const TabInfo('RESOURCES', Icons.library_books_outlined, AppColors.neonGreen),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex > 2 ? _currentIndex - 1 : _currentIndex,
        children: [
          _buildTabNavigator(0, _mapNavKey, const MapPage()),
          _buildTabNavigator(1, _reportNavKey, const ReportPage()),
          _buildTabNavigator(3, _circleNavKey, const CirclePage()),
          _buildTabNavigator(4, _resourcesNavKey, const ResourcesPage()),
        ],
      ),
      floatingActionButton: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.neonRed.withOpacity(0.6),
              blurRadius: 25,
              spreadRadius: 8,
            ),
            BoxShadow(
              color: AppColors.neonRed.withOpacity(0.4),
              blurRadius: 50,
              spreadRadius: 3,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _onSOSPressed,
          backgroundColor: AppColors.neonRed,
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
        color: AppColors.background,
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

  Widget _buildTabNavigator(int tabIndex, GlobalKey<NavigatorState> navKey, Widget homePage) {
    return Navigator(
      key: navKey,
      onGenerateRoute: (RouteSettings settings) {
        Widget page = homePage;
        
        // Report tab routes
        if (tabIndex == 1) {
          switch (settings.name) {
            case '/report':
              page = const ReportHome();
              break;
            case '/report/amber':
              page = const ModeAmberConfirm(caseId: ''); // Pass empty string for now
              break;
            case '/report/amber/details':
              final caseId = settings.arguments as String?;
              page = ModeAmberDetails(caseId: caseId ?? '');
              break;
            case '/report/witness':
              page = const ModeWitnessForm();
              break;
            case '/report/witness/success':
              final caseId = settings.arguments as String?;
              page = WitnessSuccessPage(caseId: caseId ?? '');
              break;
            case '/report/quick':
              page = const ModeQuickPin();
              break;
            default:
              page = homePage;
          }
        }
        
        return MaterialPageRoute(
          builder: (context) => page,
          settings: settings,
        );
      },
    );
  }

  Widget _buildNavItem(int index) {
    final tab = _tabs[index];
    final isActive = _currentIndex == index;
    final color = isActive ? tab.activeColor : AppColors.inactiveGray;

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

  const TabInfo(this.label, this.icon, this.activeColor);
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
      height: 70,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: isActive
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
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
                style: AppTextStyles.tabLabel(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
