import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'dart:developer' as developer;

class ImageHelper {
  // Carpeta donde se guardarán las imágenes
  static Future<String> get _imagesDir async {
    final String home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ?? '';
    final dir = Directory('$home\\Documents\\SistemaTatuajes\\images');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  // Seleccionar y copiar imagen, retorna la ruta guardada
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
      final destDir = await _imagesDir;
      final destPath = '$destDir\\$fileName';

      await sourceFile.copy(destPath);
      return destPath;
    } catch (e) {
      developer.log('Error al seleccionar imagen: $e');
      return null;
    }
  }

  // Eliminar imagen del sistema de archivos
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