import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/singleAgreementPage.dart';

class SingleTransactionsPage extends StatefulWidget {

  final subTransactions subTransaction;

  SingleTransactionsPage({required this.subTransaction});

  @override
  _SingleTransactionsState createState() => _SingleTransactionsState();
}

class _SingleTransactionsState extends State<SingleTransactionsPage> {

  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat timeFormat = DateFormat('HH:mm a');

   late Transaction loan;

    @override
    void initState() {
      super.initState();
      _fetchLoan();
    }

    Future<void> _fetchLoan() async {
      try {
        final Transaction transaction = await ApiHelper.getLoan(widget.subTransaction.transactionID);

        setState(() {
          loan=transaction;
        });
      } catch (e) {
        print(e);
      }
    }

  @override
  Widget build(BuildContext context) {

    String formattedDate = dateFormat.format(widget.subTransaction.date);
    String formattedTime = timeFormat.format(widget.subTransaction.time);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person),
            ),
            const SizedBox(height: 10.0),
            Text(
              widget.subTransaction.sender,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Text(
              '\u20B9' + widget.subTransaction.amount.toString(),
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Completed',
              style: TextStyle(fontSize: 16.0, color: Colors.green),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              height: 1.0,
              color: Colors.black,
            ),
            Text(
              formattedDate+" "+formattedTime,
              style: TextStyle(fontSize: 16.0),
            ),
            // 6th to 10th row: Card with border outline
            Card(
              margin: const EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(color: Colors.black),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 6th row: "Title"
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Title',
                        style:
                            TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      height: 1.0,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 10.0),
                    // 7th row: To: receiverName
                    Text('To: ${widget.subTransaction.receiver}'),
                    // 8th row: Receiver mail
                    Text('${widget.subTransaction.receiver}@email.com'),
                    // 9th row: From: senderName
                    Text('${widget.subTransaction.sender}'),
                    // 10th row: Sender mail
                    Text('${widget.subTransaction.sender}@email.com'),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
            // New row with two buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleAgreementPage(viewAgreement:loan)));
                  },
                  child: Text('Go to Loan'),
                ),
                SizedBox(width: 20.0), 
                ElevatedButton(
                  onPressed: () {

                  },
                  child: Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
