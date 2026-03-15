import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'database_helper.dart';
import 'theme/theme_provider.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';
import 'screens/clientes_screen.dart';
import 'screens/tatuadores_screen.dart';
import 'screens/disenos_screen.dart';
import 'screens/citas_screen.dart';
import 'screens/pagos_screen.dart';
import 'screens/reportes_screen.dart';
import 'screens/configuracion_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Maximizar la ventana al iniciar
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      minimumSize: Size(1024, 700),
      title: 'InkManager – Sistema de Gestión de Tatuajes',
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.maximize();
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SistemaTatuajesApp(),
    ),
  );
}

class SistemaTatuajesApp extends StatelessWidget {
  const SistemaTatuajesApp({super.key});

  static TextTheme _buildTextTheme(Color base, Color secondary) {
    return GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: GoogleFonts.poppins(color: base),
      bodyMedium: GoogleFonts.poppins(color: base),
      bodySmall: GoogleFonts.poppins(color: secondary),
      titleLarge: GoogleFonts.poppins(color: base, fontWeight: FontWeight.w700),
      titleMedium:
          GoogleFonts.poppins(color: base, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.poppins(color: base, fontWeight: FontWeight.w500),
      labelLarge: GoogleFonts.poppins(color: base, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.poppins(color: secondary),
      labelSmall: GoogleFonts.poppins(color: secondary),
      displayLarge: GoogleFonts.poppins(color: base),
      displayMedium: GoogleFonts.poppins(color: base),
      headlineMedium:
          GoogleFonts.poppins(color: base, fontWeight: FontWeight.w700),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _buildTextTheme(
          AppColors.lightTextPrimary, AppColors.lightTextSecondary),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        surfaceContainerHighest: AppColors.lightBackground,
        outline: AppColors.lightDivider,
      ),
      dividerColor: AppColors.lightDivider,
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        shadowColor: Colors.black.withValues(alpha: 0.06),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        labelStyle: GoogleFonts.poppins(color: AppColors.lightTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _buildTextTheme(
          AppColors.darkTextPrimary, AppColors.darkTextSecondary),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerHighest: AppColors.darkSurfaceElevated,
        outline: AppColors.darkDivider,
      ),
      dividerColor: AppColors.darkDivider,
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        shadowColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        labelStyle: GoogleFonts.poppins(color: AppColors.darkTextSecondary),
        hintStyle: GoogleFonts.poppins(color: AppColors.darkTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Sistema de Gestión de Tatuajes',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: themeProvider.themeMode,
      home: const MainScreen(),
    );
  }
}

// ─── Navigation Item Model ────────────────────────────────────────────────────
class NavigationItem {
  final IconData icon;
  final String label;
  final Color accentColor;
  NavigationItem({
    required this.icon,
    required this.label,
    required this.accentColor,
  });
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int citasHoyCount = 0;
  bool _sidebarCollapsed = false;

  static const double _expandedWidth = 260.0;
  static const double _collapsedWidth = 72.0;

  @override
  void initState() {
    super.initState();
    _loadCitasHoy();
  }

  Future<void> _loadCitasHoy() async {
    try {
      final citas = await DatabaseHelper.instance.getCitas();
      final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final citasDeHoy = citas.where((cita) => cita['fecha'] == hoy).length;
      if (mounted) {
        setState(() => citasHoyCount = citasDeHoy);
      }
    } catch (e) {
      // silent
    }
  }

  void _onNavigate(int index) {
    setState(() => _selectedIndex = index);
    _loadCitasHoy();
  }

  void _toggleSidebar() {
    setState(() => _sidebarCollapsed = !_sidebarCollapsed);
  }

