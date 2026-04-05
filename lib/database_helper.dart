import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  /// Solo para tests: usar otro nombre de archivo y reiniciar conexión.
  static String? testDbFileName;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(testDbFileName ?? 'tatuajes.db');
    return _database!;
  }

  static Future<void> resetInstanceForTest() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    testDbFileName = null;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      print('--- INICIALIZANDO BD ---');
      print('Ruta: $path');

      return await openDatabase(
        path,
        version: 3,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('❌ ERROR CRITICO AL INICIALIZAR BD: $e');
      rethrow;
    }
  }
  //actualizar base de datos
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute("ALTER TABLE tatuadores ADD COLUMN foto TEXT DEFAULT ''");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE disenos ADD COLUMN imagen TEXT DEFAULT ''");
      } catch (_) {}
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS historial_cliente (
          id_historial INTEGER PRIMARY KEY AUTOINCREMENT,
          id_cliente INTEGER NOT NULL,
          fecha TEXT DEFAULT CURRENT_TIMESTAMP,
          titulo TEXT NOT NULL,
          notas TEXT,
          imagen TEXT DEFAULT '',
          FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS depositos (
          id_deposito INTEGER PRIMARY KEY AUTOINCREMENT,
          id_cliente INTEGER NOT NULL,
          id_cita INTEGER,
          monto REAL NOT NULL,
          fecha TEXT DEFAULT CURRENT_TIMESTAMP,
          metodo_pago TEXT,
          estado TEXT DEFAULT 'Recibido',
          notas TEXT,
          FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
          FOREIGN KEY (id_cita) REFERENCES citas(id_cita)
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const textTypeNullable = 'TEXT';

    //tabla clientes
    await db.execute('''
      CREATE TABLE clientes (
        id_cliente $idType,
        nombre $textType,
        apellido $textType,
        correo $textTypeNullable,
        telefono $textType,
        fecha_registro TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    //tabla tatuadores
    await db.execute('''
      CREATE TABLE tatuadores (
        id_tatuador $idType,
        nombre $textType,
        apellido $textType,
        especialidad $textTypeNullable,
        telefono $textType,
        disponibilidad TEXT DEFAULT 'Disponible',
        foto TEXT DEFAULT ''
      )
    ''');
    //tabla diseños
    await db.execute('''
      CREATE TABLE disenos (
        id_diseno $idType,
        nombre $textType,
        categoria $textTypeNullable,
        estilo $textTypeNullable,
        tamano $textTypeNullable,
        precio $realType,
        descripcion $textTypeNullable,
        imagen TEXT DEFAULT ''
      )
    ''');
    //tabla citas
    await db.execute('''
      CREATE TABLE citas (
        id_cita $idType,
        fecha $textType,
        hora $textType,
        id_cliente INTEGER NOT NULL,
        id_tatuador INTEGER NOT NULL,
        id_diseno INTEGER,
        estado TEXT DEFAULT 'Pendiente',
        notas $textTypeNullable,
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
        FOREIGN KEY (id_tatuador) REFERENCES tatuadores(id_tatuador),
        FOREIGN KEY (id_diseno) REFERENCES disenos(id_diseno)
      )
    ''');
    //tabla pagos
    await db.execute('''
      CREATE TABLE pagos (
        id_pago $idType,
        monto $realType,
        fecha TEXT DEFAULT CURRENT_TIMESTAMP,
        id_cliente INTEGER NOT NULL,
        id_cita INTEGER NOT NULL,
        metodo_pago $textTypeNullable,
        estado TEXT DEFAULT 'Pendiente',
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
        FOREIGN KEY (id_cita) REFERENCES citas(id_cita)
      )
    ''');

    await db.execute('''
      CREATE TABLE historial_cliente (
        id_historial $idType,
        id_cliente INTEGER NOT NULL,
        fecha TEXT DEFAULT CURRENT_TIMESTAMP,
        titulo $textType,
        notas $textTypeNullable,
        imagen TEXT DEFAULT '',
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
      )
    ''');

    await db.execute('''
      CREATE TABLE depositos (
        id_deposito $idType,
        id_cliente INTEGER NOT NULL,
        id_cita INTEGER,
        monto $realType,
        fecha TEXT DEFAULT CURRENT_TIMESTAMP,
        metodo_pago $textTypeNullable,
        estado TEXT DEFAULT 'Recibido',
        notas $textTypeNullable,
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
        FOREIGN KEY (id_cita) REFERENCES citas(id_cita)
      )
    ''');
  }

  // ==================== RESPALDO Y RESTAURACIÓN ====================

  /// Exportar base de datos a un archivo
  Future<String?> exportarBaseDatos() async {
    try {
      // Obtener la ruta de la base de datos actual
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'tatuajes.db'));

      if (!await dbFile.exists()) {
        throw Exception('La base de datos no existe');
      }

      // Solicitar ubicación para guardar
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar respaldo de base de datos',
        fileName: 'tatuajes_backup_${DateTime.now().millisecondsSinceEpoch}.db',
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (outputPath == null) {
        return null; // Usuario canceló
      }

      // Asegurar extensión .db
      if (!outputPath.endsWith('.db')) {
        outputPath += '.db';
      }

      // Copiar archivo
      await dbFile.copy(outputPath);

      print('✓ Base de datos exportada a: $outputPath');
      return outputPath;
    } catch (e) {
      print('Error al exportar base de datos: $e');
      rethrow;
    }
  }

  /// Importar base de datos desde un archivo
  Future<bool> importarBaseDatos() async {
    try {
      // Seleccionar archivo a importar
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Seleccionar archivo de respaldo',
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null || result.files.single.path == null) {
        return false; // Usuario canceló
      }

      final importFile = File(result.files.single.path!);

      if (!await importFile.exists()) {
        throw Exception('El archivo seleccionado no existe');
      }

      // Cerrar base de datos actual
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Obtener ruta de la base de datos actual
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'tatuajes.db'));

      // Crear respaldo de la BD actual antes de reemplazarla
      if (await dbFile.exists()) {
        final backupPath = join(dbPath,
            'tatuajes_backup_${DateTime.now().millisecondsSinceEpoch}.db');
        await dbFile.copy(backupPath);
        print('✓ Respaldo automático creado en: $backupPath');
      }

      // Reemplazar con la nueva base de datos
      await importFile.copy(dbFile.path);

      // Reinicializar la base de datos
      _database = await _initDB('tatuajes.db');

      print('✓ Base de datos importada exitosamente');
      return true;
    } catch (e) {
      print('Error al importar base de datos: $e');
      // Intentar reabrir la base de datos original
      _database = null;
      await database;
      rethrow;
    }
  }

  /// Crear respaldo automático en carpeta de documentos
  Future<String> crearRespaldoAutomatico() async {
    try {
      // Obtener directorio de documentos
      final directory = await getApplicationDocumentsPath();
      final backupDir = Directory(join(directory, 'TatuajesBackup'));

      // Crear directorio si no existe
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Obtener archivo de base de datos
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'tatuajes.db'));

      if (!await dbFile.exists()) {
        throw Exception('La base de datos no existe');
      }

      // Crear nombre con fecha
      final timestamp = DateTime.now();
      final fileName =
          'tatuajes_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour}${timestamp.minute}.db';

      final backupPath = join(backupDir.path, fileName);

      // Copiar archivo
      await dbFile.copy(backupPath);

      print('✓ Respaldo automático creado: $backupPath');
      return backupPath;
    } catch (e) {
      print('Error al crear respaldo automático: $e');
      rethrow;
    }
  }

  /// Obtener directorio de documentos (compatible con todas las plataformas)
  Future<String> getApplicationDocumentsPath() async {
    if (Platform.isWindows) {
      final String home = Platform.environment['USERPROFILE'] ?? '';
      return join(home, 'Documents', 'SistemaTatuajes');
    } else if (Platform.isLinux) {
      return Platform.environment['HOME'] ?? '';
    } else if (Platform.isMacOS) {
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return (await getApplicationDocumentsDirectory()).path;
    }
  }

  /// Limpiar respaldos antiguos (mantener solo los últimos N)
  Future<void> limpiarRespaldosAntiguos({int mantener = 5}) async {
    try {
      final directory = await getApplicationDocumentsPath();
      final backupDir = Directory(join(directory, 'TatuajesBackup'));

      if (!await backupDir.exists()) return;

      // Obtener todos los archivos .db
      final files = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.db'))
          .cast<File>()
          .toList();

      // Ordenar por fecha de modificación (más reciente primero)
      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Eliminar los más antiguos
      if (files.length > mantener) {
        for (int i = mantener; i < files.length; i++) {
          await files[i].delete();
          print('✓ Respaldo antiguo eliminado: ${files[i].path}');
        }
      }
    } catch (e) {
      print('Error al limpiar respaldos antiguos: $e');
    }
  }

  // ==================== CLIENTES ====================

  Future<int> insertCliente(Map<String, dynamic> cliente) async {
    final db = await instance.database;
    return await db.insert('clientes', cliente);
  }

  Future<List<Map<String, dynamic>>> getClientes() async {
    final db = await instance.database;
    return await db.query('clientes', orderBy: 'id_cliente DESC');
  }

  Future<int> updateCliente(int id, Map<String, dynamic> cliente) async {
    final db = await instance.database;
    return await db.update(
      'clientes',
      cliente,
      where: 'id_cliente = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCliente(int id) async {
    final db = await instance.database;
    return await db.delete(
      'clientes',
      where: 'id_cliente = ?',
      whereArgs: [id],
    );
  }

  // ==================== TATUADORES ====================

  Future<int> insertTatuador(Map<String, dynamic> tatuador) async {
    final db = await instance.database;
    return await db.insert('tatuadores', tatuador);
  }

  Future<List<Map<String, dynamic>>> getTatuadores() async {
    final db = await instance.database;
    return await db.query('tatuadores', orderBy: 'id_tatuador DESC');
  }

  Future<int> updateTatuador(int id, Map<String, dynamic> tatuador) async {
    final db = await instance.database;
    return await db.update(
      'tatuadores',
      tatuador,
      where: 'id_tatuador = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTatuador(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tatuadores',
      where: 'id_tatuador = ?',
      whereArgs: [id],
    );
  }

  // ==================== DISEÑOS ====================

  Future<int> insertDiseno(Map<String, dynamic> diseno) async {
    final db = await instance.database;
    return await db.insert('disenos', diseno);
  }

  Future<List<Map<String, dynamic>>> getDisenos() async {
    final db = await instance.database;
    return await db.query('disenos', orderBy: 'id_diseno DESC');
  }

  Future<int> updateDiseno(int id, Map<String, dynamic> diseno) async {
    final db = await instance.database;
    return await db.update(
      'disenos',
      diseno,
      where: 'id_diseno = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDiseno(int id) async {
    final db = await instance.database;
    return await db.delete(
      'disenos',
      where: 'id_diseno = ?',
      whereArgs: [id],
    );
  }

  // ==================== CITAS ====================

  Future<int> insertCita(Map<String, dynamic> cita) async {
    final db = await instance.database;
    return await db.insert('citas', cita);
  }

  Future<List<Map<String, dynamic>>> getCitas() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT c.id_cita, c.fecha, c.hora, 
             cl.nombre || ' ' || cl.apellido as cliente,
             t.nombre || ' ' || t.apellido as tatuador,
             d.nombre as diseño,
             c.estado, c.notas,
             c.id_cliente, c.id_tatuador, c.id_diseno
      FROM citas c
      LEFT JOIN clientes cl ON c.id_cliente = cl.id_cliente
      LEFT JOIN tatuadores t ON c.id_tatuador = t.id_tatuador
      LEFT JOIN disenos d ON c.id_diseno = d.id_diseno
      ORDER BY c.fecha DESC, c.hora DESC
    ''');
  }

  Future<int> updateCita(int id, Map<String, dynamic> cita) async {
    final db = await instance.database;
    return await db.update(
      'citas',
      cita,
      where: 'id_cita = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCita(int id) async {
    final db = await instance.database;
    return await db.delete(
      'citas',
      where: 'id_cita = ?',
      whereArgs: [id],
    );
  }

  // ==================== PAGOS ====================

  Future<int> insertPago(Map<String, dynamic> pago) async {
    final db = await instance.database;
    return await db.insert('pagos', pago);
  }

  Future<List<Map<String, dynamic>>> getPagos() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT p.id_pago, p.monto, p.fecha, 
             cl.nombre || ' ' || cl.apellido as cliente,
             p.metodo_pago, p.estado,
             p.id_cliente, p.id_cita
      FROM pagos p
      LEFT JOIN clientes cl ON p.id_cliente = cl.id_cliente
      ORDER BY p.fecha DESC
    ''');
  }

  Future<double> getTotalIngresos() async {
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT SUM(monto) as total FROM pagos WHERE estado = 'Completado'");
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> updatePago(int id, Map<String, dynamic> pago) async {
    final db = await instance.database;
    return await db.update(
      'pagos',
      pago,
      where: 'id_pago = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePago(int id) async {
    final db = await instance.database;
    return await db.delete(
      'pagos',
      where: 'id_pago = ?',
      whereArgs: [id],
    );
  }

  // ==================== HISTORIAL CLÍNICO / VISUAL ====================

  Future<int> insertHistorialCliente(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('historial_cliente', row);
  }

  Future<List<Map<String, dynamic>>> getHistorialCliente(int idCliente) async {
    final db = await instance.database;
    return await db.query(
      'historial_cliente',
      where: 'id_cliente = ?',
      whereArgs: [idCliente],
      orderBy: 'fecha DESC, id_historial DESC',
    );
  }

  Future<int> deleteHistorialCliente(int idHistorial) async {
    final db = await instance.database;
    return await db.delete(
      'historial_cliente',
      where: 'id_historial = ?',
      whereArgs: [idHistorial],
    );
  }

  // ==================== DEPÓSITOS ====================

  Future<int> insertDeposito(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('depositos', row);
  }

  Future<List<Map<String, dynamic>>> getDepositos() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT d.id_deposito, d.id_cliente, d.id_cita, d.monto, d.fecha,
             d.metodo_pago, d.estado, d.notas,
             cl.nombre || ' ' || cl.apellido AS cliente
      FROM depositos d
      LEFT JOIN clientes cl ON d.id_cliente = cl.id_cliente
      ORDER BY d.fecha DESC, d.id_deposito DESC
    ''');
  }

  Future<int> updateDeposito(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'depositos',
      row,
      where: 'id_deposito = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDeposito(int id) async {
    final db = await instance.database;
    return await db.delete(
      'depositos',
      where: 'id_deposito = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalDepositosRecibidos() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      "SELECT SUM(monto) as total FROM depositos WHERE estado = 'Recibido'");
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Citas de un cliente (para vincular depósitos).
  Future<List<Map<String, dynamic>>> getCitasPorCliente(int idCliente) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT c.id_cita, c.fecha, c.hora, c.estado,
             t.nombre || ' ' || t.apellido AS tatuador
      FROM citas c
      LEFT JOIN tatuadores t ON c.id_tatuador = t.id_tatuador
      WHERE c.id_cliente = ?
      ORDER BY c.fecha DESC, c.hora DESC
    ''', [idCliente]);
  }

  // ==================== ESTADÍSTICAS ====================

  Future<Map<String, int>> getEstadisticas() async {
    final db = await instance.database;

    final clientes =
        await db.rawQuery('SELECT COUNT(*) as count FROM clientes');
    final tatuadores =
        await db.rawQuery('SELECT COUNT(*) as count FROM tatuadores');
    final citas = await db.rawQuery('SELECT COUNT(*) as count FROM citas');
    final disenos = await db.rawQuery('SELECT COUNT(*) as count FROM disenos');
    final depositos =
        await db.rawQuery('SELECT COUNT(*) as count FROM depositos');
    final historial =
        await db.rawQuery('SELECT COUNT(*) as count FROM historial_cliente');

    return {
      'clientes': Sqflite.firstIntValue(clientes) ?? 0,
      'tatuadores': Sqflite.firstIntValue(tatuadores) ?? 0,
      'citas': Sqflite.firstIntValue(citas) ?? 0,
      'diseños': Sqflite.firstIntValue(disenos) ?? 0,
      'depositos': Sqflite.firstIntValue(depositos) ?? 0,
      'historial': Sqflite.firstIntValue(historial) ?? 0,
    };
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
