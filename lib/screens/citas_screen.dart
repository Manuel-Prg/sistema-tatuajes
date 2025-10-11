import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> citas = [];
  List<Map<String, dynamic>> citasFiltradas = [];
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> tatuadores = [];
  List<Map<String, dynamic>> disenos = [];
  bool isLoading = true;
  String searchQuery = '';

  // Variables del calendario
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _citasPorFecha = {};
  bool _mostrarCalendario = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = _focusedDay;
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => isLoading = true);
    try {
      final c = await DatabaseHelper.instance.getCitas();
      final cl = await DatabaseHelper.instance.getClientes();
      final t = await DatabaseHelper.instance.getTatuadores();
      final d = await DatabaseHelper.instance.getDisenos();

      // Organizar citas por fecha
      Map<DateTime, List<Map<String, dynamic>>> citasMap = {};
      for (var cita in c) {
        final fechaStr = cita['fecha'] as String?;
        if (fechaStr != null) {
          final fecha = DateTime.tryParse(fechaStr);
          if (fecha != null) {
            final fechaNormalizada =
                DateTime(fecha.year, fecha.month, fecha.day);
            if (citasMap[fechaNormalizada] == null) {
              citasMap[fechaNormalizada] = [];
            }
            citasMap[fechaNormalizada]!.add(cita);
          }
        }
      }

      setState(() {
        citas = c;
        citasFiltradas = c;
        clientes = cl;
        tatuadores = t;
        disenos = d;
        _citasPorFecha = citasMap;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filterCitas(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        citasFiltradas = citas;
      } else {
        citasFiltradas = citas.where((cita) {
          final cliente = (cita['cliente'] ?? '').toLowerCase();
          final tatuador = (cita['tatuador'] ?? '').toLowerCase();
          final estado = (cita['estado'] ?? '').toLowerCase();
          final searchLower = query.toLowerCase();

          return cliente.contains(searchLower) ||
              tatuador.contains(searchLower) ||
              estado.contains(searchLower);
        }).toList();
      }
    });
  }

  List<Map<String, dynamic>> _getCitasDelDia(DateTime day) {
    final fechaNormalizada = DateTime(day.year, day.month, day.day);
    return _citasPorFecha[fechaNormalizada] ?? [];
  }

  Future<void> _showEditDialog([Map<String, dynamic>? row]) async {
    final fechaController = TextEditingController(text: row?['fecha'] ?? '');
    final horaController = TextEditingController(text: row?['hora'] ?? '');
    DateTime? selectedDate = row != null && row['fecha'] != null
        ? DateTime.tryParse(row['fecha'] as String)
        : _selectedDay ?? DateTime.now();
    TimeOfDay? selectedTime;
    if (row != null && row['hora'] != null) {
      final parts = (row['hora'] as String).split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        selectedTime = TimeOfDay(hour: h, minute: m);
      }
    }

    // Pre-llenar la fecha del día seleccionado
    if (selectedDate != null) {
      fechaController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }

    int? selectedCliente = row?['id_cliente'] as int?;
    int? selectedTatuador = row?['id_tatuador'] as int?;
    int? selectedDiseno = row?['id_diseño'] as int?;
    String estado = row?['estado'] ?? 'Pendiente';
    final notasController = TextEditingController(text: row?['notas'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 550,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.citasAccent,
                      AppColors.citasAccent.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.event_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row == null ? 'Nueva Cita' : 'Editar Cita',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Programe una cita para un cliente',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: fechaController,
                        readOnly: true,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          prefixIcon: const Icon(Icons.calendar_today_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: horaController,
                        readOnly: true,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Hora',
                          prefixIcon: const Icon(Icons.access_time_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
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
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedCliente,
                        decoration: InputDecoration(
                          labelText: 'Cliente',
                          prefixIcon: const Icon(Icons.person_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: clientes
                            .map((c) => DropdownMenuItem(
                                value: c['id_cliente'] as int,
                                child: Text('${c['nombre']} ${c['apellido']}')))
                            .toList(),
                        onChanged: (v) => selectedCliente = v,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedTatuador,
                        decoration: InputDecoration(
                          labelText: 'Tatuador',
                          prefixIcon: const Icon(Icons.brush_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: tatuadores
                            .map((t) => DropdownMenuItem(
                                value: t['id_tatuador'] as int,
                                child: Text('${t['nombre']} ${t['apellido']}')))
                            .toList(),
                        onChanged: (v) => selectedTatuador = v,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedDiseno,
                        decoration: InputDecoration(
                          labelText: 'Diseño (opcional)',
                          prefixIcon: const Icon(Icons.palette_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: disenos
                            .map((d) => DropdownMenuItem(
                                value: d['id_diseño'] as int,
                                child: Text(d['nombre'] ?? '')))
                            .toList(),
                        onChanged: (v) => selectedDiseno = v,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: estado,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          prefixIcon: const Icon(Icons.flag_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: [
                          'Pendiente',
                          'Confirmada',
                          'Completada',
                          'Cancelada'
                        ]
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => estado = v ?? estado,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: notasController,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Notas',
                          prefixIcon: const Icon(Icons.note_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (selectedCliente == null ||
                            selectedTatuador == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Selecciona cliente y tatuador')));
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
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.citasAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCita(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_rounded,
                  color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Confirmar eliminación'),
          ],
        ),
        content: Text(
          '¿Está seguro de eliminar esta cita?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteCita(id);
      _loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.citasAccent.withOpacity(0.2),
                            AppColors.citasAccent.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.event_rounded,
                        color: AppColors.citasAccent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestión de Citas',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${citasFiltradas.length} cita${citasFiltradas.length != 1 ? 's' : ''} programada${citasFiltradas.length != 1 ? 's' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Toggle de vista
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildViewToggle(Icons.calendar_month_rounded, true),
                          _buildViewToggle(Icons.list_rounded, false),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButtonExtended(
                      onPressed: () => _showEditDialog(),
                      icon: Icons.add_rounded,
                      label: 'Nueva Cita',
                      backgroundColor: AppColors.citasAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SearchField(
                  hintText: 'Buscar por cliente, tatuador o estado...',
                  onChanged: _filterCitas,
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mostrarCalendario
                    ? _buildCalendarView()
                    : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, bool isCalendar) {
    final isSelected = _mostrarCalendario == isCalendar;
    return InkWell(
      onTap: () => setState(() => _mostrarCalendario = isCalendar),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.citasAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Row(
      children: [
        // Calendario
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: PrimaryCard(
              child: Column(
                children: [
                  TableCalendar(
                    locale: 'es',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: _getCitasDelDia,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppColors.citasAccent.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.citasAccent,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: AppColors.citasAccent,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: AppColors.citasAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      formatButtonTextStyle: GoogleFonts.poppins(
                        color: AppColors.citasAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Lista de citas del día seleccionado
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(right: 24, top: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedDay != null
                      ? DateFormat('EEEE, d MMMM', 'es').format(_selectedDay!)
                      : 'Selecciona un día',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildCitasDelDiaSeleccionado(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCitasDelDiaSeleccionado() {
    if (_selectedDay == null) {
      return const Center(child: Text('Selecciona un día'));
    }

    final citasDelDia = _getCitasDelDia(_selectedDay!);

    if (citasDelDia.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_rounded,
              size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Sin citas este día',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: citasDelDia.length,
      itemBuilder: (context, index) {
        final cita = citasDelDia[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCitaCard(cita),
        );
      },
    );
  }

  Widget _buildListView() {
    if (citasFiltradas.isEmpty) {
      return EmptyState(
        icon: Icons.event_rounded,
        title: searchQuery.isEmpty
            ? 'No hay citas programadas'
            : 'No se encontraron resultados',
        subtitle: searchQuery.isEmpty
            ? 'Comienza agendando tu primera cita'
            : 'Intenta con otra búsqueda',
        onActionPressed: searchQuery.isEmpty ? () => _showEditDialog() : null,
        actionLabel: 'Agendar Cita',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: citasFiltradas.length,
      itemBuilder: (context, index) {
        final cita = citasFiltradas[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCitaCard(cita),
        );
      },
    );
  }

  Widget _buildCitaCard(Map<String, dynamic> item) {
    Color estadoColor;
    IconData estadoIcon;

    switch (item['estado']) {
      case 'Confirmada':
        estadoColor = Colors.blue;
        estadoIcon = Icons.check_circle_rounded;
        break;
      case 'Completada':
        estadoColor = Colors.green;
        estadoIcon = Icons.task_alt_rounded;
        break;
      case 'Cancelada':
        estadoColor = Colors.red;
        estadoIcon = Icons.cancel_rounded;
        break;
      default:
        estadoColor = Colors.orange;
        estadoIcon = Icons.schedule_rounded;
    }

    return PrimaryCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.citasAccent.withOpacity(0.2),
                  AppColors.citasAccent.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_rounded,
              color: AppColors.citasAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${item['hora']}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: estadoColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(estadoIcon, size: 14, color: estadoColor),
                          const SizedBox(width: 4),
                          Text(
                            item['estado'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: estadoColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_rounded,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      item['cliente'] ?? 'N/A',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                color: AppColors.citasAccent,
                onPressed: () => _showEditDialog(item),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded),
                color: Colors.red,
                onPressed: () => _deleteCita(item['id_cita'] as int),
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
