import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database_helper.dart';
import '../widgets/common_widgets.dart';
import '../theme/app_colors.dart';

class TatuadoresScreen extends StatefulWidget {
  const TatuadoresScreen({super.key});

  @override
  State<TatuadoresScreen> createState() => _TatuadoresScreenState();
}

class _TatuadoresScreenState extends State<TatuadoresScreen> {
  List<Map<String, dynamic>> tatuadores = [];
  List<Map<String, dynamic>> tatuadoresFiltrados = [];
  bool isLoading = true;
  String searchQuery = '';

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _especialidadController = TextEditingController();
  final _telefonoController = TextEditingController();
  String _disponibilidad = 'Disponible';

  @override
  void initState() {
    super.initState();
    _loadTatuadores();
  }

  Future<void> _loadTatuadores() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getTatuadores();
    setState(() {
      tatuadores = data;
      tatuadoresFiltrados = data;
      isLoading = false;
    });
  }

  void _filterTatuadores(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        tatuadoresFiltrados = tatuadores;
      } else {
        tatuadoresFiltrados = tatuadores.where((tatuador) {
          final nombreCompleto =
              '${tatuador['nombre']} ${tatuador['apellido']}'.toLowerCase();
          final especialidad = (tatuador['especialidad'] ?? '').toLowerCase();
          final searchLower = query.toLowerCase();

          return nombreCompleto.contains(searchLower) ||
              especialidad.contains(searchLower);
        }).toList();
      }
    });
  }

  void _clearForm() {
    _nombreController.clear();
    _apellidoController.clear();
    _especialidadController.clear();
    _telefonoController.clear();
    _disponibilidad = 'Disponible';
  }

  Future<void> _agregarTatuador() async {
    if (_formKey.currentState!.validate()) {
      final tatuador = {
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'especialidad': _especialidadController.text,
        'telefono': _telefonoController.text,
        'disponibilidad': _disponibilidad,
      };

      await DatabaseHelper.instance.insertTatuador(tatuador);
      _clearForm();
      _loadTatuadores();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Tatuador agregado exitosamente',
                    style: GoogleFonts.poppins()),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _eliminarTatuador(int id, String nombre) async {
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
          '¿Está seguro de eliminar a $nombre?',
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
      await DatabaseHelper.instance.deleteTatuador(id);
      _loadTatuadores();
    }
  }

  void _mostrarFormulario([Map<String, dynamic>? tatuador]) {
    if (tatuador != null) {
      _nombreController.text = tatuador['nombre'];
      _apellidoController.text = tatuador['apellido'];
      _especialidadController.text = tatuador['especialidad'] ?? '';
      _telefonoController.text = tatuador['telefono'];
      _disponibilidad = tatuador['disponibilidad'];
    }

    showDialog(
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
                      AppColors.tatuadoresAccent,
                      AppColors.tatuadoresAccent.withOpacity(0.8),
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
                        Icons.brush_rounded,
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
                            tatuador == null
                                ? 'Nuevo Tatuador'
                                : 'Editar Tatuador',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Complete la información del tatuador',
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
                      onPressed: () {
                        _clearForm();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildFormField(
                          controller: _nombreController,
                          label: 'Nombre',
                          icon: Icons.person_rounded,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _apellidoController,
                          label: 'Apellido',
                          icon: Icons.person_outline_rounded,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _especialidadController,
                          label: 'Especialidad',
                          icon: Icons.star_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _telefonoController,
                          label: 'Teléfono',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _disponibilidad,
                          decoration: InputDecoration(
                            labelText: 'Disponibilidad',
                            prefixIcon:
                                const Icon(Icons.schedule_rounded, size: 22),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: ['Disponible', 'No Disponible', 'En Cita']
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _disponibilidad = value!),
                        ),
                      ],
                    ),
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
                      onPressed: () {
                        _clearForm();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _agregarTatuador,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tatuadoresAccent,
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

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14),
        prefixIcon: Icon(icon, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.tatuadoresAccent, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                            AppColors.tatuadoresAccent.withOpacity(0.2),
                            AppColors.tatuadoresAccent.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.brush_rounded,
                        color: AppColors.tatuadoresAccent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestión de Tatuadores',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${tatuadoresFiltrados.length} tatuador${tatuadoresFiltrados.length != 1 ? 'es' : ''} activo${tatuadoresFiltrados.length != 1 ? 's' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FloatingActionButtonExtended(
                      onPressed: () => _mostrarFormulario(),
                      icon: Icons.add_rounded,
                      label: 'Nuevo Tatuador',
                      backgroundColor: AppColors.tatuadoresAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SearchField(
                  hintText: 'Buscar por nombre o especialidad...',
                  onChanged: _filterTatuadores,
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : tatuadoresFiltrados.isEmpty
                    ? EmptyState(
                        icon: Icons.brush_rounded,
                        title: searchQuery.isEmpty
                            ? 'No hay tatuadores registrados'
                            : 'No se encontraron resultados',
                        subtitle: searchQuery.isEmpty
                            ? 'Comienza agregando tu primer tatuador'
                            : 'Intenta con otra búsqueda',
                        onActionPressed: searchQuery.isEmpty
                            ? () => _mostrarFormulario()
                            : null,
                        actionLabel: 'Agregar Tatuador',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(32),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: tatuadoresFiltrados.length,
                        itemBuilder: (context, index) {
                          final tatuador = tatuadoresFiltrados[index];
                          return _buildTatuadorCard(tatuador);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTatuadorCard(Map<String, dynamic> tatuador) {
    return PrimaryCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.tatuadoresAccent,
                  AppColors.tatuadoresAccent.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.tatuadoresAccent.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                tatuador['nombre'][0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${tatuador['nombre']} ${tatuador['apellido']}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tatuadoresAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tatuador['especialidad'] ?? 'Sin especialidad',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.tatuadoresAccent,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tatuador['disponibilidad'] == 'Disponible'
                  ? Colors.green.withOpacity(0.15)
                  : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tatuador['disponibilidad'] == 'Disponible'
                      ? Icons.check_circle_rounded
                      : Icons.block_rounded,
                  size: 14,
                  color: tatuador['disponibilidad'] == 'Disponible'
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  tatuador['disponibilidad'],
                  style: TextStyle(
                    fontSize: 12,
                    color: tatuador['disponibilidad'] == 'Disponible'
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                color: AppColors.tatuadoresAccent,
                onPressed: () => _mostrarFormulario(tatuador),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded),
                color: Colors.red,
                onPressed: () => _eliminarTatuador(
                  tatuador['id_tatuador'],
                  '${tatuador['nombre']} ${tatuador['apellido']}',
                ),
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _especialidadController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}
