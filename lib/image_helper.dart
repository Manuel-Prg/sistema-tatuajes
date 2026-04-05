import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  static Future<String> _imagesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'SistemaTatuajes', 'images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// Selecciona y copia una imagen; devuelve la ruta guardada.
  static Future<String?> pickAndSaveImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final sourceFile = File(result.files.single.path!);
      final ext = p.extension(sourceFile.path);
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}$ext';
      final destDir = await _imagesDir();
      final destPath = p.join(destDir, fileName);

      await sourceFile.copy(destPath);
      return destPath;
    } catch (e) {
      developer.log('Error al seleccionar imagen: $e');
      return null;
    }
  }

  static Future<void> deleteImage(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      developer.log('Error al eliminar imagen: $e');
    }
  }
}
