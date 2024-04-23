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
  final void Function() fetchPaymentRequestTransactionsFromAPI;

  IncomingPaymentRequest({
    required this.paymentrequestTransaction,
    required this.fetchPaymentRequestTransactionsFromAPI
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
    String date = DateFormat('dd-MM-yyyy').format(widget.paymentrequestTransaction.date);

    // print(widget.requestTransaction.toJson());

    UserProvider userProvider = Provider.of<UserProvider>(context);
    User activeUser = userProvider.activeUser;

    // print(activeUser.email +"," + widget.requestTransaction.receiver);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, 
      appBar: AppBar(
        title: Text('payment Request', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Payment Details',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTextRow("From", widget.paymentrequestTransaction.receiver),
                  const SizedBox(height: 8.0),
                  _buildTextRow("To", widget.paymentrequestTransaction.sender),
                  const SizedBox(height: 8.0),
                  _buildTextRow("End Date", date),
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
                          style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
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
                        onPressed: activeUser.email != widget.paymentrequestTransaction.sender
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Accept Payment Request",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface
                                      )),
                                      content: Text("Are you sure you want to accept the payment request?",
                                       style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface
                                      )),
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
                                            ApiHelper.acceptTransactionPaymentRequest(transactionID: widget.paymentrequestTransaction.transactionID, date: date, subtransactionID: widget.paymentrequestTransaction.id, senderEmail: widget.paymentrequestTransaction.sender, receiverEmail: widget.paymentrequestTransaction.receiver);
                                            widget.fetchPaymentRequestTransactionsFromAPI();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Confirm"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            : null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(activeUser.email == widget.paymentrequestTransaction.sender ? Theme.of(context).colorScheme.primary : Colors.grey),
                        ), // Set onPressed to null if condition is not met
                        child: Text("Confirm", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
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
                                title:  Text("Decline Payment Request",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface
                                  )),
                                content: Text("Are you sure you want to decline the payment request?",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface
                                  )
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ApiHelper.rejectTransactionPaymentRequest(subtransactionID: widget.paymentrequestTransaction.id, senderEmail: widget.paymentrequestTransaction.sender, receiverEmail: widget.paymentrequestTransaction.receiver);
                                      widget.fetchPaymentRequestTransactionsFromAPI();
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Confirm"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                        ),
                        child: Text("Decline", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
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
          style:  TextStyle(
            fontSize: 14.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value.toString(),
            style:  TextStyle(
              fontSize: 14.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

}
