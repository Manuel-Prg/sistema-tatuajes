import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate; // ← Agregamos este parámetro

  const HomeScreen({super.key, this.onNavigate}); // ← Y aquí también

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> citas = [];

  Map<String, int> stats = {
    'clientes': 0,
    'tatuadores': 0,
    'citas': 0,
    'diseños': 0,
  };
  double totalIngresos = 0.0;
  List<Map<String, dynamic>> citasHoy = [];
  List<Map<String, dynamic>> proximasCitas = [];
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
    final todasCitas = await DatabaseHelper.instance.getCitas();

    // Filtrar citas de hoy
    final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final citasDeHoy =
        todasCitas.where((cita) => cita['fecha'] == hoy).toList();

    // Próximas 3 citas
    final ahora = DateTime.now();
    final proximas = todasCitas
        .where((cita) {
          final fechaCita = DateTime.tryParse(cita['fecha'] ?? '');
          return fechaCita != null && fechaCita.isAfter(ahora);
        })
        .take(3)
        .toList();

    setState(() {
      stats = estadisticas;
      totalIngresos = ingresos;
      citas.clear();
      citas.addAll(todasCitas);
      citasHoy = citasDeHoy;
      proximasCitas = proximas;
      isLoading = false;
    });

    _fadeController.forward();
  }

  void _navigateTo(int index) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(index);
    }
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
                    _buildWelcomeHeader(),
                    const SizedBox(height: 32),

                    // Notificación de citas del día
                    if (citasHoy.isNotEmpty) _buildCitasDelDia(),
                    if (citasHoy.isNotEmpty) const SizedBox(height: 24),

                    _buildStatsSection(),
                    const SizedBox(height: 40),

                    // Gráficas
                    _buildChartsSection(),
                    const SizedBox(height: 40),

                    _buildQuickActionsSection(),
                    const SizedBox(height: 40),

                    // Próximas citas
                    _buildProximasCitas(),
                  ],
                ),
              ),
            ),
    );
  }

  // ============= NOTIFICACIÓN CITAS DEL DÍA =============
  Widget _buildCitasDelDia() {
    return GradientCard(
      gradientColors: [
        AppColors.citasAccent,
        AppColors.citasAccent.withOpacity(0.8),
      ],
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Tienes ${citasHoy.length} cita${citasHoy.length != 1 ? 's' : ''} hoy!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Revisa tu agenda para el día',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _navigateTo(4),
            icon: const Icon(Icons.calendar_today_rounded),
            label: const Text('Ver Citas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.citasAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ============= GRÁFICAS =============
  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Análisis y Tendencias',
          subtitle: 'Rendimiento del negocio',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildIngresosChart()),
            const SizedBox(width: 20),
            Expanded(child: _buildCitasChart()),
          ],
        ),
      ],
    );
  }

  // Gráfica de Ingresos (últimos 6 meses)
  Widget _buildIngresosChart() {
    // Calcular ingresos reales por mes (últimos 6 meses)
    final now = DateTime.now();
    List<FlSpot> spots = [];
    List<DateTime> calculatedDates = [];

    for (int i = 5; i >= 0; i--) {
      final mes = DateTime(now.year, now.month - i, 1);
      calculatedDates.add(mes);
      // Por ahora usamos datos de ejemplo proporcionales al total
      final valor = (totalIngresos / 6) /
          1000; // Dividir entre 6 meses y convertir a miles
      spots.add(FlSpot((5 - i).toDouble(), valor));
    }
    print(calculatedDates);

    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.pagosAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.pagosAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ingresos Mensuales',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\${value.toInt()}k',
                          style: GoogleFonts.poppins(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final now = DateTime.now();
                        final mes = DateTime(
                            now.year, now.month - (5 - value.toInt()), 1);
                        final nombreMes = DateFormat('MMM', 'es').format(mes);
                        return Text(
                          nombreMes,
                          style: GoogleFonts.poppins(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.pagosAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.pagosAccent.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Gráfica de Citas por Estado (DATOS REALES)
  Widget _buildCitasChart() {
    // Contar citas por estado
    int pendientes = 0;
    int confirmadas = 0;
    int completadas = 0;
    int canceladas = 0;

    for (var cita in citas) {
      switch (cita['estado']) {
        case 'Pendiente':
          pendientes++;
          break;
        case 'Confirmada':
          confirmadas++;
          break;
        case 'Completada':
          completadas++;
          break;
        case 'Cancelada':
          canceladas++;
          break;
      }
    }

    final total = pendientes + confirmadas + completadas + canceladas;

    // Si no hay citas, mostrar mensaje
    if (total == 0) {
      return PrimaryCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.citasAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pie_chart_rounded,
                    color: AppColors.citasAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Estado de Citas',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy_rounded,
                        size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No hay citas registradas',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Calcular porcentajes
    final porcPendientes = (pendientes / total * 100).round();
    final porcConfirmadas = (confirmadas / total * 100).round();
    final porcCompletadas = (completadas / total * 100).round();
    final porcCanceladas = (canceladas / total * 100).round();

    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.citasAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: AppColors.citasAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Estado de Citas',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  if (pendientes > 0)
                    PieChartSectionData(
                      value: pendientes.toDouble(),
                      title: '$porcPendientes%',
                      color: Colors.orange,
                      radius: 50,
                      titleStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (confirmadas > 0)
                    PieChartSectionData(
                      value: confirmadas.toDouble(),
                      title: '$porcConfirmadas%',
                      color: Colors.blue,
                      radius: 50,
                      titleStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (completadas > 0)
                    PieChartSectionData(
                      value: completadas.toDouble(),
                      title: '$porcCompletadas%',
                      color: Colors.green,
                      radius: 50,
                      titleStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (canceladas > 0)
                    PieChartSectionData(
                      value: canceladas.toDouble(),
                      title: '$porcCanceladas%',
                      color: Colors.red,
                      radius: 50,
                      titleStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Pendiente', Colors.orange),
        _buildLegendItem('Confirmada', Colors.blue),
        _buildLegendItem('Completada', Colors.green),
        _buildLegendItem('Cancelada', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11),
        ),
      ],
    );
  }

  // ============= PRÓXIMAS CITAS =============
  Widget _buildProximasCitas() {
    if (proximasCitas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionHeader(
              title: 'Próximas Citas',
              subtitle: 'Agenda programada',
            ),
            TextButton.icon(
              onPressed: () => _navigateTo(4),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Ver Todas'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...proximasCitas.map((cita) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PrimaryCard(
                onTap: () => _navigateTo(4),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.citasAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event_rounded,
                      color: AppColors.citasAccent,
                    ),
                  ),
                  title: Text(
                    cita['cliente'] ?? 'Cliente',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${cita['fecha']} • ${cita['hora']}',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cita['estado'] ?? 'Pendiente',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  // ============= RESTO DE WIDGETS (Sin cambios) =============

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
    final statItems = [
      {
        'title': 'Clientes',
        'value': stats['clientes'].toString(),
        'icon': Icons.people_rounded,
        'color': AppColors.clientesAccent,
        'trend': '+12%',
        'index': 1,
      },
      {
        'title': 'Tatuadores',
        'value': stats['tatuadores'].toString(),
        'icon': Icons.brush_rounded,
        'color': AppColors.tatuadoresAccent,
        'trend': '+5%',
        'index': 2,
      },
      {
        'title': 'Citas',
        'value': stats['citas'].toString(),
        'icon': Icons.event_rounded,
        'color': AppColors.citasAccent,
        'trend': '+18%',
        'index': 4,
      },
      {
        'title': 'Ingresos',
        'value': '\$${totalIngresos.toStringAsFixed(0)}',
        'icon': Icons.attach_money_rounded,
        'color': AppColors.pagosAccent,
        'trend': '+25%',
        'index': 5,
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
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.5,
          children: statItems.map((item) => _statCard(item)).toList(),
        ),
      ],
    );
  }

  Widget _statCard(Map<String, dynamic> item) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          if (item['index'] != null) {
            _navigateTo(item['index'] as int);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedStatCard(
          label: item['title'],
          value: item['value'],
          icon: item['icon'],
          color: item['color'],
          trend: item['trend'],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    final actions = [
      _QuickActionData(
        title: 'Nueva Cita',
        subtitle: 'Agendar cita',
        icon: Icons.add_circle_outline_rounded,
        color: AppColors.citasAccent,
        onTap: () => _navigateTo(4),
      ),
      _QuickActionData(
        title: 'Agregar Cliente',
        subtitle: 'Nuevo cliente',
        icon: Icons.person_add_rounded,
        color: AppColors.clientesAccent,
        onTap: () => _navigateTo(1),
      ),
      _QuickActionData(
        title: 'Registrar Pago',
        subtitle: 'Nueva transacción',
        icon: Icons.payment_rounded,
        color: AppColors.pagosAccent,
        onTap: () => _navigateTo(5),
      ),
      _QuickActionData(
        title: 'Nuevo Diseño',
        subtitle: 'Subir diseño',
        icon: Icons.add_photo_alternate_rounded,
        color: AppColors.disenosAccent,
        onTap: () => _navigateTo(3),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Accesos Rápidos',
          subtitle: 'Acciones frecuentes',
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children:
              actions.map((action) => _buildQuickActionCard(action)).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(_QuickActionData action) {
    return SizedBox(
      width: 160,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
