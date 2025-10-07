import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io' show Platform;
// sqflite ffi for desktop support
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/clientes_screen.dart';
import 'screens/tatuadores_screen.dart';
import 'screens/diseños_screen.dart';
import 'screens/citas_screen.dart';
import 'screens/pagos_screen.dart';
import 'screens/reportes_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize date formatting locale data to avoid LocaleDataException
  await initializeDateFormatting();

  // Initialize sqflite for desktop (Windows, Linux, macOS) using ffi
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize and set the ffi database factory for desktop platforms
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const SistemaTatuajesApp());
}

class SistemaTatuajesApp extends StatelessWidget {
  const SistemaTatuajesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestión de Tatuajes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF007AFF), // iOS blue
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: const Color(0xFF1C1C1E),
          displayColor: const Color(0xFF1C1C1E),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          elevation: 6,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1C1C1E),
          titleTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ClientesScreen(),
    const TatuadoresScreen(),
    const DisenosScreen(),
    const CitasScreen(),
    const PagosScreen(),
    const ReportesScreen(),
  ];

  final List<NavigationItem> _navItems = [
    NavigationItem(icon: Icons.home, label: 'Inicio'),
    NavigationItem(icon: Icons.people, label: 'Clientes'),
    NavigationItem(icon: Icons.brush, label: 'Tatuadores'),
    NavigationItem(icon: Icons.palette, label: 'Diseños'),
    NavigationItem(icon: Icons.calendar_today, label: 'Citas'),
    NavigationItem(icon: Icons.attach_money, label: 'Pagos'),
    NavigationItem(icon: Icons.assessment, label: 'Reportes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar (Apple-like)
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8)
                          ],
                        ),
                        child: const Icon(
                          Icons.brush_rounded,
                          size: 36,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sistema de Tatuajes',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1C1C1E),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Luis Eduardo',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6E6E73),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF2F2F7)),

                // Menu Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _navItems.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      return _buildNavItem(
                        _navItems[index],
                        isSelected,
                        () => setState(() => _selectedIndex = index),
                      );
                    },
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Seminario de Desarrollo\nTecnológico 2\nOctubre 2025',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      NavigationItem item, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2F2F7) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF007AFF)
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(item.icon,
                  color: isSelected ? Colors.white : const Color(0xFF6E6E73),
                  size: 20),
            ),
            const SizedBox(width: 12),
            Text(item.label,
                style: GoogleFonts.poppins(
                    color: isSelected
                        ? const Color(0xFF1C1C1E)
                        : const Color(0xFF6E6E73),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}
