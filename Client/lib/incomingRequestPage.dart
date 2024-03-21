import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/Providers/incomingPaymentRequest_provider.dart';
import 'package:lendpay/Providers/incomingRequest_provider.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/incomingPaymentRequest.dart';
import 'package:lendpay/incomingRequest.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  bool shouldUpdate=false;

  late SharedPreferences prefs;
  late User activeUser;

  late final IncomingRequestProvider incomingRequestProvider;
  late final IncomingPaymentRequestProvider incomingPaymentRequestProvider;

  static String apiUrl = dotenv.env['API_BASE_URL']!;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    activeUser = Provider.of<UserProvider>(context, listen: false).activeUser;
    incomingRequestProvider = Provider.of<IncomingRequestProvider>(context,listen: false);
    incomingPaymentRequestProvider = Provider.of<IncomingPaymentRequestProvider>(context,listen: false);
    fetchRequests();

    socket = IO.io(apiUrl, <String, dynamic>{ 
      'transports': ['websocket'],
    });

    socket.on('transactionRequest', (data) {
      Transaction transaction =
          Transaction.fromJson(Map<String, dynamic>.from(data['transaction']));
        setState(() {
          incomingRequestProvider.addRequest(transaction);
          requestTransactions=incomingRequestProvider.allTransactions;
        });
    });
  }

  handleUpdateUser(){
    setState(() {
      if(shouldUpdate==false){
        incomingRequestProvider.setAllRequests(requestTransactions);
        requestTransactions=incomingRequestProvider.allTransactions;

        incomingPaymentRequestProvider.setAllRequests(paymentrequestTransactions);
        paymentrequestTransactions=incomingPaymentRequestProvider.allTransactions;
      }else{
        requestTransactions=incomingRequestProvider.allTransactions;
        paymentrequestTransactions=incomingPaymentRequestProvider.allTransactions;
      }
      saveRequestsToPrefs('${activeUser.email}/requestTransactions', requestTransactions);
      saveRequestsToPrefs('${activeUser.email}/paymentrequestTransactions', paymentrequestTransactions);
    });
  }

  Future<void> fetchRequests() async {
    try {
      prefs = await SharedPreferences.getInstance();

      final List<String>? requestTransactionsString = prefs.getStringList('${activeUser.email}/requestTransactions');
      if (requestTransactionsString != null) {
        requestTransactions = requestTransactionsString.map((requestString) => Transaction.fromJson(jsonDecode(requestString))).toList();

        if(incomingRequestProvider.allTransactions!=requestTransactions){
          handleUpdateUser();
        }
      }else{
        await fetchRequestTransactionsFromAPI();
      }

      final List<String>? paymentrequestTransactionsString = prefs.getStringList('${activeUser.email}/paymentrequestTransactions');
      if (paymentrequestTransactionsString != null) {
        paymentrequestTransactions = paymentrequestTransactionsString.map((requestString) => subTransactions.fromJson(jsonDecode(requestString))).toList();

        if(incomingPaymentRequestProvider.allTransactions!=paymentrequestTransactions){
          handleUpdateUser();
        }
      }else{
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
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          leadingWidth: (screenWidth-searchBarWidth-12)/2,
          backgroundColor: Theme.of(context).colorScheme.surface, 
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface), 
          title: 
            Container(
              width: searchBarWidth,
              height: searchBarHeight,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(229, 229, 229, 1), 
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: TextStyle( 
                        fontSize: textMultiplier * 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search with email',
                        hintStyle: TextStyle(
                          fontSize: textMultiplier * 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7), 
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon:  Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.done, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          onPressed: handleSearch,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 7),
                        border: OutlineInputBorder( 
                          borderRadius: BorderRadius.circular(5), 
                          borderSide: BorderSide.none, 
                        ),
                        filled: true,       
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,                
                      ),
                      cursorColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(
                child: Text(
                  'Loan Requests',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Payment Requests',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
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

    return incomingRequestProvider.allTransactions.isEmpty
        ? const Center(child: Text('No loan requests available.',style: TextStyle(color: Colors.grey)))
        : ListView.builder(
              itemCount: incomingRequestProvider.allTransactions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 14,right: 14),
                  child: Container(
                    margin: const EdgeInsets.only(top: 7.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.surfaceVariant, 
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 1),
                        ),
                      ],                    
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
                                      incomingRequestProvider.allTransactions[index],fetchRequestTransactionsFromAPI:fetchRequestTransactionsFromAPI
                                ),
                              )
                            ).then((_) => setState(() {fetchRequests();shouldUpdate=true;}));                        
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12), 
                          decoration: BoxDecoration(
                            color: Colors.transparent, 
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: screenHeight * 0.07 * 0.75 * 0.5,
                                backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
                                child: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant, size: screenHeight * 0.07 * 0.75),
                              ),
                              SizedBox(width: 23*widthMultiplier), 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    incomingRequestProvider.allTransactions[index].receiver,
                                    style: TextStyle(fontSize: textMultiplier * 14, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    DateFormat('dd-MM-yyyy').format(incomingRequestProvider.allTransactions[index].startDate),
                                    style: TextStyle(fontSize: textMultiplier * 12, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7), fontWeight: FontWeight.w500),
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
        ? const Center(child: Text('No payment requests available.',style: TextStyle(color: Colors.grey)))
        : ListView.builder(
              itemCount: paymentrequestTransactions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 14,right: 14),
                  child: Container(
                     margin: const EdgeInsets.only(top: 14.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceVariant,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IncomingPaymentRequest(
                                  paymentrequestTransaction:
                                      paymentrequestTransactions[index],fetchPaymentRequestTransactionsFromAPI:fetchPaymentRequestTransactionsFromAPI
                                ),
                              ),
                            ).then((_) => setState(() {fetchRequests();shouldUpdate=true;}));                        
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12), 
                          decoration: BoxDecoration(
                            color: Colors.transparent, 
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: screenHeight * 0.07 * 0.75 * 0.5,
                                backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
                                child: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant, size: screenHeight * 0.07 * 0.75),
                              ),
                              SizedBox(width: 23*widthMultiplier), 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    paymentrequestTransactions[index].receiver,
                                    style: TextStyle(fontSize: textMultiplier * 14, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    DateFormat('dd-MM-yyyy').format(paymentrequestTransactions[index].date),
                                    style: TextStyle(fontSize: textMultiplier * 12, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7), fontWeight: FontWeight.w500),
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
