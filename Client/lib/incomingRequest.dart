import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/api_helper.dart';

class IncomingRequest extends StatefulWidget {

  final User otheruser;
  final int loanAmount;
  final int period;
  final int interest;
  final int cycle;
  final double totalAmount;
  final double interestAmount;
  final double breakdownAmount;
  final String todayDate;
  final String endDateFormatted;

  IncomingRequest({
    required this.otheruser,
    required this.loanAmount,
    required this.period,
    required this.interest,
    required this.cycle,
    required this.totalAmount,
    required this.interestAmount,
    required this.breakdownAmount,
    required this.todayDate,
    required this.endDateFormatted
  });

  @override
  _IncomingRequestState createState() => _IncomingRequestState();
}

class _IncomingRequestState extends State<IncomingRequest> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agreement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Loan Details',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTextRow("From", "abc"),
                  const SizedBox(height: 8.0),
                  _buildTextRow("To", widget.otheruser.email),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Start Date", widget.todayDate),
                  const SizedBox(height: 8.0),
                  _buildTextRow("End Date", widget.endDateFormatted),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Amount", widget.loanAmount),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Interest", "$widget.interest%"),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Payment cycle", "${widget.cycle} Months"),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Loan Period", "${widget.period} Months"),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Total interest amount",widget.interestAmount),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text("\$ ${widget.totalAmount} ", style: const TextStyle(fontSize: 16.0,color: Colors.black,fontWeight: FontWeight.bold),),
                  Text("( \$ ${widget.breakdownAmount}/Month)", style: const TextStyle(fontSize: 12.0,color: Colors.black),),
                  ],),
                SizedBox(
                  width: 150,
                  height: 30,
                  child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Accept Transaction Request"),
                          content: const Text("Are you sure you want to accept the transaction request?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); 
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Perform the transaction request here
                                ApiHelper.sendTransactionRequest(receiverEmail: widget.otheruser.email, amount: widget.loanAmount, startDate: widget.todayDate, endDate: widget.endDateFormatted, interestRate: widget.interest, paymentCycle: widget.cycle, subAmount: widget.breakdownAmount, loanPeriod: widget.period, interestAmount: widget.interestAmount, totalAmount: widget.totalAmount);
                                Navigator.of(context).pop();
                              },
                              child: const Text("Confirm"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                    child: const Text("Request", style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                  ),
                )
              ],
            )
          ],
          
        ),
      ),
    );
  }

  Widget _buildTextRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

}
