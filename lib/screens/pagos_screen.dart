import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database_helper.dart';
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
  bool isLoading = true;
  double totalIngresos = 0.0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPagos();
  }

  Future<void> _loadPagos() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getPagos();
    final total = await DatabaseHelper.instance.getTotalIngresos();
    setState(() {
      pagos = data;
      pagosFiltrados = List.from(pagos);
      totalIngresos = total;
      isLoading = false;
    });
  }

  void _filterPagos(String q) {
    searchQuery = q;
    if (q.isEmpty) {
      setState(() => pagosFiltrados = List.from(pagos));
      return;
    }
    final lower = q.toLowerCase();
    setState(() {
      pagosFiltrados = pagos.where((p) {
        final cliente = (p['cliente'] ?? '').toString().toLowerCase();
        final metodo = (p['metodo_pago'] ?? '').toString().toLowerCase();
        final estado = (p['estado'] ?? '').toString().toLowerCase();
        return cliente.contains(lower) ||
            metodo.contains(lower) ||
            estado.contains(lower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Pagos',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                // Header
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
                                  size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Gestión de Pagos',
                                      style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '${pagosFiltrados.length} transaccion${pagosFiltrados.length != 1 ? 'es' : ''}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13, color: Colors.black54)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SearchField(
                            hintText: 'Buscar por cliente, método o estado...',
                            onChanged: _filterPagos),
                      ],
                    ),
                  ),
                ),

                // Total Card (responsive)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: GradientCard(
                    gradientColors: [
                      AppColors.pagosAccent,
                      AppColors.pagosAccent.withOpacity(0.8)
                    ],
                    child: LayoutBuilder(builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 600;
                      if (narrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.account_balance_wallet,
                                    color: AppColors.pagosAccent, size: 36),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text('Ingresos Totales',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 14))),
                            ]),
                            const SizedBox(height: 8),
                            Text('\${totalIngresos.toStringAsFixed(2)} MXN',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.add),
                                    label: const Text('Nuevo Pago'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            AppColors.pagosAccent))),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.account_balance_wallet,
                                  color: AppColors.pagosAccent, size: 40)),
                          const SizedBox(width: 20),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Ingresos Totales',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('\${totalIngresos.toStringAsFixed(2)} MXN',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold))
                              ])),
                          ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                              label: const Text('Nuevo Pago'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.pagosAccent)),
                        ],
                      );
                    }),
                  ),
                ),

                // Payments list
                Expanded(
                  child: pagosFiltrados.isEmpty
                      ? const EmptyState(
                          icon: Icons.payment_rounded,
                          title: 'No hay pagos registrados',
                          subtitle: 'Los pagos aparecerán aquí')
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                          itemCount: pagosFiltrados.length,
                          itemBuilder: (context, index) {
                            final pago = pagosFiltrados[index];
                            return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildPagoCard(pago));
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPagoCard(Map<String, dynamic> pago) {
    final isCompletado = pago['estado'] == 'Completado';
    return PrimaryCard(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(builder: (context, constraints) {
        final narrow = constraints.maxWidth < 600;
        if (narrow) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
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
                        color: isCompletado
                            ? AppColors.pagosAccent
                            : Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pago['cliente'] ?? 'Cliente desconocido',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Método: ${pago['metodo_pago'] ?? 'No especificado'}',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey[700])),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${pago['monto']}',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pagosAccent),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCompletado
                            ? Colors.green.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pago['estado'],
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isCompletado ? Colors.green : Colors.orange),
                      ),
                    ),
                  ],
                ),
              ]);
        }

        return Row(
          children: [
            Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: isCompletado
                        ? AppColors.pagosAccent.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    shape: BoxShape.circle),
                child: Icon(
                    isCompletado
                        ? Icons.check_circle_rounded
                        : Icons.schedule_rounded,
                    color: isCompletado ? AppColors.pagosAccent : Colors.orange,
                    size: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pago['cliente'] ?? 'Cliente desconocido',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.payment_rounded,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                          'Método: ${pago['metodo_pago'] ?? 'No especificado'}',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey[700]))
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text('Fecha: ${pago['fecha']}',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey[700]))
                    ]),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('\$${pago['monto']}',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pagosAccent)),
              const SizedBox(height: 6),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: isCompletado
                          ? Colors.green.withOpacity(0.15)
                          : Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(pago['estado'],
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCompletado ? Colors.green : Colors.orange))),
            ]),
          ],
        );
      }),
    );
  }
}
