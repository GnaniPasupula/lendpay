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
            CircleAvatar(
              radius: 50,
              // replace with actual image
              // backgroundImage: AssetImage(''),
              child:Icon(Icons.person)
            ),
            SizedBox(height: 10.0),
            // 2nd row: User name
            Text(
              'User Name',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            // 3rd row: Amount
            Text(
              '\$100.00',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            // 4th row: Text "Completed"
            Text(
              'Completed',
              style: TextStyle(fontSize: 16.0, color: Colors.green),
            ),
            // Horizontal line
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              height: 1.0,
              color: Colors.black,
            ),
            // 5th row: Date
            Text(
              '2023-10-26',
              style: TextStyle(fontSize: 16.0),
            ),
            // 6th to 10th row: Card with border outline
            Card(
              margin: EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(color: Colors.black),
              ),
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 6th row: "Title"
                    Align(
                      alignment: Alignment.center,
                      child:  
                        Text(
                          'Title',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      height: 1.0,
                      color: Colors.black,
                    ),
                    
                    SizedBox(height: 10.0),
                    // 7th row: To: receiverName
                    Text('To: Receiver Name'),
                    // 8th row: Receiver mail
                    Text('receiver@example.com'),
                    // 9th row: From: senderName
                    Text('From: Sender Name'),
                    // 10th row: Sender mail
                    Text('sender@example.com'),
                    SizedBox(height: 10.0),
                  ],
                ),
              ),
              
            ),
            Card(
              margin: EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(color: Colors.black),
              ),
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 6th row: "Title"
                    Align(
                      alignment: Alignment.center,
                      child:  
                        Text(
                          'Title',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      height: 1.0,
                      color: Colors.black,
                    ),
                    
                    SizedBox(height: 10.0),
                    // 7th row: To: receiverName
                    Text('To: Receiver Name'),
                    // 8th row: Receiver mail
                    Text('receiver@example.com'),
                    // 9th row: From: senderName
                    Text('From: Sender Name'),
                    // 10th row: Sender mail
                    Text('sender@example.com'),
                    SizedBox(height: 10.0),
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
