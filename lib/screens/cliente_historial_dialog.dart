import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';
import '../image_helper.dart';
import '../theme/app_colors.dart';

/// Historial clínico / visual por cliente (notas y foto opcional).
Future<void> showClienteHistorialDialog(
  BuildContext context, {
  required int idCliente,
  required String nombreCompleto,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _ClienteHistorialDialog(
      idCliente: idCliente,
      nombreCompleto: nombreCompleto,
    ),
  );
}

class _ClienteHistorialDialog extends StatefulWidget {
  final int idCliente;
  final String nombreCompleto;

  const _ClienteHistorialDialog({
    required this.idCliente,
    required this.nombreCompleto,
  });

  @override
  State<_ClienteHistorialDialog> createState() =>
      _ClienteHistorialDialogState();
}

class _ClienteHistorialDialogState extends State<_ClienteHistorialDialog> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows =
        await DatabaseHelper.instance.getHistorialCliente(widget.idCliente);
    if (mounted) {
      setState(() {
        _items = rows;
        _loading = false;
      });
    }
  }

  Future<void> _agregarEntrada() async {
    final tituloCtrl = TextEditingController();
    final notasCtrl = TextEditingController();
    String? imagenPath;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Nueva entrada', style: GoogleFonts.poppins()),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notasCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notas (alergias, zona, cuidados…)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final path = await ImageHelper.pickAndSaveImage();
                    if (path != null) {
                      imagenPath = path;
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                              content: Text('Imagen adjunta correctamente')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate_rounded),
                  label: const Text('Adjuntar foto (opcional)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (tituloCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await DatabaseHelper.instance.insertHistorialCliente({
      'id_cliente': widget.idCliente,
      'titulo': tituloCtrl.text.trim(),
      'notas': notasCtrl.text.trim(),
      'imagen': imagenPath ?? '',
      'fecha': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    });

    tituloCtrl.dispose();
    notasCtrl.dispose();
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrada guardada')),
      );
    }
  }

  Future<void> _eliminar(int idHistorial, String? imagen) async {
    final c = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Eliminar entrada?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (c != true) return;
    await ImageHelper.deleteImage(imagen);
    await DatabaseHelper.instance.deleteHistorialCliente(idHistorial);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 560,
        constraints: const BoxConstraints(maxHeight: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.clientesAccent,
                    AppColors.clientesAccent.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_information_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.nombreCompleto,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ElevatedButton.icon(
                onPressed: _agregarEntrada,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar nota o foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.clientesAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? Center(
                          child: Text(
                            'Sin entradas todavía.\nDocumenta sesiones, alergias o referencias visuales.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          itemBuilder: (context, i) {
                            final row = _items[i];
                            final img = row['imagen'] as String? ?? '';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            row['titulo'] ?? '',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.red),
                                          onPressed: () => _eliminar(
                                            row['id_historial'] as int,
                                            img.isEmpty ? null : img,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      row['fecha']?.toString() ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if ((row['notas'] ?? '')
                                        .toString()
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        row['notas'].toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 13),
                                      ),
                                    ],
                                    if (img.isNotEmpty &&
                                        File(img).existsSync()) ...[
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(img),
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
