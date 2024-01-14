import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/incomingPaymentRequest.dart';
import 'package:lendpay/incomingRequest.dart';

class IncomingRequestPage extends StatefulWidget {
  @override
  _IncomingRequestPageState createState() => _IncomingRequestPageState();
}

class _IncomingRequestPageState extends State<IncomingRequestPage> {
  PageController _pageController = PageController(initialPage: 0);
  TextEditingController searchController = TextEditingController();

  List<Transaction> requestTransactions = [];
  List<subTransactions> paymentrequestTransactions = [];

  bool foundUser = false;
  late String username;

  @override
  void initState() {
    super.initState();
    fetchLoanRequests();
    fetchPaymentRequests();
  }

  void handleSearch() {
    setState(() {
      username = searchController.text;
    });
  }

  Future<void> fetchLoanRequests() async {
    try {
      final List<Transaction> requests = await ApiHelper.fetchUserRequests();
      setState(() {
        requestTransactions = requests;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchPaymentRequests() async {
    try {
      final List<subTransactions> requests =
          await ApiHelper.fetchUserPaymentRequests();
      setState(() {
        paymentrequestTransactions = requests;
      });
    } catch (e) {
      print(e);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(message, style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
        backgroundColor: Colors.yellow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double cardHeight = MediaQuery.of(context).size.height * 0.25;
    double insideCardHeight = cardHeight / 3.25;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search user',
                  prefixIcon: Icon(Icons.search),
                ),
                cursorColor: Colors.white,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: handleSearch,
            )
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: [
          // Body 1
          requestTransactions.isEmpty
              ? Center(child: Text('No requests available.'))
              : ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: requestTransactions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 5.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox(
                              height: insideCardHeight,
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => IncomingRequest(
                                        requestTransaction:
                                            requestTransactions[index],
                                      ),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: insideCardHeight * 0.75,
                                  ),
                                ),
                                title: Text(
                                  requestTransactions[index].receiver,
                                  style: TextStyle(
                                      fontSize: insideCardHeight * 0.325),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      DateFormat('dd-MM-yyyy').format(
                                          requestTransactions[index].startDate),
                                      style: TextStyle(
                                          fontSize: insideCardHeight * 0.225),
                                    ),
                                  ],
                                ),
                                trailing: Icon(Icons.more_vert,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    size: insideCardHeight * 0.5),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          paymentrequestTransactions.isEmpty
              ? Center(child: Text('No payment requests available.'))
              : ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: paymentrequestTransactions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 5.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox(
                              height: insideCardHeight,
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => IncomingPaymentRequest(
                                        paymentrequestTransaction:
                                            paymentrequestTransactions[index],
                                      ),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: insideCardHeight * 0.75,
                                  ),
                                ),
                                title: Text(
                                  requestTransactions[index].receiver,
                                  style: TextStyle(
                                      fontSize: insideCardHeight * 0.325),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      DateFormat('dd-MM-yyyy').format(
                                          requestTransactions[index].startDate),
                                      style: TextStyle(
                                          fontSize: insideCardHeight * 0.225),
                                    ),
                                  ],
                                ),
                                trailing: Icon(Icons.more_vert,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    size: insideCardHeight * 0.5),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
