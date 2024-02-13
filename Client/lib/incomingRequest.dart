import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/api_helper.dart';
import 'package:provider/provider.dart';

class IncomingRequest extends StatefulWidget {

  final Transaction requestTransaction;
  final void Function() fetchRequestTransactionsFromAPI;

  IncomingRequest({
    required this.requestTransaction,
    required this.fetchRequestTransactionsFromAPI
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
    String endDateFormatted = DateFormat('dd-MM-yyyy').format(widget.requestTransaction.endDate);

    String startDateFormatted = DateFormat('dd-MM-yyyy').format(widget.requestTransaction.startDate);

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
                  _buildTextRow("From", widget.requestTransaction.receiver),
                  const SizedBox(height: 8.0),
                  _buildTextRow("To", widget.requestTransaction.sender),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Start Date", startDateFormatted),
                  const SizedBox(height: 8.0),
                  _buildTextRow("End Date", endDateFormatted),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Amount", widget.requestTransaction.amount),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Interest", "${widget.requestTransaction.interestRate}%"),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Payment cycle", "${widget.requestTransaction.paymentCycle} Months"),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Loan Period", "${widget.requestTransaction.loanPeriod} Months"),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Total interest amount",widget.requestTransaction.interestAmount),
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
                          "\$ ${widget.requestTransaction.totalAmount} ",
                          style: const TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "( \$ ${widget.requestTransaction.subAmount}/Month)",
                          style: const TextStyle(fontSize: 12.0, color: Colors.black),
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
                        onPressed: activeUser.email == widget.requestTransaction.receiver
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
                                          onPressed: () async{
                                            // Perform the transaction request here
                                            Transaction newTransaction=await ApiHelper.acceptTransactionRequest(
                                              requestTransactionID: widget.requestTransaction.id,
                                              senderEmail: widget.requestTransaction.sender,
                                              amount: widget.requestTransaction.amount,
                                              startDate: startDateFormatted,
                                              endDate: endDateFormatted,
                                              interestRate: widget.requestTransaction.interestRate,
                                              paymentCycle: widget.requestTransaction.paymentCycle,
                                              subAmount: widget.requestTransaction.subAmount,
                                              loanPeriod: widget.requestTransaction.loanPeriod,
                                              interestAmount: widget.requestTransaction.interestAmount,
                                              totalAmount: widget.requestTransaction.totalAmount,
                                            );

                                            widget.fetchRequestTransactionsFromAPI();
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
                          backgroundColor: MaterialStateProperty.all<Color>(activeUser.email == widget.requestTransaction.receiver ? Colors.black : Colors.grey),
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
                                      // Perform the transaction request here
                                      ApiHelper.rejectTransactionRequest(
                                        requestTransactionID: widget.requestTransaction.id,
                                        receiverEmail: widget.requestTransaction.receiver,
                                      );
                                      widget.fetchRequestTransactionsFromAPI();
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
