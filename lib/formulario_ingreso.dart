import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_flow/models/transaction_model.dart';

const Color fondoColor = Color(0xFF121212);
const Color tarjetaColor = Color(0xFF1E1E1E);
const Color botonColor = Color(0xFFB8860B);
const Color textoClaro = Colors.white;
const Color textoOscuro = Colors.white70;

enum TransactionType { gasto, ingreso }

class FormularioIngreso extends StatefulWidget {
  final TransactionModel? existing;

  const FormularioIngreso({Key? key, this.existing}) : super(key: key);

  @override
  _FormularioIngresoState createState() => _FormularioIngresoState();
}

class _FormularioIngresoState extends State<FormularioIngreso> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _type;
  late String _description, _amount, _category;
  DateTime _date = DateTime.now();
  final _dateFmt = DateFormat('yyyy-MM-dd');

  final List<String> categoriasGasto = [
    'Comida',
    'Ropa',
    'Vivienda',
    'Transporte',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Otros',
  ];

  final List<String> categoriasIngreso = [
    'Salario',
    'Freelance',
    'Bonificaciones',
    'Regalo',
    'Venta',
    'Reembolso',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final existing = widget.existing!;
      _type = existing.type;
      _description = existing.description;
      _category = existing.category;
      _amount = existing.amount.abs().toString();
      _date = existing.date;
    } else {
      _type = TransactionType.gasto;
      _description = _category = _amount = '';
    }
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder:
          (_, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: botonColor,
                onPrimary: fondoColor,
                surface: tarjetaColor,
                onSurface: textoClaro,
              ),
            ),
            child: child!,
          ),
    );
    if (selectedDate != null) setState(() => _date = selectedDate);
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    final tx = TransactionModel(
      id: widget.existing?.id,
      description: _description,
      category: _category,
      amount: double.parse(_amount),
      date: _date,
      type: _type,
    );
    Navigator.pop(context, {'tx': tx});
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text('¿Eliminar esta transacción?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
    if (confirmed == true) Navigator.pop(context, {'delete': true});
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textoOscuro),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: textoOscuro),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      backgroundColor: fondoColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Gasto/Ingreso' : 'Nuevo Gasto/Ingreso'),
        backgroundColor: tarjetaColor,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<TransactionType>(
                                title: const Text(
                                  'Gasto',
                                  style: TextStyle(color: textoClaro),
                                ),
                                value: TransactionType.gasto,
                                groupValue: _type,
                                activeColor: botonColor,
                                onChanged: (v) => setState(() => _type = v!),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<TransactionType>(
                                title: const Text(
                                  'Ingreso',
                                  style: TextStyle(color: textoClaro),
                                ),
                                value: TransactionType.ingreso,
                                groupValue: _type,
                                activeColor: botonColor,
                                onChanged: (v) => setState(() => _type = v!),
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          initialValue: _description,
                          style: const TextStyle(color: textoClaro),
                          decoration: _buildInputDecoration('Descripción'),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          onChanged: (v) => _description = v,
                        ),
                        DropdownButtonFormField<String>(
                          value: _category.isNotEmpty ? _category : null,
                          style: const TextStyle(color: textoClaro),
                          decoration: _buildInputDecoration('Categoría'),
                          items:
                              (_type == TransactionType.gasto
                                      ? categoriasGasto
                                      : categoriasIngreso)
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(
                                        category,
                                        style: const TextStyle(
                                          color: textoClaro,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) => setState(() => _category = value!),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Requerido'
                                      : null,
                        ),
                        TextFormField(
                          initialValue: _amount,
                          style: const TextStyle(color: textoClaro),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          decoration: _buildInputDecoration('Monto'),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requerido';
                            final value = double.tryParse(v);
                            if (value == null || value <= 0)
                              return 'Ingrese un número positivo';
                            return null;
                          },
                          onChanged: (v) => _amount = v,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Fecha: ${_dateFmt.format(_date)}',
                              style: const TextStyle(color: textoClaro),
                            ),
                            const Spacer(),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: botonColor,
                              ),
                              onPressed: _pickDate,
                              child: const Text('Seleccionar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: botonColor,
                          ),
                          onPressed: _submit,
                          child: Text(isEdit ? 'Actualizar' : 'Guardar'),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            '© 2025 FutureCoders 35. All rights reserved.',
                            style: TextStyle(color: botonColor, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
