import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
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
        primaryColor: const Color(0xFF007AFF),
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: const Color(0xFF23272F),
          displayColor: const Color(0xFF23272F),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 10,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          shadowColor: Colors.black.withOpacity(0.08),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF23272F),
          titleTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF2F4F8),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
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
  int citasHoyCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCitasHoy();
  }

  // Cargar número de citas del día
  Future<void> _loadCitasHoy() async {
    try {
      final citas = await DatabaseHelper.instance.getCitas();
      final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final citasDeHoy = citas.where((cita) => cita['fecha'] == hoy).length;

      if (mounted) {
        setState(() {
          citasHoyCount = citasDeHoy;
        });
      }
    } catch (e) {
      // Silenciosamente manejar error
    }
  }

  void _onNavigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Recargar contador cuando se navega
    _loadCitasHoy();
  }

  final List<NavigationItem> _navItems = [
    NavigationItem(icon: Icons.home, label: 'Inicio'),
    NavigationItem(icon: Icons.people, label: 'Clientes'),
    NavigationItem(icon: Icons.brush, label: 'Tatuadores'),
    NavigationItem(icon: Icons.palette, label: 'Diseños'),
    NavigationItem(icon: Icons.calendar_today, label: 'Citas'),
    NavigationItem(icon: Icons.attach_money, label: 'Pagos'),
    NavigationItem(icon: Icons.assessment, label: 'Reportes'),
    NavigationItem(icon: Icons.settings, label: 'Configuración'),
  ];

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 260,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFAFBFF), Color(0xFFE9F0FB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(22),
                  bottomRight: Radius.circular(22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 32, bottom: 18),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF4F8CFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.brush_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Sistema de Tatuajes',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF23272F),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Luis Eduardo',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF7B8494),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE3E8F0)),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _navItems.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      return KeyedSubtree(
                        key: ValueKey('nav_item_$index'),
                        child: _buildNavItem(
                          _navItems[index],
                          isSelected,
                          index,
                          () => _onNavigate(index),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18, top: 8),
                  child: Column(
                    children: [
                      const Divider(height: 1, color: Color(0xFFE3E8F0)),
                      const SizedBox(height: 10),
                      Text(
                        'Seminario de Desarrollo\nTecnológico 2\nOctubre 2025',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFB0B8C1),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF3F6FB), Color(0xFFE9F0FB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      NavigationItem item, bool isSelected, int index, VoidCallback onTap) {
    // Mostrar badge solo en Citas (índice 4) si hay citas hoy
    final showBadge = index == 4 && citasHoyCount > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        key: ValueKey(item.label),
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDF3FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF007AFF).withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF007AFF)
                        : const Color(0xFFF2F4F8),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF007AFF).withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(item.icon,
                      color:
                          isSelected ? Colors.white : const Color(0xFF7B8494),
                      size: 22),
                ),
                // Badge de notificación
                if (showBadge)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          citasHoyCount.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(item.label,
                  style: GoogleFonts.poppins(
                    color: isSelected
                        ? const Color(0xFF23272F)
                        : const Color(0xFF7B8494),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 15,
                    letterSpacing: 0.1,
                  )),
            ),
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
