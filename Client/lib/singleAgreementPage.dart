import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/Providers/subTransactionsOfTransaction_provider.dart';
import 'package:lendpay/Providers/transactionsUser_provider.dart';
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
  bool isManual=false;

  late final SubtransactionsOfTransactionProvider subtransactionsOfTransactionProvider;

  @override
  void initState() {
    super.initState();
    _fetchSubTransactions();
    setState(() {
      isManual=(!widget.viewAgreement.sender.contains("@") || !widget.viewAgreement.receiver.contains("@"))?true:false;
    });
    subtransactionsOfTransactionProvider=Provider.of<SubtransactionsOfTransactionProvider>(context,listen: false);
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

  void _deleteTransaction() async {
    // print(widget.viewAgreement.toJson());
    final transactionsUserProvider = Provider.of<TransactionsUser>(context,listen: false);

    try {
      Transaction deletedTransaction= await ApiHelper.deleteTransaction(transactionID: widget.viewAgreement.id);
      transactionsUserProvider.deleteTransactionUser(deletedTransaction); 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loan deleted successfully'),
        ),
      );
      Navigator.of(context).pop();
      // print("Transaction deleted successfully");
    } catch (e) {
      print("Error deleting Loan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete Loan. Please try again.'),
        ),
      );
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

    // print(activeUser.email +"," + widget.requestTransaction.receiver);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 375-260

    // double searchBarWidth=(screenWidth/375)*260;
    // double searchBarHeight=35;

    double textMultiplier = 1;
    double widthMultiplier = 1;
    // double textMultiplier = screenHeight/812;
    // double widthMultiplier = screenWidth/375;
    //H=812 , W=375

    double iconSize = cardHeight * 0.25; // Adjust the icon size proportionally

    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Agreement', style: TextStyle(fontSize: 18,color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16,left: 16,right: 16),
                child: Text(
                'Loan Details',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500,color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
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
                            style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "( \$ ${widget.viewAgreement.subAmount}/Month)",
                            style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
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
                                return widget.viewAgreement.type != "req" ? AlertDialog(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  title: const Text('Add Monthly Payment'),
                                  content: !widget.viewAgreement.receiver.contains('@')?Text("Are you sure you want to add the monthly payment?",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface
                                  )):Text("Are you sure you want to send the payment request?",
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
                                      onPressed: () async {
                                        try {
                                          if(!widget.viewAgreement.receiver.contains('@')){
                                            subTransactions payment= await ApiHelper.addPayment(
                                              transactionID: widget.viewAgreement.id,
                                              paidAmount: widget.viewAgreement.interestAmount,
                                              date: date,
                                              isCredit: widget.viewAgreement.isCredit
                                            );
                                            /// Add to local storage , update subtransactions
                                            
                                            setState(() {
                                              allsubTransactions.add(payment);
                                            });

                                            }else{
                                            await ApiHelper.sendTransactionPaymentRequest(
                                              transactionID: widget.viewAgreement.id,
                                              paidAmount: widget.viewAgreement.interestAmount,
                                              date: date,
                                              isCredit: widget.viewAgreement.isCredit
                                            );
                                          }
                                          Navigator.of(context).pop(); 
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: Theme.of(context).colorScheme.surface, 
                                                title: Text('Success',style: TextStyle(color: Theme.of(context).colorScheme.onSurface) ),
                                                content: !widget.viewAgreement.receiver.contains('@')? Text('Payment added successfully.',style: TextStyle(color: Theme.of(context).colorScheme.onSurface)):Text('Payment request sent successfully.',style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(); // Close the current dialog
                                                      Navigator.of(context).pop(); // Close the current page
                                                    },
                                                    child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
                                ) : AlertDialog(
                                  title: const Text('Notice'),
                                  content: const Text('Your loan request is not accepted yet'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); 
                                        Navigator.pushReplacementNamed(context, '/dashboard');
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );                              
                              }
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary ),
                          ),
                          child: Text("Pay", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
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
                ? const Center(child: Text('No payments available.'))
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
                          padding: const EdgeInsets.only(left: 14,right: 14),
                          child: Container(
                            margin: const EdgeInsets.only(top: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height: screenHeight * 0.07,
                              width: screenWidth * 0.9,
                              child:InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleTransactionsPage(subTransaction:subTransaction)));                      
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12), 
                                  decoration: BoxDecoration(
                                    color: Colors.transparent, 
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: screenHeight * 0.07 * 0.75 * 0.5,
                                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant, 
                                        child: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant, size: screenHeight * 0.07 * 0.75),
                                      ),
                                      SizedBox(width: 23*widthMultiplier),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  subTransaction.sender,
                                                  style: TextStyle(fontSize: textMultiplier * 14, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
                                                ),
                                                Text(
                                                  DateFormat('dd-MM-yyyy').format(subTransaction.date),
                                                  style: TextStyle(fontSize: textMultiplier * 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              subTransaction.amount.toString(),
                                              style: TextStyle(fontSize: textMultiplier * 16, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
        floatingActionButton: !isManual ? null : FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Confirm Delete",style: TextStyle(color: Theme.of(context).colorScheme.onError)),
                  content: const Text("Are you sure you want to delete this Loan?"),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface, 
                        foregroundColor: Theme.of(context).colorScheme.onSurface 
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); 
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,  
                        foregroundColor: Theme.of(context).colorScheme.onError 
                      ), 
                      onPressed: () {
                        _deleteTransaction();
                        Navigator.of(context).pop(); 
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                );
              }
            );
          },
          backgroundColor: Theme.of(context).colorScheme.surface, 
          child: const Icon(Icons.delete),
        ),
      );
  }
  Widget _buildTextRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
