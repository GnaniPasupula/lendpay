import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:provider/provider.dart';

class AgreementPage extends StatefulWidget {
  final int amount;
  final User otheruser;

  AgreementPage({required this.amount,required this.otheruser});

  @override
  _AgreementPageState createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  late double rateOfInterest;
  late int period;
  late DateTime startDate;
  late DateTime endDate;
  late String paymentPeriod;

  @override
  void initState() {
    super.initState();
    // Set default values or initialize the necessary variables here
    rateOfInterest = 0.0;
    period = 0;
    startDate = DateTime.now();
    endDate = DateTime.now();
    paymentPeriod = 'Monthly';
  }

  @override
  Widget build(BuildContext context) {
    User fromUser = Provider.of<UserProvider>(context).activeUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Agreement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: \$${widget.amount}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Rate of Interest: ${rateOfInterest.toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Period: $period months',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Start Date: ${DateFormat('dd/MM/yyyy').format(startDate)}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'End Date: ${DateFormat('dd/MM/yyyy').format(endDate)}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Payment Period: $paymentPeriod',
              style: TextStyle(fontSize: 16.0),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // Handle X button press
                  },
                ),
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    // Handle Check Mark button press
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
