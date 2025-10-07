// ==================== DISEÑOS SCREEN ====================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database_helper.dart';

// Accent for Diseños
const Color _disenosAccent = Color(0xFFF39C12);

class DisenosScreen extends StatefulWidget {
  const DisenosScreen({super.key});

  @override
  State<DisenosScreen> createState() => _DisenosScreenState();
}

class _DisenosScreenState extends State<DisenosScreen> {
  List<Map<String, dynamic>> disenos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDisenos();
  }

  Future<void> _loadDisenos() async {
    setState(() => isLoading = true);
    try {
      final rows = await DatabaseHelper.instance.getDisenos();
      setState(() {
        disenos = rows;
        isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading diseños: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar diseños')),
        );
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _showEditDialog([Map<String, dynamic>? row]) async {
    final nameController = TextEditingController(text: row?['nombre'] ?? '');
    final categoriaController =
        TextEditingController(text: row?['categoria'] ?? '');
    final estiloController = TextEditingController(text: row?['estilo'] ?? '');
    final tamanoController = TextEditingController(text: row?['tamaño'] ?? '');
    final precioController = TextEditingController(
        text: row != null ? row['precio'].toString() : '');
    final descripcionController =
        TextEditingController(text: row?['descripcion'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(row == null ? 'Nuevo Diseño' : 'Editar Diseño'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(
                  controller: categoriaController,
                  decoration: const InputDecoration(labelText: 'Categoria')),
              TextField(
                  controller: estiloController,
                  decoration: const InputDecoration(labelText: 'Estilo')),
              TextField(
                  controller: tamanoController,
                  decoration: const InputDecoration(labelText: 'Tamaño')),
              TextField(
                  controller: precioController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
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
              final data = {
                'nombre': nameController.text,
                'categoria': categoriaController.text,
                'estilo': estiloController.text,
                'tamaño': tamanoController.text,
                'precio': double.tryParse(precioController.text) ?? 0.0,
                'descripcion': descripcionController.text,
              };
              if (row == null) {
                await DatabaseHelper.instance.insertDiseno(data);
              } else {
                await DatabaseHelper.instance
                    .updateDiseno(row['id_diseño'] as int, data);
              }
              Navigator.of(context).pop();
              _loadDisenos();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDiseno(int id) async {
    await DatabaseHelper.instance.deleteDiseno(id);
    _loadDisenos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diseños de Tatuajes', style: GoogleFonts.poppins()),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDisenos),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showEditDialog(),
              color: _disenosAccent),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: disenos.isEmpty
                  ? Center(
                      child:
                          Text('No hay diseños', style: GoogleFonts.poppins()))
                  : ListView.separated(
                      itemCount: disenos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = disenos[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.image),
                            title: Text(item['nombre'] ?? '',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(item['categoria'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEditDialog(item)),
                                IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteDiseno(
                                        item['id_diseño'] as int)),
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
