import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/Providers/allTransactions_provider.dart';
import 'package:lendpay/Providers/incomingPaymentRequest_provider.dart';
import 'package:lendpay/Providers/incomingRequest_provider.dart';
import 'package:lendpay/Providers/subTransaction_provider.dart';
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

  late final TransactionsAllProvider transactionsAllProvider;
  late final SubtransactionsProvider subtransactionsProvider;
  late final IncomingRequestProvider incomingRequestProvider;
  late final IncomingPaymentRequestProvider incomingPaymentRequestProvider;

  @override
  void initState() {
    super.initState();
    transactionsAllProvider = Provider.of<TransactionsAllProvider>(context,listen: false);
    subtransactionsProvider = Provider.of<SubtransactionsProvider>(context,listen: false);
    incomingRequestProvider = Provider.of<IncomingRequestProvider>(context,listen: false);
    incomingPaymentRequestProvider = Provider.of<IncomingPaymentRequestProvider>(context,listen: false);
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
      backgroundColor: Theme.of(context).colorScheme.background, 
      appBar: AppBar(
        title: Text('Loan Request', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Loan Details',
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
                          style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "( \$ ${widget.requestTransaction.subAmount}/Month)",
                          style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
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
                                      title:  Text("Accept Transaction Request",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface
                                      )),
                                      content:  Text("Are you sure you want to accept the transaction request?",
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

                                            transactionsAllProvider.addTransaction(newTransaction);
                                            incomingRequestProvider.deleteRequest(newTransaction);
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
                            : null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(activeUser.email == widget.requestTransaction.receiver ? Theme.of(context).colorScheme.primary : Colors.grey),
                        ), 
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
                                title:  Text("Decline Transaction Request",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface
                                  )),
                                content: Text("Are you sure you want to decline the transaction request?",
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
