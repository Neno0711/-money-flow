import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_flow/db/database_provider.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'formulario_ingreso.dart';

const Color fondoColor = Color(0xFF121212);
const Color tarjetaColor = Color(0xFF1E1E1E);
const Color botonColor = Color(0xFFB8860B);
const Color gastoColor = Color(0xFFFF6B6B);
const Color textoClaro = Colors.white;
const Color textoOscuro = Colors.white70;

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({Key? key}) : super(key: key);

  @override
  _PantallaPrincipalState createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final List<TransactionModel> _transactions = [];
  final db = DatabaseProvider.db;
  double _totalGastos = 0;
  double _totalIngresos = 0;

  final NumberFormat _fmt = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await db.getAllTransactions();
    final totalGastos = await db.getTotalByType(TransactionType.gasto);
    final totalIngresos = await db.getTotalByType(TransactionType.ingreso);

    setState(() {
      _transactions
        ..clear()
        ..addAll(transactions);
      _totalGastos = totalGastos;
      _totalIngresos = totalIngresos;
    });
  }

  Future<void> _showForm({TransactionModel? existing, int? index}) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => FormularioIngreso(existing: existing)),
    );

    if (result == null) return;

    if (result['delete'] == true && index != null) {
      await db.deleteTransaction(_transactions[index].id!);
    } else if (result['tx'] is TransactionModel) {
      final tx = result['tx'] as TransactionModel;
      if (existing != null && index != null) {
        await db.updateTransaction(tx);
      } else {
        await db.insertTransaction(tx);
      }
    }
    _loadData();
  }

  void _confirmAction(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: const Text('Editar'),
              ),
            ],
          ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: tarjetaColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: textoOscuro, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                _fmt.format(value),
                style: const TextStyle(
                  color: textoClaro,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: textoClaro)),
      ],
    );
  }

  Widget _buildTransactionList(MediaQueryData mq, int displayCount) {
    return ListView.builder(
      itemCount: displayCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, i) {
        final tx = _transactions[i];
        final isExpense = tx.type == TransactionType.gasto;
        return Card(
          color: tarjetaColor,
          margin: EdgeInsets.symmetric(vertical: mq.size.height * 0.01),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: mq.size.width * 0.04,
              vertical: mq.size.height * 0.015,
            ),
            leading: CircleAvatar(
              backgroundColor: (isExpense ? gastoColor : botonColor)
                  .withOpacity(0.2),
              child: Icon(
                isExpense ? Icons.remove : Icons.add,
                color: isExpense ? gastoColor : botonColor,
              ),
            ),
            title: Text(
              tx.description,
              style: const TextStyle(
                color: textoClaro,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${tx.category} · ${DateFormat('yyyy-MM-dd – kk:mm').format(tx.date)}',
              style: TextStyle(
                color: textoOscuro,
                fontSize: mq.textScaleFactor * 12,
              ),
            ),
            trailing: Text(
              _fmt.format(tx.amount.abs()),
              style: TextStyle(
                color: isExpense ? gastoColor : botonColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap:
                () => _confirmAction(
                  'Confirmar edición',
                  '¿Deseas editar esta transacción?',
                  () => _showForm(existing: tx, index: i),
                ),
            onLongPress:
                () => _confirmAction(
                  'Confirmar eliminación',
                  '¿Seguro que deseas eliminar esta transacción?',
                  () => setState(() => _transactions.removeAt(i)),
                ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width > 600;
    final displayCount = _transactions.length;

    return Scaffold(
      backgroundColor: fondoColor,
      appBar: AppBar(
        backgroundColor: tarjetaColor,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo.png',
          width: isWide ? 120 : 90,
          height: isWide ? 120 : 90,
          fit: BoxFit.contain,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: botonColor,
        child: const Icon(Icons.add, color: fondoColor),
        onPressed: () => _showForm(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: mq.size.width * 0.04,
            vertical: mq.size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              isWide
                  ? Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Gastos',
                          _totalGastos,
                          Icons.arrow_upward,
                          gastoColor,
                        ),
                      ),
                      SizedBox(width: mq.size.width * 0.03),
                      Expanded(
                        child: _buildSummaryCard(
                          'Ingresos',
                          _totalIngresos,
                          Icons.arrow_downward,
                          botonColor,
                        ),
                      ),
                    ],
                  )
                  : Column(
                    children: [
                      _buildSummaryCard(
                        'Gastos',
                        _totalGastos,
                        Icons.arrow_upward,
                        gastoColor,
                      ),
                      SizedBox(height: mq.size.height * 0.02),
                      _buildSummaryCard(
                        'Ingresos',
                        _totalIngresos,
                        Icons.arrow_downward,
                        botonColor,
                      ),
                    ],
                  ),
              SizedBox(height: mq.size.height * 0.02),
              Container(
                decoration: BoxDecoration(
                  color: tarjetaColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(mq.size.width * 0.04),
                child: AspectRatio(
                  aspectRatio: isWide ? 2 : 1.3,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 40,
                      sectionsSpace: 4,
                      sections:
                          _totalGastos == 0 && _totalIngresos == 0
                              ? [
                                PieChartSectionData(
                                  value: 1,
                                  color: Colors.grey[800],
                                  title: 'Sin datos',
                                  titleStyle: const TextStyle(
                                    color: textoClaro,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ]
                              : [
                                PieChartSectionData(
                                  value: _totalGastos,
                                  title: 'Gastos\n${_fmt.format(_totalGastos)}',
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    color: textoClaro,
                                    fontSize: 12,
                                  ),
                                  color: gastoColor,
                                ),
                                PieChartSectionData(
                                  value: _totalIngresos,
                                  title:
                                      'Ingresos\n${_fmt.format(_totalIngresos)}',
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    color: textoClaro,
                                    fontSize: 12,
                                  ),
                                  color: botonColor,
                                ),
                              ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: mq.size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendDot(gastoColor, 'Gastos'),
                  SizedBox(width: mq.size.width * 0.05),
                  _buildLegendDot(botonColor, 'Ingresos'),
                ],
              ),
              SizedBox(height: mq.size.height * 0.02),
              _buildTransactionList(mq, displayCount),
              const SizedBox(height: 100), // espacio adicional por el FAB
            ],
          ),
        ),
      ),
    );
  }
}
