import 'package:flutter/material.dart';
import 'package:lendpay/Models/Transaction.dart';

class SingleTransactionsPage extends StatefulWidget {

  final Transaction transaction;

  SingleTransactionsPage({required this.transaction});

  @override
  _SingleTransactionsState createState() => _SingleTransactionsState();
}

class _SingleTransactionsState extends State<SingleTransactionsPage> {
  @override
  Widget build(BuildContext context) {
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
            // 1st row: Profile picture
            const CircleAvatar(
              radius: 50,
              // replace with actual image
              // backgroundImage: AssetImage(''),
              child:Icon(Icons.person)
            ),
            const SizedBox(height: 10.0),
            // 2nd row: User name
            const Text(
              'User Name',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            // 3rd row: Amount
            const Text(
              '\$100.00',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 10.0),
            // 4th row: Text "Completed"
            const Text(
              'Completed',
              style: TextStyle(fontSize: 16.0, color: Colors.green),
            ),
            // Horizontal line
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              height: 1.0,
              color: Colors.black,
            ),
            // 5th row: Date
            const Text(
              '2023-10-26',
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
                      child:  
                        Text(
                          'Title',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      height: 1.0,
                      color: Colors.black,
                    ),
                    
                    const SizedBox(height: 10.0),
                    // 7th row: To: receiverName
                    const Text('To: Receiver Name'),
                    // 8th row: Receiver mail
                    const Text('receiver@example.com'),
                    // 9th row: From: senderName
                    const Text('From: Sender Name'),
                    // 10th row: Sender mail
                    const Text('sender@example.com'),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
              
            ),
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
                      child:  
                        Text(
                          'Title',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      height: 1.0,
                      color: Colors.black,
                    ),
                    
                    const SizedBox(height: 10.0),
                    // 7th row: To: receiverName
                    const Text('To: Receiver Name'),
                    // 8th row: Receiver mail
                    const Text('receiver@example.com'),
                    // 9th row: From: senderName
                    const Text('From: Sender Name'),
                    // 10th row: Sender mail
                    const Text('sender@example.com'),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
