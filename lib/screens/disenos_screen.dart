import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database_helper.dart';
import '../widgets/common_widgets.dart';
import '../theme/app_colors.dart';
import '../image_helper.dart';

class DisenosScreen extends StatefulWidget {
  const DisenosScreen({super.key});

  @override
  State<DisenosScreen> createState() => _DisenosScreenState();
}

class _DisenosScreenState extends State<DisenosScreen> {
  List<Map<String, dynamic>> disenos = [];
  List<Map<String, dynamic>> disenosFiltrados = [];
  bool isLoading = true;
  String searchQuery = '';

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _estiloController = TextEditingController();
  final _tamanoController = TextEditingController();
  final _precioController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDisenos();
  }

  String? _imagenPath;

  Future<void> _loadDisenos() async {
    setState(() => isLoading = true);
    try {
      final data = await DatabaseHelper.instance.getDisenos();
      setState(() {
        disenos = data;
        disenosFiltrados = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filterDisenos(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        disenosFiltrados = disenos;
      } else {
        disenosFiltrados = disenos.where((diseno) {
          final nombre = (diseno['nombre'] ?? '').toLowerCase();
          final categoria = (diseno['categoria'] ?? '').toLowerCase();
          final estilo = (diseno['estilo'] ?? '').toLowerCase();
          final searchLower = query.toLowerCase();

          return nombre.contains(searchLower) ||
              categoria.contains(searchLower) ||
              estilo.contains(searchLower);
        }).toList();
      }
    });
  }

  void _clearForm() {
    _nombreController.clear();
    _categoriaController.clear();
    _estiloController.clear();
    _tamanoController.clear();
    _precioController.clear();
    _descripcionController.clear();
    _imagenPath = null;
  }

  Future<void> _agregarDiseno() async {
    if (_formKey.currentState!.validate()) {
      final diseno = {
        'nombre': _nombreController.text,
        'categoria': _categoriaController.text,
        'estilo': _estiloController.text,
        'tamaño': _tamanoController.text,
        'precio': double.tryParse(_precioController.text) ?? 0.0,
        'descripcion': _descripcionController.text,
        'imagen': _imagenPath ?? '',
      };

      await DatabaseHelper.instance.insertDiseno(diseno);
      _clearForm();
      _loadDisenos();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Diseño agregado exitosamente',
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

  Future<void> _eliminarDiseno(int id, String nombre) async {
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
          '¿Está seguro de eliminar el diseño "$nombre"?',
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
      await DatabaseHelper.instance.deleteDiseno(id);
      _loadDisenos();
    }
  }

  void _mostrarFormulario([Map<String, dynamic>? diseno]) {
    if (diseno != null) {
      _nombreController.text = diseno['nombre'] ?? '';
      _categoriaController.text = diseno['categoria'] ?? '';
      _estiloController.text = diseno['estilo'] ?? '';
      _tamanoController.text = diseno['tamaño'] ?? '';
      _precioController.text = diseno['precio']?.toString() ?? '';
      _descripcionController.text = diseno['descripcion'] ?? '';
      _imagenPath = diseno['imagen'];
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 550,
            constraints: const BoxConstraints(maxHeight: 750),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.disenosAccent,
                        AppColors.disenosAccent.withOpacity(0.8),
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
                          Icons.palette_rounded,
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
                              diseno == null ? 'Nuevo Diseño' : 'Editar Diseño',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Complete la información del diseño',
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Preview
                              GestureDetector(
                                onTap: () async {
                                  final path = await ImageHelper.pickAndSaveImage();
                                  if (path != null) {
                                    setStateDialog(() => _imagenPath = path);
                                  }
                                },
                                child: Container(
                                  height: 160,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.disenosAccent.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: _imagenPath != null && _imagenPath!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(13),
                                          child: Image.file(
                                            File(_imagenPath!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_photo_alternate_rounded,
                                                size: 48,
                                                color: AppColors.disenosAccent.withOpacity(0.5)),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Toca para agregar imagen',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              if (_imagenPath != null && _imagenPath!.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () => setStateDialog(() => _imagenPath = null),
                                  icon: const Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                                  label: Text('Quitar imagen',
                                      style: GoogleFonts.poppins(color: Colors.red, fontSize: 12)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            controller: _nombreController,
                          label: 'Nombre del Diseño',
                          icon: Icons.title_rounded,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _categoriaController,
                          label: 'Categoría',
                          icon: Icons.category_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _estiloController,
                          label: 'Estilo',
                          icon: Icons.style_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _tamanoController,
                          label: 'Tamaño',
                          icon: Icons.straighten_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _precioController,
                          label: 'Precio (MXN)',
                          icon: Icons.attach_money_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Campo requerido';
                            }
                            if (double.tryParse(value!) == null) {
                              return 'Precio inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _descripcionController,
                          label: 'Descripción',
                          icon: Icons.description_rounded,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _agregarDiseno,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.disenosAccent,
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
    ));
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14),
        prefixIcon: Icon(icon, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.disenosAccent, width: 2),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF22263A) : Colors.grey.shade50,
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
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.disenosAccent.withOpacity(0.2),
                            AppColors.disenosAccent.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.palette_rounded,
                        color: AppColors.disenosAccent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catálogo de Diseños',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${disenosFiltrados.length} diseño${disenosFiltrados.length != 1 ? 's' : ''} disponible${disenosFiltrados.length != 1 ? 's' : ''}',
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
                      label: 'Nuevo Diseño',
                      backgroundColor: AppColors.disenosAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SearchField(
                  hintText: 'Buscar por nombre, categoría o estilo...',
                  onChanged: _filterDisenos,
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : disenosFiltrados.isEmpty
                    ? EmptyState(
                        icon: Icons.palette_rounded,
                        title: searchQuery.isEmpty
                            ? 'No hay diseños registrados'
                            : 'No se encontraron resultados',
                        subtitle: searchQuery.isEmpty
                            ? 'Comienza agregando tu primer diseño'
                            : 'Intenta con otra búsqueda',
                        onActionPressed: searchQuery.isEmpty
                            ? () => _mostrarFormulario()
                            : null,
                        actionLabel: 'Agregar Diseño',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(28),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: disenosFiltrados.length,
                        itemBuilder: (context, index) {
                          final diseno = disenosFiltrados[index];
                          return FadeSlideIn(
                            delay: Duration(milliseconds: 50 * index),
                            child: _buildDisenoCard(diseno),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.disenosAccent.withOpacity(0.15),
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 60,
          color: AppColors.disenosAccent.withOpacity(0.4),
        ),
      ),
    );
  }
  
  Widget _buildDisenoCard(Map<String, dynamic> diseno) {
    return PrimaryCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: diseno['imagen'] != null && (diseno['imagen'] as String).isNotEmpty
                  ? Image.file(
                      File(diseno['imagen'] as String),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diseno['nombre'] ?? 'Sin nombre',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (diseno['categoria'] != null) ...[
                  Row(
                    children: [
                      Icon(Icons.category_rounded,
                          size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          diseno['categoria'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (diseno['estilo'] != null) ...[
                  Row(
                    children: [
                      Icon(Icons.style_rounded,
                          size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          diseno['estilo'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.disenosAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${diseno['precio']?.toStringAsFixed(0) ?? '0'}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.disenosAccent,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          color: AppColors.disenosAccent,
                          onPressed: () => _mostrarFormulario(diseno),
                          tooltip: 'Editar',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, size: 20),
                          color: Colors.red,
                          onPressed: () => _eliminarDiseno(
                            diseno['id_diseño'],
                            diseno['nombre'] ?? 'este diseño',
                          ),
                          tooltip: 'Eliminar',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    _estiloController.dispose();
    _tamanoController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}
