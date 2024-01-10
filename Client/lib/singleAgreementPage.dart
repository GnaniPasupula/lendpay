import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/api_helper.dart';
import 'package:provider/provider.dart';

class SingleAgreementPage extends StatefulWidget {

  final Transaction viewAgreement;

  SingleAgreementPage({
    required this.viewAgreement,
  });

  @override
  _SingleAgreementState createState() => _SingleAgreementState();
}

class _SingleAgreementState extends State<SingleAgreementPage> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String endDateFormatted = DateFormat('dd-MM-yyyy').format(widget.viewAgreement.endDate);

    String startDateFormatted = DateFormat('dd-MM-yyyy').format(widget.viewAgreement.startDate);

    // print(widget.requestTransaction.toJson());

    UserProvider userProvider = Provider.of<UserProvider>(context);
    User activeUser = userProvider.activeUser;

    // print(activeUser.email +"," + widget.requestTransaction.receiver);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Agreement'),
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
                  _buildTextRow("From", "gnani"),
                  const SizedBox(height: 8.0),
                  _buildTextRow("To", widget.viewAgreement.receiver),
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
                          "\$ ${widget.viewAgreement.totalAmount} ",
                          style: const TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "( \$ ${widget.viewAgreement.subAmount}/Month)",
                          style: const TextStyle(fontSize: 12.0, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
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
