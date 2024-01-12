import 'package:intl/intl.dart';

class subTransactions {
  final String transactionID;
  final String sender;
  final String receiver;
  final double amount;
  final String time;
  final DateTime date;
  final String type;

  subTransactions({
    required this.transactionID,
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.time,
    required this.date,
    required this.type,
  });

  factory subTransactions.fromJson(Map<String, dynamic> json) {

    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm');

    return subTransactions(
      transactionID: json['transactionID'],
      sender: json['sender'],
      receiver: json['receiver'],
      amount: json['amount'],
      time: json['time'],
      date: json['date'],
      type: json['type']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionID': transactionID,
      'sender': sender,
      'receiver': receiver,
      'amount': amount,
      'time': time,
      'date': date,
      'type': type
    };
  }
}
