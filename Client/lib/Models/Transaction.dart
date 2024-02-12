import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final String sender;
  final String receiver;
  final int amount;
  final DateTime time;
  final DateTime startDate;
  final DateTime endDate;
  final int interestRate;
  final int paymentCycle; 
  final double subAmount;
  final int loanPeriod; 
  final double interestAmount;
  final double totalAmount;
  final double amountPaid;
  final String note;
  final String type;

  Transaction({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.time,
    required this.startDate,
    required this.endDate,
    required this.interestRate,
    required this.paymentCycle,
    required this.subAmount,
    required this.loanPeriod,
    required this.interestAmount,
    required this.totalAmount,
    required this.amountPaid,
    required this.note,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {

    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm');

    return Transaction(
      id: json['_id'],
      sender: json['sender'],
      receiver: json['receiver'],
      amount: json['amount'],
      time:timeFormat.parse(json['time']),
      startDate: dateFormat.parse(json['startDate']),
      endDate: dateFormat.parse(json['endDate']),
      interestRate: json['interestRate'],
      paymentCycle: json['paymentCycle'],
      subAmount: json['subAmount'],
      loanPeriod: json['loanPeriod'],
      interestAmount: json['interestAmount'],
      totalAmount: json['totalAmount'],
      amountPaid: json['amountPaid'],
      note: json['note'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {

    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm');

    return {
      '_id': id,
      'sender': sender,
      'receiver': receiver,
      'amount': amount,
      'time': timeFormat.format(time),
      'startDate': dateFormat.format(startDate),
      'endDate': dateFormat.format(endDate),
      'interestRate': interestRate,
      'paymentCycle': paymentCycle,
      'subAmount': subAmount,
      'loanPeriod': loanPeriod,
      'interestAmount': interestAmount,
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'note': note,
      'type': type,
    };
  }
}
