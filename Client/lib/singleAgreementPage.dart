import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/singleTransaction.dart';
import 'package:provider/provider.dart';

class SingleAgreementPage extends StatefulWidget {

  final Transaction viewAgreement;

  const SingleAgreementPage({
    required this.viewAgreement,
  });

  @override
  _SingleAgreementState createState() => _SingleAgreementState();
}

class _SingleAgreementState extends State<SingleAgreementPage> {

  List<subTransactions> allsubTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchSubTransactions();
  }

  Future<void> _fetchSubTransactions() async {
    try {
      final List<subTransactions> transactions = await ApiHelper.fetchSubTransactionsOfTransaction(widget.viewAgreement.id);
      setState(() {
        allsubTransactions=transactions;
      });
      // print('all transactions = ${allTransactions}');
    } catch (e) {
      print(e);
      // Handle error and show a proper error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    String endDateFormatted = DateFormat('dd-MM-yyyy').format(widget.viewAgreement.endDate);

    String startDateFormatted = DateFormat('dd-MM-yyyy').format(widget.viewAgreement.startDate);

    String date=DateFormat('dd-MM-yyyy').format(DateTime.now());

    double cardHeight = MediaQuery.of(context).size.height * 0.25; // Card height
    double insideCardHeight=cardHeight/3.25;

    // print(widget.requestTransaction.toJson());

    UserProvider userProvider = Provider.of<UserProvider>(context);
    User activeUser = userProvider.activeUser;

    // print(activeUser.email +"," + widget.requestTransaction.receiver);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Agreement'),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 16,left: 16,right: 16),
                child: Text(
                'Loan Details',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTextRow("From", widget.viewAgreement.receiver),
                      const SizedBox(height: 8.0),
                      _buildTextRow("To", widget.viewAgreement.sender),
                      const SizedBox(height: 8.0),
                      _buildTextRow("Start Date", startDateFormatted),
                      const SizedBox(height: 8.0),
                      _buildTextRow("End Date", endDateFormatted),
                      const SizedBox(height: 8.0),
                      _buildTextRow("Amount", widget.viewAgreement.amount),
                      const SizedBox(height: 8.0),
                      _buildTextRow("Interest", "${widget.viewAgreement.interestRate}%"),
                      const SizedBox(height: 8.0),
                      _buildTextRow("Payment cycle", "${widget.viewAgreement.paymentCycle} Months"),
                      const SizedBox(height: 8.0),
                      _buildTextRow("Loan Period", "${widget.viewAgreement.loanPeriod} Months"),
                      const SizedBox(height: 8.0),
                      _buildTextRow("Total interest amount",widget.viewAgreement.interestAmount),
                      const SizedBox(height: 8.0),
                      _buildTextRow("Total amount paid",widget.viewAgreement.amountPaid),
                    ],
                  ),
              ),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 8,left: 16,right: 16),
              child:Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "\$ ${widget.viewAgreement.totalAmount} ",
                            style: const TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "( \$ ${widget.viewAgreement.subAmount}/Month)",
                            style: const TextStyle(fontSize: 12.0, color: Colors.black),
                          ),
                        ],
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
                                  title: const Text('Pay Monthly Payment'),
                                  content: const Text("Are you sure you want to pay the transaction request?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          // Call the API function
                                          await ApiHelper.sendTransactionPaymentRequest(
                                            transactionID: widget.viewAgreement.id,
                                            paidAmount: widget.viewAgreement.interestAmount,
                                            date: date,
                                          );

                                          // Show success popup
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Success'),
                                                content: const Text('Payment request sent successfully.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(); // Close the dialog
                                                      Navigator.of(context).pop(); // Close the current page
                                                      Navigator.pushReplacementNamed(context, '/dashboard');
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } catch (e) {
                                          // Handle error if the API call fails
                                          print('Error: $e');
                                          // You can show an error popup or handle it based on your requirements
                                        }
                                      },
                                      child: const Text("Confirm"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text("Pay", style: TextStyle(color: Colors.white)),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),   
                ],
              ),
            ),
            Expanded(
            child: allsubTransactions.isEmpty
                ? const Center(child: Text('No transactions available.'))
                : ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0), // Top left corner
                    topRight: Radius.circular(24.0), // Top right corner
                  ),
                  child: Container(
                    color: Colors.white, // Set the background color to white
                    child: ListView.builder(
                      itemCount: allsubTransactions.length,
                      itemBuilder: (context, index) {
                        final subTransaction = allsubTransactions[index];

                        final transactionDate = subTransaction.date;
                        String formattedDate;
                        final now = DateTime.now();

                        // if (transactionDate.year == now.year &&
                        //     transactionDate.month == now.month &&
                        //     transactionDate.day == now.day) {
                        //   // Show time in 12hr format along with the date if it's today
                        //   formattedDate = DateFormat('d MMM h:mm a').format(transactionDate);
                        // } else if (transactionDate.year == now.year &&
                        //     transactionDate.month == now.month &&
                        //     transactionDate.day == now.day - 1) {
                        //   // Show "Yesterday" along with the time if it's yesterday
                        //   formattedDate = 'Yesterday ' + DateFormat.jm().format(transactionDate);
                        // } else if (transactionDate.year == now.year) {
                        //   // Show date in the format "day Month" along with the time if it's this year
                        //   formattedDate = DateFormat('d MMM').format(transactionDate) +
                        //       ' ' +
                        //       DateFormat.jm().format(transactionDate);
                        // } else {
                        //   // Show date in the format "day Month Year" along with the time
                        //   formattedDate = DateFormat('d MMM y').format(transactionDate) +
                        //       ' ' +
                        //       DateFormat.jm().format(transactionDate);
                        // }
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox(
                              height: insideCardHeight, // Set the individual card's height
                              child: ListTile(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleTransactionsPage(subTransaction:subTransaction)));
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: Icon(Icons.person, color: Colors.white,size:insideCardHeight*0.75),
                                ),
                                title: Text(
                                  subTransaction.receiver,
                                  style: TextStyle(fontSize: insideCardHeight * 0.325),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(DateFormat('dd-MM-yyyy').format(subTransaction.date),style: TextStyle(fontSize: insideCardHeight * 0.225)),
                                  ],
                                ),
                                trailing: Text(subTransaction.amount.toString(),style: TextStyle(fontSize: insideCardHeight * 0.3)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          ),
          ],
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
