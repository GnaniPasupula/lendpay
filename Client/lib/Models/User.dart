class User {
  final String id;
  String? email;
  String password;
  String name;
  String? currencySymbol;
  List<String> creditTransactions;
  List<String> debitTransactions;
  List<String> requests;
  List<String> paymentrequests;
  double totalCredit;
  double totalDebit;
  List<String> previousUsers;
  List<String> subTransactions;
  String fCMToken;
  
  User({
    required this.id,
    this.email,
    required this.password,
    required this.name,
    this.currencySymbol='\$',
    required this.creditTransactions,
    required this.debitTransactions,
    required this.requests,
    required this.paymentrequests,
    required this.totalCredit,
    required this.totalDebit,
    required this.previousUsers,
    required this.subTransactions,
    required this.fCMToken
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:json['_id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      currencySymbol: json['currencySymbol'],
      creditTransactions: List<String>.from(json['creditTransactions']),
      debitTransactions: List<String>.from(json['debitTransactions']),
      requests: List<String>.from(json['requests']),
      paymentrequests: List<String>.from(json['paymentrequests']),
      totalCredit: json['totalCredit'].toDouble(),
      totalDebit: json['totalDebit'].toDouble(),
      previousUsers: List<String>.from(json['previousUsers']),
      subTransactions: List<String>.from(json['subTransactions']),
      fCMToken: json['fCMToken']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'password': password,
      'name': name,
      'currencySymbol': currencySymbol,
      'creditTransactions': creditTransactions,
      'debitTransactions': debitTransactions,
      'requests': requests,
      'paymentrequests': paymentrequests,
      'totalCredit': totalCredit,
      'totalDebit': totalDebit,
      'previousUsers': previousUsers,
      'subTransactions': subTransactions,
      'fCMToken': fCMToken
    };
  }
}
