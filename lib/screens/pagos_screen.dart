import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  List<Map<String, dynamic>> pagos = [];
  List<Map<String, dynamic>> pagosFiltrados = [];
  List<Map<String, dynamic>> depositos = [];
  List<Map<String, dynamic>> depositosFiltrados = [];
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> citas = [];

  bool isLoading = true;
  double totalIngresos = 0.0;
  double totalDepositos = 0.0;
  String searchQuery = '';
  String? _filtroEstadoPago;
  String? _filtroEstadoDeposito;
  bool _vistaDepositos = false;

  @override
  void initState() {
    super.initState();
    _loadPagos();
  }

  Future<void> _loadPagos() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getPagos();
    final deps = await DatabaseHelper.instance.getDepositos();
    final total = await DatabaseHelper.instance.getTotalIngresos();
    final totalD = await DatabaseHelper.instance.getTotalDepositosRecibidos();
    final cl = await DatabaseHelper.instance.getClientes();
    final ci = await DatabaseHelper.instance.getCitas();
    setState(() {
      pagos = data;
      depositos = deps;
      clientes = cl;
      citas = ci;
      totalIngresos = total;
      totalDepositos = totalD;
      isLoading = false;
    });
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    var pl = List<Map<String, dynamic>>.from(pagos);
    if (_filtroEstadoPago != null) {
      pl = pl.where((p) => p['estado'] == _filtroEstadoPago).toList();
    }
    if (searchQuery.isNotEmpty && !_vistaDepositos) {
      final q = searchQuery.toLowerCase();
      pl = pl.where((p) {
        final c = (p['cliente'] ?? '').toString().toLowerCase();
        final m = (p['metodo_pago'] ?? '').toString().toLowerCase();
        final e = (p['estado'] ?? '').toString().toLowerCase();
        return c.contains(q) || m.contains(q) || e.contains(q);
      }).toList();
    }

    var dl = List<Map<String, dynamic>>.from(depositos);
    if (_filtroEstadoDeposito != null) {
      dl = dl.where((d) => d['estado'] == _filtroEstadoDeposito).toList();
    }
    if (searchQuery.isNotEmpty && _vistaDepositos) {
      final q = searchQuery.toLowerCase();
      dl = dl.where((d) {
        final c = (d['cliente'] ?? '').toString().toLowerCase();
        final m = (d['metodo_pago'] ?? '').toString().toLowerCase();
        final e = (d['estado'] ?? '').toString().toLowerCase();
        return c.contains(q) || m.contains(q) || e.contains(q);
      }).toList();
    }

    setState(() {
      pagosFiltrados = pl;
      depositosFiltrados = dl;
    });
  }

  void _filterPagos(String q) {
    searchQuery = q;
    _aplicarFiltros();
  }

  Future<void> _mostrarDialogoNuevoPago() async {
    int? idCliente;
    int? idCita;
    final montoCtrl = TextEditingController();
    String metodo = 'Efectivo';
    String estado = 'Completado';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Registrar pago', style: GoogleFonts.poppins()),
        content: SizedBox(
          width: 420,
          child: StatefulBuilder(
            builder: (context, setLocal) {
              final citasCliente = idCliente == null
                  ? <Map<String, dynamic>>[]
                  : citas
                      .where((c) => c['id_cliente'] == idCliente)
                      .toList();

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: idCliente,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      items: clientes
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['id_cliente'] as int,
                              child: Text(
                                  '${c['nombre']} ${c['apellido']}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setLocal(() {
                        idCliente = v;
                        idCita = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: idCita,
                      decoration: const InputDecoration(
                        labelText: 'Cita',
                        prefixIcon: Icon(Icons.event_rounded),
                      ),
                      items: citasCliente
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['id_cita'] as int,
                              child: Text(
                                '${c['fecha']} ${c['hora']} — ${c['tatuador'] ?? ''}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setLocal(() => idCita = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: montoCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Monto',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: metodo,
                      decoration: const InputDecoration(
                        labelText: 'Método de pago',
                      ),
                      items: ['Efectivo', 'Tarjeta', 'Transferencia', 'Otro']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setLocal(() => metodo = v ?? metodo),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: estado,
                      decoration:
                          const InputDecoration(labelText: 'Estado del pago'),
                      items: ['Pendiente', 'Completado']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setLocal(() => estado = v ?? estado),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok != true) {
      montoCtrl.dispose();
      return;
    }

    if (idCliente == null || idCita == null) {
      montoCtrl.dispose();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona cliente y cita')),
        );
      }
      return;
    }

    final monto = double.tryParse(montoCtrl.text.replaceAll(',', '.'));
    montoCtrl.dispose();
    if (monto == null || monto <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monto inválido')),
        );
      }
      return;
    }

    await DatabaseHelper.instance.insertPago({
      'monto': monto,
      'fecha': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'id_cliente': idCliente,
      'id_cita': idCita,
      'metodo_pago': metodo,
      'estado': estado,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago registrado')),
      );
      _loadPagos();
    }
  }

  Future<void> _mostrarDialogoNuevoDeposito() async {
    int? idCliente;
    int? idCita;
    final montoCtrl = TextEditingController();
    final notasCtrl = TextEditingController();
    String metodo = 'Efectivo';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Registrar depósito', style: GoogleFonts.poppins()),
        content: SizedBox(
          width: 420,
          child: StatefulBuilder(
            builder: (context, setLocal) {
              final citasCliente = idCliente == null
                  ? <Map<String, dynamic>>[]
                  : citas
                      .where((c) => c['id_cliente'] == idCliente)
                      .toList();

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: idCliente,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      items: clientes
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['id_cliente'] as int,
                              child: Text(
                                  '${c['nombre']} ${c['apellido']}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setLocal(() {
                        idCliente = v;
                        idCita = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      value: idCita,
                      decoration: const InputDecoration(
                        labelText: 'Cita (opcional)',
                        prefixIcon: Icon(Icons.event_rounded),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Sin vincular'),
                        ),
                        ...citasCliente.map(
                          (c) => DropdownMenuItem<int?>(
                            value: c['id_cita'] as int,
                            child: Text(
                              '${c['fecha']} ${c['hora']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setLocal(() => idCita = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: montoCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Monto del depósito',
                        prefixIcon: Icon(Icons.savings_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: metodo,
                      decoration: const InputDecoration(
                        labelText: 'Método',
                      ),
                      items: ['Efectivo', 'Tarjeta', 'Transferencia', 'Otro']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setLocal(() => metodo = v ?? metodo),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notasCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notas',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok != true) {
      montoCtrl.dispose();
      notasCtrl.dispose();
      return;
    }

    if (idCliente == null) {
      montoCtrl.dispose();
      notasCtrl.dispose();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona un cliente')),
        );
      }
      return;
    }

    final monto = double.tryParse(montoCtrl.text.replaceAll(',', '.'));
    montoCtrl.dispose();
    final notas = notasCtrl.text.trim();
    notasCtrl.dispose();

    if (monto == null || monto <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monto inválido')),
        );
      }
      return;
    }

    final row = <String, dynamic>{
      'id_cliente': idCliente,
      'monto': monto,
      'fecha': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'metodo_pago': metodo,
      'estado': 'Recibido',
      'notas': notas,
    };
    if (idCita != null) row['id_cita'] = idCita;

    await DatabaseHelper.instance.insertDeposito(row);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Depósito registrado')),
      );
      _loadPagos();
    }
  }

  Future<void> _eliminarDeposito(int id) async {
    final c = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar depósito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (c == true) {
      await DatabaseHelper.instance.deleteDeposito(id);
      _loadPagos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pagos y depósitos',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPagos,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: PrimaryCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.pagosAccent.withOpacity(0.2),
                                    AppColors.pagosAccent.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppColors.pagosAccent,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Caja',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  Text(
                                    _vistaDepositos
                                        ? '${depositosFiltrados.length} depósito(s) mostrados'
                                        : '${pagosFiltrados.length} pago(s) mostrados',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ToggleButtons(
                          isSelected: [!_vistaDepositos, _vistaDepositos],
                          onPressed: (i) {
                            setState(() => _vistaDepositos = i == 1);
                            _aplicarFiltros();
                          },
                          borderRadius: BorderRadius.circular(12),
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Pagos'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Depósitos'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SearchField(
                          hintText: _vistaDepositos
                              ? 'Buscar depósito por cliente o método...'
                              : 'Buscar pago por cliente o método...',
                          onChanged: _filterPagos,
                        ),
                        const SizedBox(height: 12),
                        if (!_vistaDepositos)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              children: [
                                FilterChip(
                                  label: const Text('Todos (estado)'),
                                  selected: _filtroEstadoPago == null,
                                  onSelected: (_) {
                                    setState(() => _filtroEstadoPago = null);
                                    _aplicarFiltros();
                                  },
                                ),
                                ...['Pendiente', 'Completado'].map(
                                  (e) => FilterChip(
                                    label: Text(e),
                                    selected: _filtroEstadoPago == e,
                                    onSelected: (_) {
                                      setState(() => _filtroEstadoPago = e);
                                      _aplicarFiltros();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              children: [
                                FilterChip(
                                  label: const Text('Todos'),
                                  selected: _filtroEstadoDeposito == null,
                                  onSelected: (_) {
                                    setState(
                                        () => _filtroEstadoDeposito = null);
                                    _aplicarFiltros();
                                  },
                                ),
                                ...['Recibido', 'Aplicado', 'Reembolsado'].map(
                                  (e) => FilterChip(
                                    label: Text(e),
                                    selected: _filtroEstadoDeposito == e,
                                    onSelected: (_) {
                                      setState(
                                          () => _filtroEstadoDeposito = e);
                                      _aplicarFiltros();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: GradientCard(
                    gradientColors: [
                      AppColors.pagosAccent,
                      AppColors.pagosAccent.withOpacity(0.8),
                    ],
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final narrow = constraints.maxWidth < 700;
                        final child = narrow
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ingresos (pagos completados)',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'MXN ${totalIngresos.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Depósitos recibidos',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'MXN ${totalDepositos.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _mostrarDialogoNuevoPago,
                                          icon: const Icon(Icons.add),
                                          label: const Text('Nuevo pago'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor:
                                                AppColors.pagosAccent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed:
                                              _mostrarDialogoNuevoDeposito,
                                          icon: const Icon(Icons.savings),
                                          label: const Text('Depósito'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            side: const BorderSide(
                                                color: Colors.white70),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ingresos (pagos completados)',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'MXN ${totalIngresos.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Depósitos recibidos: MXN ${totalDepositos.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white.withValues(
                                                alpha: 0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _mostrarDialogoNuevoPago,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Nuevo pago'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.pagosAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: _mostrarDialogoNuevoDeposito,
                                    icon: const Icon(Icons.savings),
                                    label: const Text('Depósito'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                          color: Colors.white70),
                                    ),
                                  ),
                                ],
                              );
                        return child;
                      },
                    ),
                  ),
                ),

                Expanded(
                  child: _vistaDepositos
                      ? (depositosFiltrados.isEmpty
                          ? const EmptyState(
                              icon: Icons.savings_rounded,
                              title: 'No hay depósitos',
                              subtitle:
                                  'Registra anticipos para reservar sesiones',
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 8, 24, 24),
                              itemCount: depositosFiltrados.length,
                              itemBuilder: (context, index) {
                                final d = depositosFiltrados[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildDepositoCard(d),
                                );
                              },
                            ))
                      : (pagosFiltrados.isEmpty
                          ? const EmptyState(
                              icon: Icons.payment_rounded,
                              title: 'No hay pagos registrados',
                              subtitle: 'Los pagos aparecerán aquí',
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 8, 24, 24),
                              itemCount: pagosFiltrados.length,
                              itemBuilder: (context, index) {
                                final pago = pagosFiltrados[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildPagoCard(pago),
                                );
                              },
                            )),
                ),
              ],
            ),
    );
  }

  Widget _buildDepositoCard(Map<String, dynamic> d) {
    return PrimaryCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.savings_rounded,
              color: AppColors.pagosAccent, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d['cliente'] ?? 'Cliente',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${d['fecha']} · ${d['metodo_pago'] ?? ''}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                if ((d['notas'] ?? '').toString().isNotEmpty)
                  Text(
                    d['notas'].toString(),
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
              ],
            ),
          ),
          Text(
            'MXN ${(d['monto'] as num).toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.pagosAccent,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () =>
                _eliminarDeposito(d['id_deposito'] as int),
          ),
        ],
      ),
    );
  }

  Widget _buildPagoCard(Map<String, dynamic> pago) {
    final isCompletado = pago['estado'] == 'Completado';
    return PrimaryCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isCompletado
                  ? AppColors.pagosAccent.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompletado
                  ? Icons.check_circle_rounded
                  : Icons.schedule_rounded,
              color: isCompletado ? AppColors.pagosAccent : Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pago['cliente'] ?? 'Cliente desconocido',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Método: ${pago['metodo_pago'] ?? '—'} · ${pago['fecha']}',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'MXN ${(pago['monto'] as num).toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pagosAccent,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompletado
                      ? Colors.green.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pago['estado'].toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCompletado ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
