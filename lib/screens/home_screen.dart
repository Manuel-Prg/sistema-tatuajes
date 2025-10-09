import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Map<String, int> stats = {
    'clientes': 0,
    'tatuadores': 0,
    'citas': 0,
    'diseños': 0,
  };
  double totalIngresos = 0.0;
  bool isLoading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final estadisticas = await DatabaseHelper.instance.getEstadisticas();
    final ingresos = await DatabaseHelper.instance.getTotalIngresos();

    setState(() {
      stats = estadisticas;
      totalIngresos = ingresos;
      isLoading = false;
    });

    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header con diseño mejorado
                    _buildWelcomeHeader(),
                    const SizedBox(height: 32),

                    // Stats Grid con animación
                    _buildStatsSection(),
                    const SizedBox(height: 40),

                    // Quick Actions mejorado
                    _buildQuickActionsSection(),
                    const SizedBox(height: 40),

                    // Recent Activity (opcional)
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = '¡Buenos días!';
    IconData greetingIcon = Icons.wb_sunny;

    if (hour >= 12 && hour < 18) {
      greeting = '¡Buenas tardes!';
      greetingIcon = Icons.wb_twilight;
    } else if (hour >= 18) {
      greeting = '¡Buenas noches!';
      greetingIcon = Icons.nights_stay;
    }

    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'es').format(now);

    return GradientCard(
      gradientColors: [
        AppColors.homeAccent,
        AppColors.homeAccent.withOpacity(0.8),
      ],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(greetingIcon, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      greeting,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Sistema de Gestión de Tatuajes',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.colorize,
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    // Build a concrete list from the stats map so we can index it in the grid
    final statItems = [
      {
        'title': 'Clientes',
        'value': stats['clientes'].toString(),
        'icon': Icons.people_rounded,
        'color': AppColors.clientesAccent,
        'trend': '+12%',
      },
      {
        'title': 'Tatuadores',
        'value': stats['tatuadores'].toString(),
        'icon': Icons.brush_rounded,
        'color': AppColors.tatuadoresAccent,
        'trend': '+5%',
      },
      {
        'title': 'Citas',
        'value': stats['citas'].toString(),
        'icon': Icons.event_rounded,
        'color': AppColors.citasAccent,
        'trend': '+18%',
      },
      {
        'title': 'Diseños',
        'value': stats['diseños'].toString(),
        'icon': Icons.palette_rounded,
        'color': AppColors.disenosAccent,
        'trend': '+8%',
      },
      {
        'title': 'Ingresos',
        'value': '\$${totalIngresos.toStringAsFixed(2)}',
        'icon': Icons.attach_money_rounded,
        'color': AppColors.pagosAccent,
        'trend': '+25%',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Estadísticas Generales',
          subtitle: 'Vista general del sistema',
        ),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          // Choose columns based on width
          int cols = 1;
          if (constraints.maxWidth > 1200) {
            cols = 3;
          } else if (constraints.maxWidth > 800) {
            cols = 2;
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: constraints.maxWidth / (cols * 220),
            ),
            itemCount: statItems.length,
            itemBuilder: (context, index) {
              final item = statItems[index];
              return _statCard(item);
            },
          );
        }),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    final actions = [
      _QuickActionData(
        title: 'Nueva Cita',
        subtitle: 'Agendar cita para cliente',
        icon: Icons.add_circle_outline_rounded,
        color: AppColors.citasAccent,
        onTap: () {
          // Navegar a citas
        },
      ),
      _QuickActionData(
        title: 'Agregar Cliente',
        subtitle: 'Registrar nuevo cliente',
        icon: Icons.person_add_rounded,
        color: AppColors.clientesAccent,
        onTap: () {
          // Navegar a clientes
        },
      ),
      _QuickActionData(
        title: 'Registrar Pago',
        subtitle: 'Añadir transacción',
        icon: Icons.payment_rounded,
        color: AppColors.pagosAccent,
        onTap: () {
          // Navegar a pagos
        },
      ),
      _QuickActionData(
        title: 'Nuevo Diseño',
        subtitle: 'Subir diseño de tatuaje',
        icon: Icons.add_photo_alternate_rounded,
        color: AppColors.disenosAccent,
        onTap: () {
          // Navegar a diseños
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Accesos Rápidos',
          subtitle: 'Acciones frecuentes del sistema',
        ),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          final itemWidth = 160.0;
          final cols =
              (constraints.maxWidth / (itemWidth + 24)).floor().clamp(1, 4);
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: actions.map((action) {
              return SizedBox(
                width: (constraints.maxWidth / cols) - 16,
                child: InkWell(
                  onTap: action.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
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
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _statCard(Map<String, dynamic> item) {
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item['icon'], color: item['color'], size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item['color'].withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item['trend'],
                    style: GoogleFonts.poppins(
                        color: item['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item['value'],
              style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 6),
          Text(item['title'],
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Actividad Reciente',
          subtitle: 'Últimas acciones del sistema',
        ),
        const SizedBox(height: 20),
        PrimaryCard(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.person_add,
                title: 'Nuevo cliente registrado',
                subtitle: 'Juan Pérez - hace 2 horas',
                color: AppColors.clientesAccent,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                icon: Icons.event,
                title: 'Cita agendada',
                subtitle: 'María González - mañana 10:00 AM',
                color: AppColors.citasAccent,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                icon: Icons.attach_money,
                title: 'Pago registrado',
                subtitle: '\$1,500 MXN - Carlos Rodríguez',
                color: AppColors.pagosAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.black26,
      ),
    );
  }
}

class _QuickActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
