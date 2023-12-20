import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/singleTransaction.dart';

class TransactionsPage extends StatefulWidget {
  final User user;

  TransactionsPage({required this.user});

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<TransactionsPage> {
  List<Transaction> allTransactionsUser = [];
  TextEditingController messageController = TextEditingController();

  Future<void> _fetchTransactions() async {
    try {
      final List<Transaction> transactions =
          await ApiHelper.fetchUserTransactions(widget.user.email);
      setState(() {
        allTransactionsUser = transactions;
      });
      // print(allTransactionsUser);
    } catch (e) {
      print(e);
      // Handle error and show a proper error message to the user
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(widget.user.email),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: allTransactionsUser.length,
              reverse: true,
              itemBuilder: (context, index) {
                final transaction = allTransactionsUser[index];
                return buildTransactionItem(transaction);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  )
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Handle sending the message
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTransactionItem(Transaction transaction) {
    bool isCredit = transaction.sender == widget.user.email;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SingleTransactionsPage(transaction: transaction)));
      },
      child: Align(
        alignment: isCredit ? Alignment.centerLeft : Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7, // Adjust the percentage as needed
          ),
          child: Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: isCredit ? Colors.green : Colors.blue,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isCredit ? "Credit" : "Debit"}: \$${transaction.amount}',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 8.0),
                Container(
                  height: 1.0,
                  color: Colors.white, // Adjust the color as needed
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Note: ${transaction.note}',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${DateFormat('hh:mm a').format(transaction.date)}',
                      style: TextStyle(fontSize: 12.0, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
