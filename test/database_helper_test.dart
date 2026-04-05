import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sistema_tatuajes/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper.resetInstanceForTest();
    DatabaseHelper.testDbFileName =
        'test_${DateTime.now().microsecondsSinceEpoch}.db';
  });

  tearDown(() async {
    await DatabaseHelper.resetInstanceForTest();
  });

  test('insertar y listar clientes', () async {
    final id = await DatabaseHelper.instance.insertCliente({
      'nombre': 'Ana',
      'apellido': 'López',
      'correo': 'ana@ejemplo.com',
      'telefono': '5550000',
    });
    expect(id, greaterThan(0));
    final lista = await DatabaseHelper.instance.getClientes();
    expect(lista, hasLength(1));
    expect(lista.first['nombre'], 'Ana');
  });

  test('cita y pago enlazados', () async {
    final idCliente = await DatabaseHelper.instance.insertCliente({
      'nombre': 'Beto',
      'apellido': 'Ruiz',
      'correo': 'b@r.com',
      'telefono': '1',
    });
    final idTatuador = await DatabaseHelper.instance.insertTatuador({
      'nombre': 'T',
      'apellido': 'Ink',
      'especialidad': 'Blackwork',
      'telefono': '2',
      'disponibilidad': 'Disponible',
    });
    final idDiseno = await DatabaseHelper.instance.insertDiseno({
      'nombre': 'Rosa',
      'categoria': 'Floral',
      'estilo': 'Fine line',
      'tamano': 'M',
      'precio': 100.0,
      'descripcion': '',
    });
    final idCita = await DatabaseHelper.instance.insertCita({
      'fecha': '2030-01-15',
      'hora': '10:00',
      'id_cliente': idCliente,
      'id_tatuador': idTatuador,
      'id_diseno': idDiseno,
      'estado': 'Confirmada',
      'notas': '',
    });
    await DatabaseHelper.instance.insertPago({
      'monto': 50.0,
      'fecha': '2030-01-15 10:00:00',
      'id_cliente': idCliente,
      'id_cita': idCita,
      'metodo_pago': 'Efectivo',
      'estado': 'Completado',
    });
    final total = await DatabaseHelper.instance.getTotalIngresos();
    expect(total, 50.0);
  });

  test('historial de cliente y depósito', () async {
    final idCliente = await DatabaseHelper.instance.insertCliente({
      'nombre': 'C',
      'apellido': 'D',
      'correo': 'c@d.com',
      'telefono': '9',
    });
    await DatabaseHelper.instance.insertHistorialCliente({
      'id_cliente': idCliente,
      'titulo': 'Alergia a látex',
      'notas': 'Confirmado',
      'imagen': '',
      'fecha': '2026-01-01 12:00:00',
    });
    final h = await DatabaseHelper.instance.getHistorialCliente(idCliente);
    expect(h, hasLength(1));

    await DatabaseHelper.instance.insertDeposito({
      'id_cliente': idCliente,
      'monto': 200.0,
      'fecha': '2026-01-02 12:00:00',
      'metodo_pago': 'Transferencia',
      'estado': 'Recibido',
      'notas': 'Anticipo sesión',
    });
    final d = await DatabaseHelper.instance.getDepositos();
    expect(d, hasLength(1));
    final sum = await DatabaseHelper.instance.getTotalDepositosRecibidos();
    expect(sum, 200.0);
  });
}