  final List<NavigationItem> _navItems = [
    NavigationItem(
        icon: Icons.home_rounded,
        label: 'Inicio',
        accentColor: AppColors.homeAccent),
    NavigationItem(
        icon: Icons.people_rounded,
        label: 'Clientes',
        accentColor: AppColors.clientesAccent),
    NavigationItem(
        icon: Icons.brush_rounded,
        label: 'Tatuadores',
        accentColor: AppColors.tatuadoresAccent),
    NavigationItem(
        icon: Icons.palette_rounded,
        label: 'Diseños',
        accentColor: AppColors.disenosAccent),
    NavigationItem(
        icon: Icons.calendar_today_rounded,
        label: 'Citas',
        accentColor: AppColors.citasAccent),
    NavigationItem(
        icon: Icons.attach_money_rounded,
        label: 'Pagos',
        accentColor: AppColors.pagosAccent),
    NavigationItem(
        icon: Icons.assessment_rounded,
        label: 'Reportes',
        accentColor: AppColors.reportesAccent),
    NavigationItem(
        icon: Icons.settings_rounded,
        label: 'Configuración',
        accentColor: AppColors.configAccent),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    final List<Widget> screens = [
      HomeScreen(onNavigate: _onNavigate),
      const ClientesScreen(),
      const TatuadoresScreen(),
      const DisenosScreen(),
      const CitasScreen(),
      const PagosScreen(),
      const ReportesScreen(),
      const ConfiguracionScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          // ─── SIDEBAR ────────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            width: _sidebarCollapsed ? _collapsedWidth : _expandedWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkSidebarStart, AppColors.darkSidebarEnd]
                    : [AppColors.lightSidebarStart, AppColors.lightSidebarEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.25),
                  blurRadius: 32,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Column(
                children: [
                  // ── Logo / Header ────────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOutCubic,
                    padding: EdgeInsets.only(
                      top: 24,
                      bottom: 16,
                      left: _sidebarCollapsed ? 0 : 20,
                      right: _sidebarCollapsed ? 0 : 8,
                    ),
                    child: _sidebarCollapsed
                        ? _buildCollapsedHeader()
                        : _buildExpandedHeader(),
                  ),

                  // ── Divider ──────────────────────────────────────────────
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.12),
                    indent: 16,
                    endIndent: 16,
                  ),
                  const SizedBox(height: 8),

                  // ── Nav Items ────────────────────────────────────────────
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 10),
                      itemCount: _navItems.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIndex == index;
                        return _buildNavItem(
                          _navItems[index],
                          isSelected,
                          index,
                          () => _onNavigate(index),
                        );
                      },
                    ),
                  ),

                  // ── Footer ───────────────────────────────────────────────
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.12),
                    indent: 16,
                    endIndent: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 10),
                    child: _buildThemeToggle(themeProvider, isDark),
                  ),
                  if (!_sidebarCollapsed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        'Desarrollado por FutureDevs',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.25),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── CONTENT AREA ────────────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.03, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: screens[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Collapsed header (just logo icon + toggle) ─────────────────────────────
  Widget _buildCollapsedHeader() {
    return Column(
      children: [
        _buildToggleButton(),
      ],
    );
  }

  // ── Expanded header (logo + title + toggle) ─────────────────────────────────
  Widget _buildExpandedHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'InkManager',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        _buildToggleButton(),
      ],
    );
  }

  Widget _buildToggleButton() {
    return Tooltip(
      message: _sidebarCollapsed ? 'Expandir menú' : 'Colapsar menú',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _toggleSidebar,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: AnimatedRotation(
              turns: _sidebarCollapsed ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider, bool isDark) {
    if (_sidebarCollapsed) {
      return Tooltip(
        message: isDark ? 'Modo Claro' : 'Modo Oscuro',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => themeProvider.toggleTheme(),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isDark ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                  key: ValueKey(isDark),
                  color: isDark
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFFE0E7FF),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => themeProvider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                key: ValueKey(isDark),
                color:
                    isDark ? const Color(0xFFFBBF24) : const Color(0xFFE0E7FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isDark ? 'Modo Claro' : 'Modo Oscuro',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    NavigationItem item,
    bool isSelected,
    int index,
    VoidCallback onTap,
  ) {
    final showBadge = index == 4 && citasHoyCount > 0;

    final navItem = Tooltip(
      message: _sidebarCollapsed ? item.label : '',
      preferBelow: false,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: 0.06),
          splashColor: item.accentColor.withValues(alpha: 0.15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: EdgeInsets.symmetric(
              horizontal: _sidebarCollapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? item.accentColor.withValues(alpha: 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: isSelected
                  ? Border.all(
                      color: item.accentColor.withValues(alpha: 0.35),
                      width: 1,
                    )
                  : null,
            ),
            child: _sidebarCollapsed
                ? _buildCollapsedNavContent(item, isSelected, showBadge)
                : _buildExpandedNavContent(item, isSelected, showBadge),
          ),
        ),
      ),
    );

    return navItem;
  }

  Widget _buildCollapsedNavContent(
      NavigationItem item, bool isSelected, bool showBadge) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? item.accentColor.withValues(alpha: 0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: isSelected
                  ? item.accentColor
                  : Colors.white.withValues(alpha: 0.5),
              size: 22,
            ),
          ),
          if (showBadge)
            Positioned(
              top: -4,
              right: -4,
              child: _buildBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedNavContent(
      NavigationItem item, bool isSelected, bool showBadge) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? item.accentColor.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                item.icon,
                color: isSelected
                    ? item.accentColor
                    : Colors.white.withValues(alpha: 0.5),
                size: 20,
              ),
            ),
            if (showBadge)
              Positioned(
                top: -4,
                right: -4,
                child: _buildBadge(),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.label,
            style: GoogleFonts.poppins(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.5),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13.5,
              letterSpacing: 0.1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isSelected)
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: item.accentColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: item.accentColor.withValues(alpha: 0.6),
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.citasAccent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.lightSidebarStart, width: 2),
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Center(
        child: Text(
          citasHoyCount.toString(),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
