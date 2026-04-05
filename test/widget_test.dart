import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sistema_tatuajes/main.dart';
import 'package:sistema_tatuajes/theme/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('La app muestra la marca principal', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const SistemaTatuajesApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('InkManager'), findsWidgets);
  });
}
