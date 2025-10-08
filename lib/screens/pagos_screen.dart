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
      pagosFiltrados = data;
      totalIngresos = total;
      isLoading = false;
    });
  }

  void _filterPagos(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        pagosFiltrados = pagos;
      } else {
        pagosFiltrados = pagos.where((pago) {
          final cliente = (pago['cliente'] ?? '').toLowerCase();
          final metodo = (pago['metodo_pago'] ?? '').toLowerCase();
          final estado = (pago['estado'] ?? '').toLowerCase();
          final searchLower = query.toLowerCase();

          return cliente.contains(searchLower) ||
              metodo.contains(searchLower) ||
              estado.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
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
                      child: Icon(
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
                            'Gestión de Pagos',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${pagosFiltrados.length} transaccion${pagosFiltrados.length != 1 ? 'es' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SearchField(
                  hintText: 'Buscar por cliente, método o estado...',
                  onChanged: _filterPagos,
                ),
              ],
            ),
          ),

          // Total Card
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
            child: GradientCard(
              gradientColors: [
                AppColors.pagosAccent,
                AppColors.pagosAccent.withOpacity(0.8),
              ],
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ingresos Totales',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${totalIngresos.toStringAsFixed(2)} MXN',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '+25%',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de pagos
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : pagosFiltrados.isEmpty
                    ? EmptyState(
                        icon: Icons.payment_rounded,
                        title: searchQuery.isEmpty
                            ? 'No hay pagos registrados'
                            : 'No se encontraron resultados',
                        subtitle: searchQuery.isEmpty
                            ? 'Los pagos aparecerán aquí'
                            : 'Intenta con otra búsqueda',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                        itemCount: pagosFiltrados.length,
                        itemBuilder: (context, index) {
                          final pago = pagosFiltrados[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPagoCard(pago),
                          );
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
      padding: const EdgeInsets.all(20),
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
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pago['cliente'] ?? 'Cliente desconocido',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.payment_rounded,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Método: ${pago['metodo_pago'] ?? 'No especificado'}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Fecha: ${pago['fecha']}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${pago['monto']}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pagosAccent,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
