import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/API/firebase_api.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/Providers/fCMToken_provider.dart';
import 'package:lendpay/api_helper.dart';
import 'package:provider/provider.dart';

class AgreementPage extends StatefulWidget {
  final int amount;
  final User otheruser;
  final void Function(Transaction) updateTransactions;

  AgreementPage({required this.amount, required this.otheruser, required this.updateTransactions});

  @override
  _AgreementPageState createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  late int loanAmount;
  late int period;
  late int interest;
  late int cycle;
  late double totalAmount;
  late double interestAmount;
  late double breakdownAmount;
  late TextEditingController _loanAmountController;
  late TextEditingController _periodAmountController;
  late TextEditingController _interestAmountController;
  late TextEditingController _cycleAmountController;


  @override
  void initState() {
    super.initState();
    loanAmount = widget.amount;
    totalAmount=loanAmount as double;
    _loanAmountController = TextEditingController(text: loanAmount.toString());
    _periodAmountController = TextEditingController(text: "12");
    _interestAmountController = TextEditingController(text: "12");
    _cycleAmountController = TextEditingController(text: "1");
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    String todayDate = DateFormat('dd-MM-yyyy').format(today);

    period = int.tryParse(_periodAmountController.text) ?? 0;
    DateTime endDate = today.add(Duration(days: period * 30));
    String endDateFormatted = DateFormat('dd-MM-yyyy').format(endDate);

    interest = int.tryParse(_interestAmountController.text) ?? 0;

    cycle = int.tryParse(_cycleAmountController.text) ?? 0;
    interestAmount = loanAmount*interest*period/(12*100);
    interestAmount = double.parse(interestAmount.toStringAsFixed(2));
    breakdownAmount = double.parse((totalAmount/period).toStringAsFixed(2));

    totalAmount=loanAmount+interestAmount;

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    FCMTokenProvider fcmTokenProvider = Provider.of<FCMTokenProvider>(context,listen: false);

    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: 18,color: Color.fromRGBO(0, 0, 0, 1))),
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Loan Details',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Customize your loan and EMI details',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Text(
                  'Select Loan Amount',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      loanAmount = (loanAmount - 1000).clamp(0, double.infinity).toInt();
                      _loanAmountController.text = loanAmount.toString();
                    });
                  },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _loanAmountController,
                      onChanged: (value) {
                        setState(() {
                          loanAmount = int.tryParse(value) ?? 0;
                        });
                      },
                      style: const TextStyle(fontSize: 64.0),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      loanAmount = (loanAmount + 1000).clamp(0, double.infinity).toInt();
                      _loanAmountController.text = loanAmount.toString();
                    });
                  },
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Choose tenor', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                Text('Payment cycle', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                Text('Choose interest', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFormBox(_periodAmountController, "Months", "period"),
                _buildFormBox(_cycleAmountController, "Months", "cycle"),
                _buildFormBox(_interestAmountController, "Interest", "interest")
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTextRow("From", userProvider.activeUser.email),
                  const SizedBox(height: 8.0),
                  _buildTextRow("To", widget.otheruser.email),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Start Date", todayDate),
                  const SizedBox(height: 8.0),
                  _buildTextRow("End Date", endDateFormatted),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Amount", loanAmount),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Interest", "$interest%"),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Payment cycle", "$cycle Months"),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Loan Period", "$period Months"),
                  const SizedBox(height: 8.0),
                  _buildTextRow("Total interest amount",interestAmount),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text("\$ $totalAmount ", style: const TextStyle(fontSize: 16.0,color: Colors.black,fontWeight: FontWeight.bold),),
                  Text("( \$ $breakdownAmount/Month)", style: const TextStyle(fontSize: 12.0,color: Colors.black),),
                  ],),
                  Container(
                    width: 150,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Show a confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Transaction Request"),
                              content: const Text("Are you sure you want to send the transaction request?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); 
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Transaction newTransaction = await ApiHelper.sendTransactionRequest(receiverEmail:widget.otheruser.email, amount: loanAmount, startDate: todayDate, endDate: endDateFormatted, interestRate: interest, paymentCycle: cycle, subAmount: breakdownAmount, loanPeriod: period, interestAmount: interestAmount, totalAmount: totalAmount);
                                    widget.updateTransactions(newTransaction);
                                    await FirebaseApi().sendNotificationToUser(receiverToken: fcmTokenProvider.fCMToken, title: "Loan", body: userProvider.activeUser.email);
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

  Widget _buildFormBox(TextEditingController controller, String label, String variable){
    return  SizedBox(
      width: 100.0,
      height: 70.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.grey[100],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  controller: controller,
                    onChanged: (value) {
                      setState(() {
                        switch (variable) {
                          case "period":
                            period = int.tryParse(value) ?? 0;
                            break;
                          case "cycle":
                            cycle = int.tryParse(value) ?? 0;
                            break;
                          case "interest":
                            interest = int.tryParse(value) ?? 0;
                            break;
                        }
                      });
                    },
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
