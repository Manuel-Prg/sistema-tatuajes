// test_database.dart
// Ejecuta este archivo para verificar y poblar la base de datos con datos de prueba

import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('═══════════════════════════════════════════════════');
  print('🔧 VERIFICACIÓN DE BASE DE DATOS');
  print('═══════════════════════════════════════════════════\n');

  try {
    // Inicializar base de datos
    print('📊 Inicializando base de datos...');
    final db = await DatabaseHelper.instance.database;
    print('✅ Base de datos creada exitosamente\n');

    // Verificar que las tablas existen
    print('🔍 Verificando tablas...');
    final tables =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

    print('📋 Tablas encontradas:');
    for (var table in tables) {
      print('   ✓ ${table['name']}');
    }
    print('');

    // Poblar con datos de prueba
    print('💾 Insertando datos de prueba...\n');

    // Insertar clientes de prueba
    print('👥 Agregando clientes...');
    await DatabaseHelper.instance.insertCliente({
      'nombre': 'Juan',
      'apellido': 'Pérez',
      'correo': 'juan.perez@email.com',
      'telefono': '9931234567',
    });

    await DatabaseHelper.instance.insertCliente({
      'nombre': 'María',
      'apellido': 'González',
      'correo': 'maria.gonzalez@email.com',
      'telefono': '9937654321',
    });

    await DatabaseHelper.instance.insertCliente({
      'nombre': 'Carlos',
      'apellido': 'Rodríguez',
      'correo': 'carlos.rod@email.com',
      'telefono': '9931122334',
    });
    print('   ✅ 3 clientes agregados');

    // Insertar tatuadores de prueba
    print('\n🎨 Agregando tatuadores...');
    await DatabaseHelper.instance.insertTatuador({
      'nombre': 'Pedro',
      'apellido': 'Martínez',
      'especialidad': 'Realismo',
      'telefono': '9935566778',
      'disponibilidad': 'Disponible',
    });

    await DatabaseHelper.instance.insertTatuador({
      'nombre': 'Ana',
      'apellido': 'López',
      'especialidad': 'Tradicional',
      'telefono': '9938877665',
      'disponibilidad': 'Disponible',
    });

    await DatabaseHelper.instance.insertTatuador({
      'nombre': 'Luis',
      'apellido': 'Hernández',
      'especialidad': 'Geométrico',
      'telefono': '9932233445',
      'disponibilidad': 'En Cita',
    });
    print('   ✅ 3 tatuadores agregados');

    // Insertar diseños de prueba
    print('\n✏️ Agregando diseños...');
    await DatabaseHelper.instance.insertDiseno({
      'nombre': 'Rosa Realista',
      'categoria': 'Flores',
      'estilo': 'Realismo',
      'tamaño': 'Mediano',
      'precio': 1500.00,
      'descripcion': 'Rosa con sombreado realista en blanco y negro',
    });

    await DatabaseHelper.instance.insertDiseno({
      'nombre': 'Dragón Oriental',
      'categoria': 'Mitología',
      'estilo': 'Oriental',
      'tamaño': 'Grande',
      'precio': 3500.00,
      'descripcion': 'Dragón chino a todo color',
    });

    await DatabaseHelper.instance.insertDiseno({
      'nombre': 'Mandala',
      'categoria': 'Geométrico',
      'estilo': 'Geométrico',
      'tamaño': 'Pequeño',
      'precio': 800.00,
      'descripcion': 'Mandala circular con detalles finos',
    });

    await DatabaseHelper.instance.insertDiseno({
      'nombre': 'Calavera Mexicana',
      'categoria': 'Cultural',
      'estilo': 'Tradicional',
      'tamaño': 'Mediano',
      'precio': 2000.00,
      'descripcion': 'Calavera del Día de Muertos con flores',
    });
    print('   ✅ 4 diseños agregados');

    // Insertar citas de prueba
    print('\n📅 Agregando citas...');
    await DatabaseHelper.instance.insertCita({
      'fecha': '2025-11-15',
      'hora': '10:00',
      'id_cliente': 1,
      'id_tatuador': 1,
      'id_diseño': 1,
      'estado': 'Pendiente',
      'notas': 'Primera sesión - brazo izquierdo',
    });

    await DatabaseHelper.instance.insertCita({
      'fecha': '2025-11-16',
      'hora': '14:00',
      'id_cliente': 2,
      'id_tatuador': 2,
      'id_diseño': 4,
      'estado': 'Confirmada',
      'notas': 'Espalda alta',
    });

    await DatabaseHelper.instance.insertCita({
      'fecha': '2025-11-18',
      'hora': '16:00',
      'id_cliente': 3,
      'id_tatuador': 3,
      'id_diseño': 3,
      'estado': 'Pendiente',
      'notas': 'Consulta previa incluida',
    });
    print('   ✅ 3 citas agregadas');

    // Insertar pagos de prueba
    print('\n💰 Agregando pagos...');
    await DatabaseHelper.instance.insertPago({
      'monto': 1500.00,
      'id_cliente': 1,
      'id_cita': 1,
      'metodo_pago': 'Efectivo',
      'estado': 'Completado',
    });

    await DatabaseHelper.instance.insertPago({
      'monto': 2000.00,
      'id_cliente': 2,
      'id_cita': 2,
      'metodo_pago': 'Transferencia',
      'estado': 'Completado',
    });

    await DatabaseHelper.instance.insertPago({
      'monto': 800.00,
      'id_cliente': 3,
      'id_cita': 3,
      'metodo_pago': 'Tarjeta',
      'estado': 'Pendiente',
    });
    print('   ✅ 3 pagos agregados');

    // Mostrar resumen
    print('\n═══════════════════════════════════════════════════');
    print('📊 RESUMEN DE DATOS');
    print('═══════════════════════════════════════════════════');

    final stats = await DatabaseHelper.instance.getEstadisticas();
    final totalIngresos = await DatabaseHelper.instance.getTotalIngresos();

    print('👥 Clientes:    ${stats['clientes']}');
    print('🎨 Tatuadores:  ${stats['tatuadores']}');
    print('✏️  Diseños:     ${stats['diseños']}');
    print('📅 Citas:       ${stats['citas']}');
    print('💰 Ingresos:    \$${totalIngresos.toStringAsFixed(2)} MXN');

    print('\n═══════════════════════════════════════════════════');
    print('✅ BASE DE DATOS LISTA PARA USAR');
    print('═══════════════════════════════════════════════════\n');

    print('🚀 Ahora ejecuta: flutter run -d windows\n');
  } catch (e) {
    print('❌ ERROR: $e');
    print('\n⚠️  Verifica que:');
    print('   1. Las dependencias estén instaladas (flutter pub get)');
    print('   2. El archivo database_helper.dart exista');
    print('   3. Tengas permisos de escritura\n');
  }
}
