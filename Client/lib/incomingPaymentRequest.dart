import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/api_helper.dart';
import 'package:provider/provider.dart';

class IncomingPaymentRequest extends StatefulWidget {

  final subTransactions paymentrequestTransaction;

  IncomingPaymentRequest({
    required this.paymentrequestTransaction,
  });

  @override
  _IncomingRequestState createState() => _IncomingRequestState();
}

class _IncomingRequestState extends State<IncomingPaymentRequest> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String endDateFormatted = DateFormat('dd-MM-yyyy').format(widget.paymentrequestTransaction.date);

    // print(widget.requestTransaction.toJson());

    UserProvider userProvider = Provider.of<UserProvider>(context);
    User activeUser = userProvider.activeUser;

    // print(activeUser.email +"," + widget.requestTransaction.receiver);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Request'),
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
                  _buildTextRow("From", widget.paymentrequestTransaction.receiver),
                  const SizedBox(height: 8.0),
                  _buildTextRow("To", widget.paymentrequestTransaction.sender),
                  const SizedBox(height: 8.0),
                  _buildTextRow("End Date", endDateFormatted),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Amount", widget.paymentrequestTransaction.amount),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "\$ ${widget.paymentrequestTransaction.amount} ",
                          style: const TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 30,
                      child: TextButton(
                        onPressed: activeUser.email == widget.paymentrequestTransaction.receiver
                            ? () {
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

                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Confirm"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            : null, // Set onPressed to null if condition is not met
                        child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(activeUser.email == widget.paymentrequestTransaction.receiver ? Colors.black : Colors.grey),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      height: 30,
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Decline Transaction Request"),
                                content: const Text("Are you sure you want to decline the transaction request?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {

                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Confirm"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text("Decline", style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
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
