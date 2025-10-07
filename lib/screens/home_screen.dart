import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import '../theme/app_colors.dart';
import '../theme/hover_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, int> stats = {
    'clientes': 0,
    'tatuadores': 0,
    'citas': 0,
    'diseños': 0,
  };
  double totalIngresos = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final estadisticas = await DatabaseHelper.instance.getEstadisticas();
    final ingresos = await DatabaseHelper.instance.getTotalIngresos();

    setState(() {
      stats = estadisticas;
      totalIngresos = ingresos;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Panel de Control',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              _loadData();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeCard(),
                  const SizedBox(height: 24),

                  // Stats Grid
                  Text(
                    'Estadísticas Generales',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsGrid(),

                  const SizedBox(height: 32),

                  // Quick Actions
                  Text(
                    'Accesos Rápidos',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeCard() {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'es').format(now);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.12),
          AppColors.homeAccent.withOpacity(0.12)
        ]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Bienvenido!',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistema de Gestión de Tatuajes',
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(
                    color: Colors.black45,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.colorize,
              size: 50,
              color: AppColors.homeAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final statsData = [
      StatCard(
        title: 'Clientes',
        value: stats['clientes'].toString(),
        icon: Icons.people,
        color: const Color(0xFF3498DB),
        trend: '+12%',
      ),
      StatCard(
        title: 'Tatuadores',
        value: stats['tatuadores'].toString(),
        icon: Icons.brush,
        color: const Color(0xFF9B59B6),
        trend: '+5%',
      ),
      StatCard(
        title: 'Citas',
        value: stats['citas'].toString(),
        icon: Icons.calendar_today,
        color: const Color(0xFFE74C3C),
        trend: '+18%',
      ),
      StatCard(
        title: 'Diseños',
        value: stats['diseños'].toString(),
        icon: Icons.palette,
        color: const Color(0xFFF39C12),
        trend: '+8%',
      ),
      StatCard(
        title: 'Ingresos Totales',
        value: '\$${totalIngresos.toStringAsFixed(2)}',
        icon: Icons.attach_money,
        color: const Color(0xFF27AE60),
        trend: '+25%',
        isLarge: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: statsData.length,
      itemBuilder: (context, index) {
        final stat = statsData[index];
        return _buildStatCard(stat);
      },
    );
  }

  Widget _buildStatCard(StatCard stat) {
    return HoverCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: stat.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    stat.icon,
                    color: stat.color,
                    size: 28,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stat.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    stat.trend,
                    style: GoogleFonts.poppins(
                      color: stat.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              stat.value,
              style: GoogleFonts.poppins(
                fontSize: stat.isLarge ? 28 : 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              stat.title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      QuickAction(
        title: 'Nueva Cita',
        icon: Icons.add_circle,
        color: AppColors.homeAccent,
        onTap: () {},
      ),
      QuickAction(
        title: 'Agregar Cliente',
        icon: Icons.person_add,
        color: AppColors.clientesAccent,
        onTap: () {},
      ),
      QuickAction(
        title: 'Registrar Pago',
        icon: Icons.payment,
        color: AppColors.pagosAccent,
        onTap: () {},
      ),
      QuickAction(
        title: 'Nuevo Diseño',
        icon: Icons.add_photo_alternate,
        color: AppColors.disenosAccent,
        onTap: () {},
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: actions.map((action) {
        return InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 160,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: action.color.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(action.icon, color: action.color, size: 36),
                const SizedBox(height: 12),
                Text(
                  action.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isLarge;

  StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    this.isLarge = false,
  });
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
