// ==================== REPORTES SCREEN ====================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database_helper.dart';

// Accent for Reportes
const Color _reportesAccent = Color(0xFF3498DB);

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  Map<String, int> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final estadisticas = await DatabaseHelper.instance.getEstadisticas();
      // Ensure the map has the expected keys with non-null int values
      setState(() {
        stats = {
          'clientes': estadisticas['clientes'] ?? 0,
          'tatuadores': estadisticas['tatuadores'] ?? 0,
          'citas': estadisticas['citas'] ?? 0,
          'diseños': estadisticas['diseños'] ?? 0,
        };
        isLoading = false;
      });
    } catch (e, st) {
      // If any error occurs, avoid leaving the loading spinner forever
      // and show a message to the user while using safe defaults.
      // ignore: avoid_print
      print('Error loading estadisticas: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar estadísticas')),
        );
        setState(() {
          stats = {'clientes': 0, 'tatuadores': 0, 'citas': 0, 'diseños': 0};
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes y Estadísticas',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Función de exportar en desarrollo')),
              );
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
                  Text(
                    'Resumen General',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grid de estadísticas
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                        'Clientes',
                        stats['clientes'].toString(),
                        Icons.people,
                        _reportesAccent,
                      ),
                      _buildStatCard(
                        'Tatuadores',
                        stats['tatuadores'].toString(),
                        Icons.brush,
                        Theme.of(context).colorScheme.primary,
                      ),
                      _buildStatCard(
                        'Citas',
                        stats['citas'].toString(),
                        Icons.calendar_today,
                        const Color(0xFFE74C3C),
                      ),
                      _buildStatCard(
                        'Diseños',
                        stats['diseños'].toString(),
                        Icons.palette,
                        Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Opciones de Reporte',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildReportButton(
                        'Reporte de Clientes',
                        Icons.people,
                        Theme.of(context).colorScheme.primary,
                        () {},
                      ),
                      _buildReportButton(
                        'Reporte de Ingresos',
                        Icons.attach_money,
                        const Color(0xFF27AE60),
                        () {},
                      ),
                      _buildReportButton(
                        'Citas Programadas',
                        Icons.event,
                        const Color(0xFFE74C3C),
                        () {},
                      ),
                      _buildReportButton(
                        'Tatuadores Activos',
                        Icons.brush,
                        const Color(0xFF9B59B6),
                        () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                'Información del Sistema',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Alumno:', 'Luis Eduardo'),
                          _buildInfoRow('Materia:',
                              'Seminario de Desarrollo Tecnológico 2'),
                          _buildInfoRow(
                              'Proyecto:', 'Sistema de Gestión de Tatuajes'),
                          _buildInfoRow('Tecnología:', 'Flutter + SQLite'),
                          _buildInfoRow('Fecha:', 'Octubre 2025'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
