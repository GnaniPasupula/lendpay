class User {
  String email;
  String password;
  List<String> creditTransactions;
  List<String> debitTransactions;
  double totalCredit;
  double totalDebit;
  List<User> previousUsers;
  

  User({
    required this.email,
    required this.password,
    required this.creditTransactions,
    required this.debitTransactions,
    required this.totalCredit,
    required this.totalDebit,
    required this.previousUsers
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      password: json['password'],
      creditTransactions: List<String>.from(json['creditTransactions']),
      debitTransactions: List<String>.from(json['debitTransactions']),
      totalCredit: json['totalCredit'].toDouble(),
      totalDebit: json['totalDebit'].toDouble(),
      previousUsers: List<User>.from(json['previousUsers'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'creditTransactions': creditTransactions,
      'debitTransactions': debitTransactions,
      'totalCredit': totalCredit,
      'totalDebit': totalDebit,
      'previousUsers': previousUsers
    };
  }
}
