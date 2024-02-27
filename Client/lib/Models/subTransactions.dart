import 'package:intl/intl.dart';

class subTransactions {
  final String id;
  final String transactionID;
  final String sender;
  final String receiver;
  final double amount;
  final DateTime time;
  final DateTime date;
  final String type;
  final bool isCredit;

  subTransactions({
    required this.id,
    required this.transactionID,
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.time,
    required this.date,
    required this.type,
    required this.isCredit
  });

  factory subTransactions.fromJson(Map<String, dynamic> json) {

    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm');

    return subTransactions(
      id: json['_id'],
      transactionID: json['transactionID'],
      sender: json['sender'],
      receiver: json['receiver'],
      amount: json['amount'],
      time: timeFormat.parse(json['time']),
      date: dateFormat.parse(json['date']),
      type: json['type'],
      isCredit: json['isCredit']
    );
  }

  Map<String, dynamic> toJson() {

    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm');

    return {
      '_id': id,
      'transactionID': transactionID,
      'sender': sender,
      'receiver': receiver,
      'amount': amount,
      'time': timeFormat.format(time),
      'date': dateFormat.format(date),
      'type': type,
      'isCredit': isCredit
    };
  }
}
