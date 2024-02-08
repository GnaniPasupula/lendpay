import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/agreementPage.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/singleAgreementPage.dart';
import 'package:lendpay/singleTransaction.dart';

class TransactionsPage extends StatefulWidget {
  final User otheruser;

  TransactionsPage({required this.otheruser});

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<TransactionsPage> {
  List<Transaction> allTransactionsUser = [];
  TextEditingController messageController = TextEditingController();

  Future<void> _fetchTransactions() async {
    try {
      final List<Transaction> transactions =
          await ApiHelper.fetchUserTransactions(widget.otheruser.email);
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

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 375-260

    double searchBarWidth=(screenWidth/375)*260;
    double searchBarHeight=35;

    double textMultiplier = 1;
    double widthMultiplier = 1;
    // double textMultiplier = screenHeight/812;
    // double widthMultiplier = screenWidth/375;
    //H=812 , W=375

    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        title: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: screenHeight * 0.07 * 0.75 * 0.5,
                  backgroundColor: Color.fromRGBO(218, 218, 218, 1),
                  child: Icon(Icons.person, color: const Color.fromARGB(255, 0, 0, 0), size: screenHeight * 0.07 * 0.75),
                ),
                SizedBox(width: 23 * widthMultiplier),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.otheruser.name,
                      style: TextStyle(fontSize: textMultiplier * 14, color: Color.fromRGBO(0, 0, 0, 1), fontWeight: FontWeight.w500),
                    ),
                    Text(
                      widget.otheruser.email,
                      style: TextStyle(fontSize: textMultiplier * 12, color: Color.fromRGBO(107, 114, 120, 1), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),        
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
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
          Container(
            width: searchBarWidth,
            height: searchBarHeight,
            margin: EdgeInsets.only(bottom: 10), 
            decoration: BoxDecoration(
              color: Color.fromRGBO(229, 229, 229, 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                SizedBox(width: 8), 
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: TextStyle(
                      fontSize: textMultiplier * 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      hintStyle: TextStyle(
                        fontSize: textMultiplier * 12,
                        color: Color.fromRGBO(107, 114, 120, 1),
                        fontWeight: FontWeight.w500,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: Color.fromRGBO(0, 0, 0, 1)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AgreementPage(amount: int.parse(messageController.text), otheruser: widget.otheruser)));
                        },
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 8), 
                      border: InputBorder.none,
                    ),
                    cursorColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTransactionItem(Transaction transaction) {
    bool isCredit = transaction.sender == widget.otheruser.email;
    bool isReq = transaction.type == "req";

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleAgreementPage(viewAgreement:transaction)));
      },
      child: Align(
        alignment: isCredit ? Alignment.centerLeft : Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7, 
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: isCredit ? Colors.green : Colors.blue,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isReq ? "Request":(isCredit ? "Credit" : "Debit")}: \$${transaction.amount}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 1.0,
                  color: Colors.white, 
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Note: ${transaction.note}',
                        style: const TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(transaction.time),
                      style: const TextStyle(fontSize: 12.0, color: Colors.white),
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
