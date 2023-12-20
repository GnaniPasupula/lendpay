class Transaction {
  final String sender;
  final String receiver;
  final double amount;
  final DateTime date;
  final double interestRate;
  final double interestPeriod; 
  final String note;

  Transaction({
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
