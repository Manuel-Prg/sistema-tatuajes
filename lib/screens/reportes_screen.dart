import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  Map<String, int> stats = {};
  double totalIngresos = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final estadisticas = await DatabaseHelper.instance.getEstadisticas();
      final ingresos = await DatabaseHelper.instance.getTotalIngresos();
      setState(() {
        stats = {
          'clientes': estadisticas['clientes'] ?? 0,
          'tatuadores': estadisticas['tatuadores'] ?? 0,
          'citas': estadisticas['citas'] ?? 0,
          'diseños': estadisticas['diseños'] ?? 0,
        };
        totalIngresos = ingresos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        stats = {'clientes': 0, 'tatuadores': 0, 'citas': 0, 'diseños': 0};
        totalIngresos = 0.0;
        isLoading = false;
      });
    }
  }

  // Generar reporte de clientes
  Future<void> _generarReporteClientes() async {
    try {
      final clientes = await DatabaseHelper.instance.getClientes();

      if (clientes.isEmpty) {
        _mostrarMensaje('No hay clientes para exportar', false);
        return;
      }

      String csv = 'ID,Nombre,Apellido,Correo,Teléfono,Fecha Registro\n';
      for (var cliente in clientes) {
        csv += '${cliente['id_cliente']},'
            '${cliente['nombre']},'
            '${cliente['apellido']},'
            '${cliente['correo'] ?? ''},'
            '${cliente['telefono']},'
            '${cliente['fecha_registro'] ?? ''}\n';
      }

      await _guardarArchivo(csv, 'reporte_clientes.csv');
      _mostrarMensaje('Reporte de clientes exportado exitosamente', true);
    } catch (e) {
      _mostrarMensaje('Error al generar reporte: $e', false);
    }
  }

  // Generar reporte de ingresos
  Future<void> _generarReporteIngresos() async {
    try {
      final pagos = await DatabaseHelper.instance.getPagos();

      if (pagos.isEmpty) {
        _mostrarMensaje('No hay pagos para exportar', false);
        return;
      }

      String csv = 'ID,Cliente,Monto,Método Pago,Estado,Fecha\n';
      for (var pago in pagos) {
        csv += '${pago['id_pago']},'
            '${pago['cliente'] ?? 'N/A'},'
            '${pago['monto']},'
            '${pago['metodo_pago'] ?? 'N/A'},'
            '${pago['estado']},'
            '${pago['fecha']}\n';
      }

      csv += '\nTOTAL INGRESOS,,,,$totalIngresos\n';

      await _guardarArchivo(csv, 'reporte_ingresos.csv');
      _mostrarMensaje('Reporte de ingresos exportado exitosamente', true);
    } catch (e) {
      _mostrarMensaje('Error al generar reporte: $e', false);
    }
  }

  // Generar reporte de citas
  Future<void> _generarReporteCitas() async {
    try {
      final citas = await DatabaseHelper.instance.getCitas();

      if (citas.isEmpty) {
        _mostrarMensaje('No hay citas para exportar', false);
        return;
      }

      String csv = 'ID,Fecha,Hora,Cliente,Tatuador,Diseño,Estado,Notas\n';
      for (var cita in citas) {
        csv += '${cita['id_cita']},'
            '${cita['fecha']},'
            '${cita['hora']},'
            '${cita['cliente'] ?? 'N/A'},'
            '${cita['tatuador'] ?? 'N/A'},'
            '${cita['diseño'] ?? 'N/A'},'
            '${cita['estado']},'
            '"${cita['notas'] ?? ''}"\n';
      }

      await _guardarArchivo(csv, 'reporte_citas.csv');
      _mostrarMensaje('Reporte de citas exportado exitosamente', true);
    } catch (e) {
      _mostrarMensaje('Error al generar reporte: $e', false);
    }
  }

  // Generar reporte de tatuadores
  Future<void> _generarReporteTatuadores() async {
    try {
      final tatuadores = await DatabaseHelper.instance.getTatuadores();

      if (tatuadores.isEmpty) {
        _mostrarMensaje('No hay tatuadores para exportar', false);
        return;
      }

      String csv = 'ID,Nombre,Apellido,Especialidad,Teléfono,Disponibilidad\n';
      for (var tatuador in tatuadores) {
        csv += '${tatuador['id_tatuador']},'
            '${tatuador['nombre']},'
            '${tatuador['apellido']},'
            '${tatuador['especialidad'] ?? 'N/A'},'
            '${tatuador['telefono']},'
            '${tatuador['disponibilidad']}\n';
      }

      await _guardarArchivo(csv, 'reporte_tatuadores.csv');
      _mostrarMensaje('Reporte de tatuadores exportado exitosamente', true);
    } catch (e) {
      _mostrarMensaje('Error al generar reporte: $e', false);
    }
  }

  // Generar reporte de diseños
  Future<void> _generarReporteDisenos() async {
    try {
      final disenos = await DatabaseHelper.instance.getDisenos();

      if (disenos.isEmpty) {
        _mostrarMensaje('No hay disenos para exportar', false);
        return;
      }

      String csv = 'ID,Nombre,Categoria,Estilo,Tamano,Precio,Descripcion\n';
      for (var diseno in disenos) {
        csv += '${diseno['id_diseno']},'
            '${diseno['nombre']},'
            '${diseno['categoria'] ?? 'N/A'},'
            '${diseno['estilo'] ?? 'N/A'},'
            '${diseno['tamano'] ?? 'N/A'},'
            '${diseno['precio']},'
            '"${diseno['descripcion'] ?? ''}"\n';
      }

      await _guardarArchivo(csv, 'reporte_disenos.csv');
      _mostrarMensaje('Reporte de disenos exportado exitosamente', true);
    } catch (e) {
      _mostrarMensaje('Error al generar reporte: $e', false);
    }
  }

  // Generar reporte completo
  Future<void> _generarReporteCompleto() async {
    try {
      String csv =
          '========== REPORTE COMPLETO - SISTEMA DE TATUAJES ==========\n';
      csv +=
          'Fecha de generación: ${DateTime.now().toString().split('.')[0]}\n\n';

      // Estadísticas generales
      csv += '===== ESTADÍSTICAS GENERALES =====\n';
      csv += 'Total Clientes,$stats["clientes"]\n';
      csv += 'Total Tatuadores,$stats["tatuadores"]\n';
      csv += 'Total Citas,$stats["citas"]\n';
      csv += 'Total Diseños,$stats["diseños"]\n';
      csv += 'Ingresos Totales,\$$totalIngresos\n\n';

      // Clientes
      csv += '===== CLIENTES =====\n';
      csv += 'ID,Nombre,Apellido,Correo,Teléfono\n';
      final clientes = await DatabaseHelper.instance.getClientes();
      for (var cliente in clientes) {
        csv += '${cliente['id_cliente']},'
            '${cliente['nombre']},'
            '${cliente['apellido']},'
            '${cliente['correo'] ?? ''},'
            '${cliente['telefono']}\n';
      }
      csv += '\n';

      // Tatuadores
      csv += '===== TATUADORES =====\n';
      csv += 'ID,Nombre,Apellido,Especialidad,Disponibilidad\n';
      final tatuadores = await DatabaseHelper.instance.getTatuadores();
      for (var tatuador in tatuadores) {
        csv += '${tatuador['id_tatuador']},'
            '${tatuador['nombre']},'
            '${tatuador['apellido']},'
            '${tatuador['especialidad'] ?? 'N/A'},'
            '${tatuador['disponibilidad']}\n';
      }
      csv += '\n';

      // Citas
      csv += '===== CITAS =====\n';
      csv += 'ID,Fecha,Hora,Cliente,Tatuador,Estado\n';
      final citas = await DatabaseHelper.instance.getCitas();
      for (var cita in citas) {
        csv += '${cita['id_cita']},'
            '${cita['fecha']},'
            '${cita['hora']},'
            '${cita['cliente'] ?? 'N/A'},'
            '${cita['tatuador'] ?? 'N/A'},'
            '${cita['estado']}\n';
      }
      csv += '\n';

      // Pagos
      csv += '===== PAGOS =====\n';
      csv += 'ID,Cliente,Monto,Método,Estado,Fecha\n';
      final pagos = await DatabaseHelper.instance.getPagos();
      for (var pago in pagos) {
        csv += '${pago['id_pago']},'
            '${pago['cliente'] ?? 'N/A'},'
            '${pago['monto']},'
            '${pago['metodo_pago'] ?? 'N/A'},'
            '${pago['estado']},'
            '${pago['fecha']}\n';
      }
      csv += '\n';

      csv += '========== FIN DEL REPORTE ==========\n';

      await _guardarArchivo(csv, 'reporte_completo.csv');
      _mostrarMensaje('Reporte completo exportado exitosamente', true);
    } catch (e) {
      _mostrarMensaje('Error al generar reporte completo: $e', false);
    }
  }

  // Guardar archivo en el sistema
  Future<void> _guardarArchivo(String contenido, String nombreArchivo) async {
    try {
      // Obtener directorio de documentos
      final directoryPath = await getApplicationDocumentsPath();

      // Crear el directorio si no existe
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final path = '$directoryPath\\$nombreArchivo';

      // Crear archivo
      final file = File(path);
      await file.writeAsString(contenido);

      print('Archivo guardado en: $path');
    } catch (e) {
      throw Exception('Error al guardar archivo: $e');
    }
  }

  // Obtener ruta de documentos según la plataforma
  Future<String> getApplicationDocumentsPath() async {
    if (Platform.isWindows) {
      // En Windows, usar la carpeta Documentos del usuario
      final String home = Platform.environment['USERPROFILE'] ?? '';
      return '$home\\Documents\\SistemaTatuajes';
    } else {
      // En otros sistemas, usar path_provider
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  // Mostrar mensaje al usuario
  void _mostrarMensaje(String mensaje, bool esExito) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              esExito ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        backgroundColor: esExito ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
        action: esExito
            ? SnackBarAction(
                label: 'Ver',
                textColor: Colors.white,
                onPressed: () async {
                  final path = await getApplicationDocumentsPath();
                  _mostrarDialogoRuta(path);
                },
              )
            : null,
      ),
    );
  }

  // Mostrar diálogo con la ruta del archivo
  void _mostrarDialogoRuta(String ruta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.folder_rounded, color: AppColors.reportesAccent),
            SizedBox(width: 12),
            Text('Archivo Guardado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El archivo se guardó en:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                ruta,
                style: GoogleFonts.robotoMono(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.reportesAccent.withOpacity(0.2),
                              AppColors.reportesAccent.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.assessment_rounded,
                          color: AppColors.reportesAccent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reportes y Estadísticas',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Exporta reportes en formato CSV',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () {
                          setState(() => isLoading = true);
                          _loadData();
                        },
                        tooltip: 'Actualizar',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Stats Grid
                  const SectionHeader(title: 'Resumen General'),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.4,
                    children: [
                      AnimatedStatCard(
                        label: 'Clientes',
                        value: stats['clientes'].toString(),
                        icon: Icons.people_rounded,
                        color: AppColors.clientesAccent,
                        trend: '+12%',
                      ),
                      AnimatedStatCard(
                        label: 'Tatuadores',
                        value: stats['tatuadores'].toString(),
                        icon: Icons.brush_rounded,
                        color: AppColors.tatuadoresAccent,
                        trend: '+5%',
                      ),
                      AnimatedStatCard(
                        label: 'Citas',
                        value: stats['citas'].toString(),
                        icon: Icons.event_rounded,
                        color: AppColors.citasAccent,
                        trend: '+18%',
                      ),
                      AnimatedStatCard(
                        label: 'Ingresos',
                        value: '\$${totalIngresos.toStringAsFixed(0)}',
                        icon: Icons.attach_money_rounded,
                        color: AppColors.pagosAccent,
                        trend: '+25%',
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Opciones de Exportación
                  const SectionHeader(
                    title: 'Exportar Reportes',
                    subtitle: 'Descarga reportes en formato CSV',
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 3,
                    children: [
                      _buildReportButton(
                        'Reporte de Clientes',
                        'Exportar lista completa de clientes',
                        Icons.people_rounded,
                        AppColors.clientesAccent,
                        _generarReporteClientes,
                      ),
                      _buildReportButton(
                        'Reporte de Ingresos',
                        'Exportar análisis financiero completo',
                        Icons.attach_money_rounded,
                        AppColors.pagosAccent,
                        _generarReporteIngresos,
                      ),
                      _buildReportButton(
                        'Reporte de Citas',
                        'Exportar calendario de citas',
                        Icons.event_rounded,
                        AppColors.citasAccent,
                        _generarReporteCitas,
                      ),
                      _buildReportButton(
                        'Reporte de Tatuadores',
                        'Exportar lista de tatuadores',
                        Icons.brush_rounded,
                        AppColors.tatuadoresAccent,
                        _generarReporteTatuadores,
                      ),
                      _buildReportButton(
                        'Reporte de Disenos',
                        'Exportar catalogo de disenos',
                        Icons.palette_rounded,
                        AppColors.disenosAccent,
                        _generarReporteDisenos,
                      ),
                      _buildReportButton(
                        'Reporte Completo',
                        'Exportar todos los datos del sistema',
                        Icons.description_rounded,
                        AppColors.reportesAccent,
                        _generarReporteCompleto,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Información del Sistema
                  const SectionHeader(title: 'Información del Sistema'),
                  const SizedBox(height: 20),
                  PrimaryCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.reportesAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.info_rounded,
                                color: AppColors.reportesAccent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Detalles del Proyecto',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildInfoRow('Alumno:', 'Luis Eduardo'),
                        _buildInfoRow('Materia:',
                            'Seminario de Desarrollo Tecnológico 2'),
                        _buildInfoRow(
                            'Proyecto:', 'Sistema de Gestión de Tatuajes'),
                        _buildInfoRow('Tecnología:', 'Flutter + SQLite'),
                        _buildInfoRow('Versión:', '2.0 Funcional'),
                        _buildInfoRow('Fecha:', 'Octubre 2025'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.homeAccent.withOpacity(0.1),
                                AppColors.homeAccent.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_rounded,
                                  color: AppColors.homeAccent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Sistema completamente funcional con exportación de reportes',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.homeAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildReportButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return PrimaryCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.download_rounded, size: 20, color: color),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
