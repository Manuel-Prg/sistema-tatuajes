// ==================== CITAS SCREEN ====================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import '../theme/app_colors.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  List<Map<String, dynamic>> citas = [];
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> tatuadores = [];
  List<Map<String, dynamic>> disenos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => isLoading = true);
    try {
      final c = await DatabaseHelper.instance.getCitas();
      final cl = await DatabaseHelper.instance.getClientes();
      final t = await DatabaseHelper.instance.getTatuadores();
      final d = await DatabaseHelper.instance.getDisenos();
      setState(() {
        citas = c;
        clientes = cl;
        tatuadores = t;
        disenos = d;
        isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading citas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al cargar citas')));
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _showEditDialog([Map<String, dynamic>? row]) async {
    final fechaController = TextEditingController(text: row?['fecha'] ?? '');
    final horaController = TextEditingController(text: row?['hora'] ?? '');
    DateTime? selectedDate = row != null && row['fecha'] != null
        ? DateTime.tryParse(row['fecha'] as String)
        : null;
    TimeOfDay? selectedTime;
    if (row != null && row['hora'] != null) {
      final parts = (row['hora'] as String).split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        selectedTime = TimeOfDay(hour: h, minute: m);
      }
    }
    int? selectedCliente = row?['id_cliente'] as int?;
    int? selectedTatuador = row?['id_tatuador'] as int?;
    int? selectedDiseno = row?['id_diseño'] as int?;
    String estado = row?['estado'] ?? 'Pendiente';
    final notasController = TextEditingController(text: row?['notas'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(row == null ? 'Nueva Cita' : 'Editar Cita'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: fechaController,
                readOnly: true,
                decoration:
                    const InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                    fechaController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
              TextFormField(
                controller: horaController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Hora (HH:MM)'),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    selectedTime = picked;
                    horaController.text =
                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  }
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedCliente,
                items: clientes
                    .map((c) => DropdownMenuItem(
                        value: c['id_cliente'] as int,
                        child: Text('${c['nombre']} ${c['apellido']}')))
                    .toList(),
                onChanged: (v) => selectedCliente = v,
                decoration: const InputDecoration(labelText: 'Cliente'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedTatuador,
                items: tatuadores
                    .map((t) => DropdownMenuItem(
                        value: t['id_tatuador'] as int,
                        child: Text('${t['nombre']} ${t['apellido']}')))
                    .toList(),
                onChanged: (v) => selectedTatuador = v,
                decoration: const InputDecoration(labelText: 'Tatuador'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedDiseno,
                items: disenos
                    .map((d) => DropdownMenuItem(
                        value: d['id_diseño'] as int,
                        child: Text(d['nombre'] ?? '')))
                    .toList(),
                onChanged: (v) => selectedDiseno = v,
                decoration:
                    const InputDecoration(labelText: 'Diseño (opcional)'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: estado,
                items: ['Pendiente', 'Confirmada', 'Completada', 'Cancelada']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => estado = v ?? estado,
                decoration: const InputDecoration(labelText: 'Estado'),
              ),
              TextField(
                  controller: notasController,
                  decoration: const InputDecoration(labelText: 'Notas'),
                  maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (selectedCliente == null || selectedTatuador == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Selecciona cliente y tatuador')));
                return;
              }
              final data = {
                'fecha': fechaController.text,
                'hora': horaController.text,
                'id_cliente': selectedCliente,
                'id_tatuador': selectedTatuador,
                'id_diseño': selectedDiseno,
                'estado': estado,
                'notas': notasController.text,
              };
              if (row == null) {
                await DatabaseHelper.instance.insertCita(data);
              } else {
                await DatabaseHelper.instance
                    .updateCita(row['id_cita'] as int, data);
              }
              Navigator.of(context).pop();
              _loadAll();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCita(int id) async {
    await DatabaseHelper.instance.deleteCita(id);
    _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Citas', style: GoogleFonts.poppins()),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showEditDialog(),
              color: AppColors.citasAccent),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: citas.isEmpty
                  ? Center(
                      child: Text('No hay citas', style: GoogleFonts.poppins()))
                  : ListView.separated(
                      itemCount: citas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = citas[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text('${item['fecha']} ${item['hora']}',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${item['cliente'] ?? ''} • ${item['tatuador'] ?? ''}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEditDialog(item)),
                                IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _deleteCita(item['id_cita'] as int)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
