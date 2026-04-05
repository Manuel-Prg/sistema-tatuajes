import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
          'depositos': estadisticas['depositos'] ?? 0,
          'historial': estadisticas['historial'] ?? 0,
        };
        totalIngresos = ingresos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        stats = {
          'clientes': 0,
          'tatuadores': 0,
          'citas': 0,
          'diseños': 0,
          'depositos': 0,
          'historial': 0,
        };
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

      final out = await _guardarArchivo(csv, 'reporte_clientes.csv');
      _mostrarMensaje(
        'Clientes exportados (${p.basename(out)})',
        true,
        exportPath: out,
      );
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

      final out = await _guardarArchivo(csv, 'reporte_ingresos.csv');
      _mostrarMensaje(
        'Ingresos exportados (${p.basename(out)})',
        true,
        exportPath: out,
      );
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

      final out = await _guardarArchivo(csv, 'reporte_citas.csv');
      _mostrarMensaje(
        'Citas exportadas (${p.basename(out)})',
        true,
        exportPath: out,
      );
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

      final out = await _guardarArchivo(csv, 'reporte_tatuadores.csv');
      _mostrarMensaje(
        'Tatuadores exportados (${p.basename(out)})',
        true,
        exportPath: out,
      );
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

      final out = await _guardarArchivo(csv, 'reporte_disenos.csv');
      _mostrarMensaje(
        'Diseños exportados (${p.basename(out)})',
        true,
        exportPath: out,
      );
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
      csv += 'Total Clientes,${stats['clientes'] ?? 0}\n';
      csv += 'Total Tatuadores,${stats['tatuadores'] ?? 0}\n';
      csv += 'Total Citas,${stats['citas'] ?? 0}\n';
      csv += 'Total Diseños,${stats['diseños'] ?? 0}\n';
      csv += 'Entradas historial cliente,${stats['historial'] ?? 0}\n';
      csv += 'Depósitos registrados,${stats['depositos'] ?? 0}\n';
      csv += 'Ingresos Totales (pagos completados),$totalIngresos\n\n';

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

      csv += '===== DEPÓSITOS =====\n';
      csv += 'ID,Cliente,Monto,Estado,Fecha,Notas\n';
      final depositos = await DatabaseHelper.instance.getDepositos();
      for (var d in depositos) {
        csv += '${d['id_deposito']},'
            '${d['cliente'] ?? 'N/A'},'
            '${d['monto']},'
            '${d['estado']},'
            '${d['fecha']},'
            '"${d['notas'] ?? ''}"\n';
      }
      csv += '\n';

      csv += '===== HISTORIAL CLIENTE (NOTAS) =====\n';
      csv += 'ID,IdCliente,Fecha,Título,Notas\n';
      final db = await DatabaseHelper.instance.database;
      final histRows = await db.query('historial_cliente',
          orderBy: 'fecha DESC');
      for (var h in histRows) {
        csv += '${h['id_historial']},'
            '${h['id_cliente']},'
            '${h['fecha']},'
            '"${h['titulo']}",'
            '"${h['notas'] ?? ''}"\n';
      }
      csv += '\n';

      csv += '========== FIN DEL REPORTE ==========\n';

      final out = await _guardarArchivo(csv, 'reporte_completo.csv');
      _mostrarMensaje(
        'Reporte completo (${p.basename(out)})',
        true,
        exportPath: out,
      );
    } catch (e) {
      _mostrarMensaje('Error al generar reporte completo: $e', false);
    }
  }

  /// Guarda texto: primero pide ubicación al usuario; si cancela, usa carpeta de documentos.
  Future<String> _guardarArchivo(String contenido, String nombreArchivo) async {
    try {
      final extOnly = p.extension(nombreArchivo).replaceFirst('.', '');
      final picked = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar reporte',
        fileName: nombreArchivo,
        type: FileType.custom,
        allowedExtensions: [extOnly.isEmpty ? 'csv' : extOnly],
      );

      if (picked != null) {
        var path = picked;
        final ext = p.extension(nombreArchivo);
        if (ext.isNotEmpty && !path.toLowerCase().endsWith(ext.toLowerCase())) {
          path += ext;
        }
        await File(path).writeAsString(contenido);
        return path;
      }

      final directoryPath = await getApplicationDocumentsPath();
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final path = p.join(directoryPath, nombreArchivo);
      await File(path).writeAsString(contenido);
      return path;
    } catch (e) {
      throw Exception('Error al guardar archivo: $e');
    }
  }

  Future<void> _generarPdfResumen() async {
    try {
      final ingresos = await DatabaseHelper.instance.getTotalIngresos();
      final depositosTotal =
          await DatabaseHelper.instance.getTotalDepositosRecibidos();

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'InkManager — Resumen',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generado: ${DateTime.now().toString().split('.').first}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 24),
                pw.Text('Clientes: ${stats['clientes'] ?? 0}'),
                pw.Text('Tatuadores: ${stats['tatuadores'] ?? 0}'),
                pw.Text('Citas: ${stats['citas'] ?? 0}'),
                pw.Text('Diseños: ${stats['diseños'] ?? 0}'),
                pw.Text('Depósitos (movimientos): ${stats['depositos'] ?? 0}'),
                pw.Text('Notas en historial: ${stats['historial'] ?? 0}'),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Ingresos por pagos completados: ${ingresos.toStringAsFixed(2)}',
                ),
                pw.Text(
                  'Total depósitos recibidos: ${depositosTotal.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ),
      );

      final bytes = await pdf.save();
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar PDF',
        fileName:
            'reporte_resumen_${DateTime.now().millisecondsSinceEpoch}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (path == null) {
        _mostrarMensaje('Exportación PDF cancelada', false);
        return;
      }
      var out = path;
      if (!out.toLowerCase().endsWith('.pdf')) out = '$out.pdf';
      await File(out).writeAsBytes(bytes);
      _mostrarMensaje('PDF guardado: ${p.basename(out)}', true);
    } catch (e) {
      _mostrarMensaje('Error al generar PDF: $e', false);
    }
  }

  // Obtener ruta de documentos según la plataforma
  Future<String> getApplicationDocumentsPath() async {
    if (Platform.isWindows) {
      // En Windows, usar la carpeta Documentos del usuario
      final String home = Platform.environment['USERPROFILE'] ?? '';
      return p.join(home, 'Documents', 'SistemaTatuajes');
    } else {
      // En otros sistemas, usar path_provider
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  // Mostrar mensaje al usuario
  void _mostrarMensaje(
    String mensaje,
    bool esExito, {
    String? exportPath,
  }) {
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
        action: esExito && exportPath != null
            ? SnackBarAction(
                label: 'Ver ruta',
                textColor: Colors.white,
                onPressed: () => _mostrarDialogoRuta(exportPath),
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
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Exporta CSV (elige carpeta) o PDF de resumen',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.45),
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
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
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
                    childAspectRatio: 2.2,
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
                    subtitle: 'CSV con diálogo de guardado, o PDF de resumen',
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
                      _buildReportButton(
                        'Resumen PDF',
                        'Documento PDF con estadísticas e ingresos',
                        Icons.picture_as_pdf_rounded,
                        Colors.deepPurple,
                        _generarPdfResumen,
                      ),
                    ],
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
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
}
