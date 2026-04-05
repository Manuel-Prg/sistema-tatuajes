import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/common_widgets.dart';
import '../data/database_helper.dart';
import '../theme/app_colors.dart';
import 'cliente_historial_dialog.dart';

enum _ClienteOrden { nombreAZ, registroReciente, registroAntiguo }

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> clientesFiltrados = [];
  bool isLoading = true;
  String searchQuery = '';
  _ClienteOrden _orden = _ClienteOrden.nombreAZ;
  int? _editandoIdCliente;

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getClientes();
    setState(() {
      clientes = data;
      isLoading = false;
    });
    _aplicarOrdenYFiltro();
  }

  void _aplicarOrdenYFiltro() {
    final sorted = List<Map<String, dynamic>>.from(clientes);
    switch (_orden) {
      case _ClienteOrden.nombreAZ:
        sorted.sort((a, b) {
          final na = '${a['nombre']} ${a['apellido']}'.toLowerCase();
          final nb = '${b['nombre']} ${b['apellido']}'.toLowerCase();
          return na.compareTo(nb);
        });
        break;
      case _ClienteOrden.registroReciente:
        sorted.sort((a, b) {
          final fa = (a['fecha_registro'] ?? '').toString();
          final fb = (b['fecha_registro'] ?? '').toString();
          return fb.compareTo(fa);
        });
        break;
      case _ClienteOrden.registroAntiguo:
        sorted.sort((a, b) {
          final fa = (a['fecha_registro'] ?? '').toString();
          final fb = (b['fecha_registro'] ?? '').toString();
          return fa.compareTo(fb);
        });
        break;
    }

    setState(() {
      if (searchQuery.isEmpty) {
        clientesFiltrados = sorted;
      } else {
        final q = searchQuery.toLowerCase();
        clientesFiltrados = sorted.where((cliente) {
          final nombreCompleto =
              '${cliente['nombre']} ${cliente['apellido']}'.toLowerCase();
          final correo = (cliente['correo'] ?? '').toLowerCase();
          final telefono = cliente['telefono'].toString().toLowerCase();
          return nombreCompleto.contains(q) ||
              correo.contains(q) ||
              telefono.contains(q);
        }).toList();
      }
    });
  }

  void _filterClientes(String query) {
    searchQuery = query;
    _aplicarOrdenYFiltro();
  }

  void _clearForm() {
    _editandoIdCliente = null;
    _nombreController.clear();
    _apellidoController.clear();
    _correoController.clear();
    _telefonoController.clear();
  }

  Future<void> _guardarCliente() async {
    if (_formKey.currentState!.validate()) {
      final eraEdicion = _editandoIdCliente != null;
      final cliente = {
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'correo': _correoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
      };

      if (_editandoIdCliente != null) {
        await DatabaseHelper.instance.updateCliente(_editandoIdCliente!, cliente);
      } else {
        await DatabaseHelper.instance.insertCliente(cliente);
      }
      _clearForm();
      _loadClientes();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                    eraEdicion
                        ? 'Cliente actualizado'
                        : 'Cliente agregado exitosamente',
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

  Future<void> _eliminarCliente(int id, String nombre) async {
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
      await DatabaseHelper.instance.deleteCliente(id);
      _loadClientes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text('Cliente eliminado', style: GoogleFonts.poppins()),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _mostrarFormulario([Map<String, dynamic>? cliente]) {
    if (cliente != null) {
      _editandoIdCliente = cliente['id_cliente'] as int?;
      _nombreController.text = cliente['nombre'];
      _apellidoController.text = cliente['apellido'];
      _correoController.text = cliente['correo'] ?? '';
      _telefonoController.text = cliente['telefono'];
    } else {
      _editandoIdCliente = null;
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
              // Header del diálogo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.clientesAccent,
                      AppColors.clientesAccent.withOpacity(0.8),
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
                        Icons.person_add_rounded,
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
                            cliente == null
                                ? 'Nuevo Cliente'
                                : 'Editar Cliente',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Complete la información del cliente',
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

              // Formulario
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
                          controller: _correoController,
                          label: 'Correo Electrónico',
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Campo requerido';
                            }
                            if (!value!.contains('@')) return 'Correo inválido';
                            return null;
                          },
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
                      ],
                    ),
                  ),
                ),
              ),

              // Footer con botones
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _guardarCliente,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.clientesAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : Colors.grey.shade300;
    final fillColor = isDark
        ? AppColors.darkSurfaceElevated
        : Colors.grey.shade50;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14),
        prefixIcon: Icon(icon, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.clientesAccent, width: 2),
        ),
        filled: true,
        fillColor: fillColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header con gradiente
          Container(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.clientesAccent.withOpacity(0.2),
                            AppColors.clientesAccent.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.people_rounded,
                        color: AppColors.clientesAccent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestión de Clientes',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${clientesFiltrados.length} cliente${clientesFiltrados.length != 1 ? 's' : ''} registrado${clientesFiltrados.length != 1 ? 's' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FloatingActionButtonExtended(
                      onPressed: () => _mostrarFormulario(),
                      icon: Icons.add_rounded,
                      label: 'Nuevo Cliente',
                      backgroundColor: AppColors.clientesAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SearchField(
                        hintText: 'Buscar por nombre, correo o teléfono...',
                        onChanged: _filterClientes,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<_ClienteOrden>(
                        value: _orden,
                        decoration: InputDecoration(
                          labelText: 'Ordenar',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: _ClienteOrden.nombreAZ,
                            child: Text('Nombre A–Z'),
                          ),
                          DropdownMenuItem(
                            value: _ClienteOrden.registroReciente,
                            child: Text('Registro: reciente'),
                          ),
                          DropdownMenuItem(
                            value: _ClienteOrden.registroAntiguo,
                            child: Text('Registro: antiguo'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _orden = v);
                          _aplicarOrdenYFiltro();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de clientes
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : clientesFiltrados.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: searchQuery.isEmpty
                            ? 'No hay clientes registrados'
                            : 'No se encontraron resultados',
                        subtitle: searchQuery.isEmpty
                            ? 'Comienza agregando tu primer cliente'
                            : 'Intenta con otra búsqueda',
                        onActionPressed: searchQuery.isEmpty
                            ? () => _mostrarFormulario()
                            : null,
                        actionLabel: 'Agregar Cliente',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(28),
                        itemCount: clientesFiltrados.length,
                        itemBuilder: (context, index) {
                          final cliente = clientesFiltrados[index];
                          return FadeSlideIn(
                            delay: Duration(milliseconds: 40 * index),
                            child: _buildClienteCard(cliente),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildClienteCard(Map<String, dynamic> cliente) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PrimaryCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            Hero(
              tag: 'cliente_${cliente['id_cliente']}',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.clientesAccent,
                      AppColors.clientesAccent.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.clientesAccent.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    cliente['nombre'][0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cliente['nombre']} ${cliente['apellido']}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email_rounded,
                          size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          cliente['correo'] ?? 'Sin correo',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone_rounded,
                          size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 8),
                      Text(
                        cliente['telefono'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Acciones
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.medical_information_outlined),
                  color: AppColors.clientesAccent,
                  tooltip: 'Historial clínico / visual',
                  onPressed: () {
                    showClienteHistorialDialog(
                      context,
                      idCliente: cliente['id_cliente'] as int,
                      nombreCompleto:
                          '${cliente['nombre']} ${cliente['apellido']}',
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  color: AppColors.clientesAccent,
                  onPressed: () => _mostrarFormulario(cliente),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  color: Colors.red,
                  onPressed: () => _eliminarCliente(
                    cliente['id_cliente'],
                    '${cliente['nombre']} ${cliente['apellido']}',
                  ),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}
