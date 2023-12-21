class Transaction {
  // final String id;
  final String sender;
  final String receiver;
  final double amount;
  final DateTime date;
  final double interestRate;
  final double interestPeriod; 
  final String note;

  Transaction({
    // required this.id,
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.date,
    required this.interestRate,
    required this.interestPeriod,
    required this.note
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      // id:json['_id'],
      sender: json['sender'],
      receiver: json['receiver'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      interestRate: json['interestRate'],
      interestPeriod: json['interestPeriod'],
      note: json['note']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // '_id': id,
      'sender': sender,
      'receiver': receiver,
      'amount': amount,
      'date': date,
      'interestRate': interestRate,
      'interestPeriod': interestPeriod,
      'note': note
    };
  }
}
