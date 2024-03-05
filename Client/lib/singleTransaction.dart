import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/Providers/subTransaction_provider.dart';
import 'package:lendpay/Providers/subTransactionsOfTransaction_provider.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/singleAgreementPage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class SingleTransactionsPage extends StatefulWidget {
  final subTransactions subTransaction;

  SingleTransactionsPage({required this.subTransaction});

  @override
  _SingleTransactionsState createState() => _SingleTransactionsState();
}

class _SingleTransactionsState extends State<SingleTransactionsPage> {
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat timeFormat = DateFormat('HH:mm a');

  late Transaction loan;
  late String tempDirPath;
  late ScreenshotController screenshotController;

  bool isManual=false;

  @override
  void initState() {
    super.initState();
    _fetchLoan();
    setState(() {
      isManual=(!widget.subTransaction.sender.contains("@") || !widget.subTransaction.receiver.contains("@"))?true:false;
    });
    screenshotController = ScreenshotController();
  }

  Future<void> _fetchLoan() async {
    try {
      final Transaction transaction =
          await ApiHelper.getLoan(widget.subTransaction.transactionID);

      setState(() {
        loan = transaction;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _takeScreenshotAndShare() async {
    try {
      // Take the screenshot
      final Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes != null) {
        // Save the screenshot to a temporary file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/screenshot.png');
        await file.writeAsBytes(imageBytes);

        // Share the screenshot
        final pickedFile = XFile(file.path);
        await Share.shareXFiles([pickedFile],
            text: 'Check out this screenshot');
      }
    } catch (e) {
      print('Error sharing screenshot: $e');
    }
  }

  Future<void> _deletePayment() async {
    final subtransactionsUserProvider = Provider.of<SubtransactionsOfTransactionProvider>(context,listen: false);
    final subtransactionsProvider = Provider.of<SubtransactionsProvider>(context,listen: false);

    try {
      final subTransactions subtransactionToDelete=await ApiHelper.deletePayment(
        subtransactionID: widget.subTransaction.id,
      );
      subtransactionsUserProvider.deletesubTransactionTransactionUser(subtransactionToDelete);
      subtransactionsProvider.deletesubTransaction(subtransactionToDelete);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment deleted successfully'),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      print('Error deleting transaction: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete payment. Please try again.'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    String formattedDate = dateFormat.format(widget.subTransaction.date);
    String formattedTime = timeFormat.format(widget.subTransaction.time);

    return Screenshot(
        controller: screenshotController,
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background, 
            appBar: AppBar(
              title: Text('Payment',
                  style: TextStyle(
                      fontSize: 18, color: Theme.of(context).colorScheme.onBackground,)),
              backgroundColor: Theme.of(context).colorScheme.surface, 
              elevation: 0,
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
                    child: Icon(Icons.person,
                        color: Theme.of(context).colorScheme.onSurfaceVariant, 
                        size: 50
                        ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    widget.subTransaction.sender,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.onBackground,)
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    '\u20B9' + widget.subTransaction.amount.toString(),
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    'Completed',
                    style: TextStyle(fontSize: 16.0, color: Colors.green),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    height: 1.0,
                    color: Colors.black,
                  ),
                  Text(
                    formattedDate + " " + formattedTime,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  // 6th to 10th row: Card with border outline
                  Card(
                    margin: const EdgeInsets.all(20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Title',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            height: 1.0,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 10.0),
                          Text('To: ${widget.subTransaction.receiver}'),
                          Text('${widget.subTransaction.receiver}@email.com'),
                          Text('${widget.subTransaction.sender}'),
                          Text('${widget.subTransaction.sender}@email.com'),
                          const SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                  ),
                  // New row with two buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SingleAgreementPage(
                                      viewAgreement: loan)));
                        },
                        style: ElevatedButton.styleFrom( 
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary, 
                        ),
                        child: const Text('Go to Loan'),
                      ),
                      const SizedBox(width: 20.0),
                      ElevatedButton(
                        onPressed: _takeScreenshotAndShare,
                        style: ElevatedButton.styleFrom( 
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary, 
                        ),
                        child: const Text('Share'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            floatingActionButton: !isManual ? null : FloatingActionButton(
              onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Delete",style: TextStyle(color: Theme.of(context).colorScheme.onError)),
                          content: const Text("Are you sure you want to delete this payment?"),
                          backgroundColor: Theme.of(context).colorScheme.surface,
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
                                Navigator.of(context).pop(); 
                                _deletePayment(); 
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
          )
        );      
  }
}
