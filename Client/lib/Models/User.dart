class User {
  // final String id;
  String email;
  String password;
  String name;
  List<String> creditTransactions;
  List<String> debitTransactions;
  List<String> requests;
  double totalCredit;
  double totalDebit;
  List<User> previousUsers;
  List<String> subTransactions;
  
  User({
    // required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.creditTransactions,
    required this.debitTransactions,
    required this.requests,
    required this.totalCredit,
    required this.totalDebit,
    required this.previousUsers,
    required this.subTransactions
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // id:json['_id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      creditTransactions: List<String>.from(json['creditTransactions']),
      debitTransactions: List<String>.from(json['debitTransactions']),
      requests: List<String>.from(json['requests']),
      totalCredit: json['totalCredit'].toDouble(),
      totalDebit: json['totalDebit'].toDouble(),
      previousUsers: List<User>.from(json['previousUsers']),
      subTransactions: List<String>.from(json['subTransactions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // '_id': id,
      'email': email,
      'password': password,
      'name': name,
      'creditTransactions': creditTransactions,
      'debitTransactions': debitTransactions,
      'requests': requests,
      'totalCredit': totalCredit,
      'totalDebit': totalDebit,
      'previousUsers': previousUsers,
      'subTransactions': subTransactions
    };
  }
}
