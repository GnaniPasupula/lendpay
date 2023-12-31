class subTransactions {
  final String transactionID;
  final String sender;
  final String receiver;
  final double amount;
  final String time;
  final String date;

  subTransactions({
    required this.transactionID,
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.time,
    required this.date,
  });

  factory subTransactions.fromJson(Map<String, dynamic> json) {
    return subTransactions(
      transactionID: json['transactionID'],
      sender: json['sender'],
      receiver: json['receiver'],
      amount: json['amount'],
      time: json['time'],
      date: json['date'],
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
    };
  }
}
