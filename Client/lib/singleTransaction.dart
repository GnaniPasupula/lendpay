import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/singleAgreementPage.dart';
import 'package:path_provider/path_provider.dart';
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
    try {
      await ApiHelper.deletePayment(
        subtransactionID: widget.subTransaction.id,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment deleted successfully'),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      print('Error deleting transaction: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
            backgroundColor: Color.fromRGBO(255, 255, 255, 1),
            appBar: AppBar(
              title: Text('Payment',
                  style: TextStyle(
                      fontSize: 18, color: Color.fromRGBO(0, 0, 0, 1))),
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color.fromRGBO(218, 218, 218, 1),
                    child: Icon(Icons.person,
                        color: const Color.fromARGB(255, 0, 0, 0), size: 50),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    widget.subTransaction.sender,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    '\u20B9' + widget.subTransaction.amount.toString(),
                    style: TextStyle(fontSize: 16.0),
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
                    style: TextStyle(fontSize: 16.0),
                  ),
                  // 6th to 10th row: Card with border outline
                  Card(
                    margin: const EdgeInsets.all(20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: const BorderSide(color: Colors.black),
                    ),
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
                        child: Text('Go to Loan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 20.0),
                      ElevatedButton(
                        onPressed: _takeScreenshotAndShare,
                        child: Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
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
                          title: Text("Confirm Delete"),
                          content: Text("Are you sure you want to delete this transaction?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); 
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); 
                                _deletePayment();
                              },
                              child: Text("Delete"),
                            ),
                          ],
                        );
                      }
                    );
              },
              child: Icon(Icons.delete),
              backgroundColor: Colors.black,
            ),
          )
        );      
  }
}
