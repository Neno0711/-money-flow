import 'package:money_flow/formulario_ingreso.dart';
class TransactionModel {
  final int? id;
  final String description;
  final double amount;
  final DateTime date; // Cambiado de String a DateTime
  final TransactionType type; // 'income' o 'expense'
  final String category;

  TransactionModel({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(), // Convertir DateTime a String
        'type': type.index, // Guardar el índice del enum
        'category': category,
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
        id: map['id'],
        description: map['description'],
        amount: map['amount'],
        date: DateTime.parse(map['date']), // Convertir String a DateTime
        type: map['type'] == 0
            ? TransactionType.gasto
            : TransactionType.ingreso,
        category: map['category'],
      );
}
