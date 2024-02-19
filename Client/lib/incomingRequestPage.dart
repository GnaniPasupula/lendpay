import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/incomingPaymentRequest.dart';
import 'package:lendpay/incomingRequest.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncomingRequestPage extends StatefulWidget {

  @override
  _IncomingRequestPageState createState() => _IncomingRequestPageState();
}

class _IncomingRequestPageState extends State<IncomingRequestPage> {
  TextEditingController searchController = TextEditingController();

  List<Transaction> requestTransactions = [];
  List<subTransactions> paymentrequestTransactions = [];

  bool foundUser = false;
  late String username;

  bool isLoading = true;
  late SharedPreferences prefs;

  late User activeUser; 

  @override
  void initState() {
    super.initState();
    activeUser = Provider.of<UserProvider>(context, listen: false).activeUser;
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      prefs = await SharedPreferences.getInstance();

      final List<String>? requestTransactionsString = prefs.getStringList('${activeUser.email}/requestTransactions');
      if (requestTransactionsString != null) {
        requestTransactions = requestTransactionsString.map((requestString) => Transaction.fromJson(jsonDecode(requestString))).toList();
      }

      final List<String>? paymentrequestTransactionsString = prefs.getStringList('${activeUser.email}/paymentrequestTransactions');
      if (paymentrequestTransactionsString != null) {
        paymentrequestTransactions = paymentrequestTransactionsString.map((requestString) => subTransactions.fromJson(jsonDecode(requestString))).toList();
      }

      if (requestTransactions.isEmpty) {
        await fetchRequestTransactionsFromAPI();
      }

      if (paymentrequestTransactions.isEmpty) {
        await fetchPaymentRequestTransactionsFromAPI();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      // Handle error and show a proper error message to the user
    }
  }

  Future<void> fetchRequestTransactionsFromAPI() async {
    try {
      final List<Transaction> fetchedRequests = await ApiHelper.fetchUserRequests();
      setState(() {
        requestTransactions = fetchedRequests;
      });
      await saveRequestsToPrefs('${activeUser.email}/requestTransactions', fetchedRequests);
    } catch (e) {
      print(e);
      // Handle error and show a proper error message to the user
    }
  }

  Future<void> fetchPaymentRequestTransactionsFromAPI() async {
    try {
      final List<subTransactions> fetchedRequests = await ApiHelper.fetchUserPaymentRequests();
      setState(() {
        paymentrequestTransactions = fetchedRequests;
      });
      await saveRequestsToPrefs('${activeUser.email}/paymentrequestTransactions', fetchedRequests);
    } catch (e) {
      print(e);
      // Handle error and show a proper error message to the user
    }
  }

  Future<void> saveRequestsToPrefs(String key, List<dynamic> requests) async {
    final List<String> requestsString = requests.map((request) => jsonEncode(request.toJson())).toList();
    await prefs.setStringList(key, requestsString);
  }

  void handleSearch() {
    setState(() {
      username = searchController.text;
    });
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

    UserProvider userProvider = Provider.of<UserProvider>(context);
    User activeUser = userProvider.activeUser;

      if (isLoading) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  // 375-260

  double searchBarWidth=(screenWidth/375)*260;
  double searchBarHeight=35;

  double textMultiplier = 1;
  double widthMultiplier = 1;
  // double textMultiplier = screenHeight/812;
  // double widthMultiplier = screenWidth/375;
  //H=812 , W=375

    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        appBar: AppBar(
          leadingWidth: (screenWidth-searchBarWidth-12)/2,
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          title: 
            Container(
              width: searchBarWidth,
              height: searchBarHeight,
              decoration: BoxDecoration(
                color: Color.fromRGBO(229, 229, 229, 1), 
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: TextStyle( 
                        fontSize: textMultiplier * 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search with email',
                        hintStyle: TextStyle(
                          fontSize: textMultiplier * 12,
                          color: Color.fromRGBO(107, 114, 120, 1),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.search, color: Color.fromRGBO(0, 0, 0, 1)),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.done, color: Color.fromRGBO(0, 0, 0, 1)),
                          onPressed: handleSearch,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 7),
                        border: InputBorder.none,
                      ),
                      cursorColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          bottom: const TabBar(
            indicatorColor: Colors.black,
            tabs: [
              Tab(
                child: Text(
                  'Loan Requests',
                  style: TextStyle(
                    color: Colors.black, 
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Payment Requests',
                  style: TextStyle(
                    color: Colors.black, 
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildUserRequestsList(),
            buildPaymentRequestsList(),
          ],
        ),
      ),
    );
  }

  Widget buildUserRequestsList() {
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

    return requestTransactions.isEmpty
        ? Center(child: Text('No loan requests available.'))
        : ListView.builder(
              itemCount: requestTransactions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(left: 14,right: 14),
                  child: Container(
                    margin: EdgeInsets.only(top: 7.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(229, 229, 229, 0.3),
                    ),
                    child: SizedBox(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.9,
                      child:InkWell(
                        onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IncomingRequest(
                                  requestTransaction:
                                      requestTransactions[index],fetchRequestTransactionsFromAPI:fetchRequestTransactionsFromAPI
                                ),
                              ),
                            );                        
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12), 
                          decoration: BoxDecoration(
                            color: Colors.transparent, 
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: screenHeight * 0.07 * 0.75 * 0.5,
                                backgroundColor: Color.fromRGBO(218, 218, 218, 1),
                                child: Icon(Icons.person, color: const Color.fromARGB(255, 0, 0, 0), size: screenHeight * 0.07 * 0.75),
                              ),
                              SizedBox(width: 23*widthMultiplier), 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    requestTransactions[index].receiver,
                                    style: TextStyle(fontSize: textMultiplier * 14, color: Color.fromRGBO(0, 0, 0, 1), fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    DateFormat('dd-MM-yyyy').format(requestTransactions[index].startDate),
                                    style: TextStyle(fontSize: textMultiplier * 12, color: Color.fromRGBO(107, 114, 120, 1), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            
            );
  }

  Widget buildPaymentRequestsList() {

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

    return paymentrequestTransactions.isEmpty
        ? Center(child: Text('No payment requests available.'))
        : ListView.builder(
              itemCount: paymentrequestTransactions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(left: 14,right: 14),
                  child: Container(
                     margin: EdgeInsets.only(top: 14.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(229, 229, 229, 0.3),
                    ),
                    child: SizedBox(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.9,
                      child:InkWell(
                        onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IncomingPaymentRequest(
                                  paymentrequestTransaction:
                                      paymentrequestTransactions[index],fetchPaymentRequestTransactionsFromAPI:fetchPaymentRequestTransactionsFromAPI
                                ),
                              ),
                            );                        
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12), 
                          decoration: BoxDecoration(
                            color: Colors.transparent, 
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: screenHeight * 0.07 * 0.75 * 0.5,
                                backgroundColor: Color.fromRGBO(218, 218, 218, 1),
                                child: Icon(Icons.person, color: const Color.fromARGB(255, 0, 0, 0), size: screenHeight * 0.07 * 0.75),
                              ),
                              SizedBox(width: 23*widthMultiplier), 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    paymentrequestTransactions[index].receiver,
                                    style: TextStyle(fontSize: textMultiplier * 14, color: Color.fromRGBO(0, 0, 0, 1), fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    DateFormat('dd-MM-yyyy').format(paymentrequestTransactions[index].date),
                                    style: TextStyle(fontSize: textMultiplier * 12, color: Color.fromRGBO(107, 114, 120, 1), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
  }
}
