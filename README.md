# sistema_tatuajes

A new Flutter project.

# Sistema de Gestión de Tatuajes 🎨

**Alumno:** Luis Eduardo  
**Materia:** Seminario de Desarrollo Tecnológico 2  
**Fecha:** Octubre 2025  
**Tecnología:** Flutter + SQLite

---

## 📋 Requisitos Previos

1. **Flutter SDK** (versión 3.0 o superior)
   - Descarga desde: https://flutter.dev/docs/get-started/install
   
2. **Editor de Código**
   - Visual Studio Code (recomendado)
   - Android Studio
   
3. **Git** (opcional)

---

## 🚀 Instalación y Configuración

### Paso 1: Crear el proyecto

```bash
flutter create sistema_tatuajes
cd sistema_tatuajes
```

### Paso 2: Estructura de carpetas

Crea la siguiente estructura dentro de la carpeta `lib`:

```
lib/
├── main.dart
├── database_helper.dart
└── screens/
    ├── home_screen.dart
    ├── clientes_screen.dart
    ├── tatuadores_screen.dart
    ├── diseños_screen.dart
    ├── citas_screen.dart
    ├── pagos_screen.dart
    └── reportes_screen.dart
```

### Paso 3: Configurar pubspec.yaml

Reemplaza el contenido de `pubspec.yaml` con el archivo proporcionado que incluye las dependencias:
- sqflite
- path_provider
- google_fonts
- intl
- provider

### Paso 4: Instalar dependencias

```bash
flutter pub get
```

### Paso 5: Copiar los archivos

1. Copia el contenido de `main.dart` al archivo principal
2. Copia `database_helper.dart` en la raíz de `lib/`
3. Copia cada screen en la carpeta `screens/`
4. (Opcional) Copia `test_database.dart` en la raíz de `lib/` para poblar datos de prueba

### Paso 6: Verificar y poblar la base de datos (OPCIONAL)

```bash
# Ejecutar script de verificación y datos de prueba
flutter run lib/test_database.dart
```

Este script:
- ✅ Crea la base de datos automáticamente
- ✅ Verifica que todas las tablas existan
- ✅ Inserta datos de prueba (3 clientes, 3 tatuadores, 4 diseños, 3 citas, 3 pagos)
- ✅ Muestra un resumen de estadísticas

**NOTA:** La base de datos se crea automáticamente al ejecutar la app por primera vez, este paso es opcional para verificar y tener datos de ejemplo.

---

## 🖥️ Ejecutar el Proyecto

### En Windows (Escritorio)

```bash
flutter run -d windows
```

### En Linux

```bash
flutter run -d linux
```

### En macOS

```bash
flutter run -d macos
```

### En modo Debug

```bash
flutter run
```

---

## 📦 Generar Instalable

### Para Windows (.exe)

```bash
flutter build windows --release
```

El ejecutable estará en: `build/windows/runner/Release/`

### Para Linux

```bash
flutter build linux --release
```

### Para macOS

```bash
flutter build macos --release
```

---

## 🎯 Funcionalidades Implementadas

✅ **Dashboard Principal**
- Estadísticas generales
- Resumen de ingresos
- Accesos rápidos

✅ **Gestión de Clientes**
- Agregar clientes con formulario validado
- Listar todos los clientes
- Eliminar clientes
- Búsqueda (en desarrollo)

✅ **Gestión de Tatuadores**
- Registrar tatuadores con especialidad
- Control de disponibilidad
- Vista en tarjetas (grid)
- Eliminar tatuadores

✅ **Gestión de Pagos**
- Listado de pagos realizados
- Total de ingresos acumulados
- Estados de pago (Completado/Pendiente)

✅ **Reportes**
- Estadísticas generales
- Información del sistema
- Opciones de exportación (próximamente)

✅ **Base de Datos SQLite**
- Persistencia de datos local
- Relaciones entre tablas
- CRUD completo para todas las entidades

---

## 🗄️ Estructura de Base de Datos

### Tablas Principales:

1. **clientes**
   - id_cliente (PK)
   - nombre, apellido
   - correo, telefono
   - fecha_registro

2. **tatuadores**
   - id_tatuador (PK)
   - nombre, apellido
   - especialidad, telefono
   - disponibilidad

3. **diseños**
   - id_diseño (PK)
   - nombre, categoria, estilo
   - tamaño, precio
   - ruta_imagen, descripcion

4. **citas**
   - id_cita (PK)
   - fecha, hora
   - id_cliente (FK), id_tatuador (FK), id_diseño (FK)
   - estado, notas

5. **pagos**
   - id_pago (PK)
   - monto, fecha
   - id_cliente (FK), id_cita (FK)
   - metodo_pago, estado

---

## 🛠️ Solución de Problemas Comunes

### Error: "flutter not found"
- Asegúrate de tener Flutter en tu PATH
- Reinicia la terminal después de instalar Flutter

### Error: "No devices found"
- Para Windows: `flutter config --enable-windows-desktop`
- Para Linux: `flutter config --enable-linux-desktop`
- Para macOS: `flutter config --enable-macos-desktop`

### Error con dependencias
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Error de compilación
```bash
flutter doctor
```
Esto te mostrará qué falta por configurar

---

## 📱 Próximas Funcionalidades

🔜 Módulo de Diseños completo con imágenes  
🔜 Calendario visual para citas  
🔜 Exportar reportes a PDF  
🔜 Búsqueda y filtros avanzados  
🔜 Gráficas de ingresos  
🔜 Respaldo de base de datos  
🔜 Notificaciones de citas  

---

## 📸 Capturas de Pantalla

(Puedes agregar capturas del sistema funcionando)

---

## 👨‍💻 Desarrollo

**Desarrollador:** Luis Eduardo  
**Proyecto:** Sistema de Gestión de Tatuajes  
**Institución:** [Tu Institución]  
**Semestre:** Octubre 2025

---

## 📄 Licencia

Este proyecto es con fines educativos para la materia de Seminario de Desarrollo Tecnológico 2.

---

## 🤝 Soporte

Si tienes problemas o preguntas:
1. Revisa la documentación de Flutter: https://docs.flutter.dev
2. Consulta los errores en `flutter doctor`
3. Verifica que todas las dependencias estén instaladas

---

## ✨ Características Visuales

- 🎨 Interfaz moderna con Material Design
- 🌈 Paleta de colores personalizada
- 📊 Dashboard interactivo
- 🔄 Navegación fluida
- 💾 Guardado automático en SQLite
- 🎯 Diseño responsive

---

**¡Sistema listo para usar! 🚀**
