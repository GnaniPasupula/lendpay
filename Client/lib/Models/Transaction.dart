import 'package:intl/intl.dart';

class Transaction {
  // final String id;
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
  final String note;
  final String type;

  Transaction({
    // required this.id,
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
    required this.note,
    required this.type
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {

    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm');

    return Transaction(
      // id: json['_id'],
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
      note: json['note'],
      type: json['type']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // '_id': id,
      'sender': sender,
      'receiver': receiver,
      'amount': amount,
      'time': time,
      'startDate': startDate,
      'endDate': endDate,
      'interestRate': interestRate,
      'paymentCycle': paymentCycle,
      'subAmount': subAmount,
      'loanPeriod': loanPeriod,
      'interestAmount': interestAmount,
      'totalAmount': totalAmount,
      'note': note,
      'type': type
    };
  }
}
