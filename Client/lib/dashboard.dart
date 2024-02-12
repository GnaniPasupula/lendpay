import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lendpay/API/firebase_api.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/Providers/fCMToken_provider.dart';
import 'package:lendpay/Providers/subTransaction_provider.dart';
import 'package:lendpay/allAgreementsPage.dart';
import 'package:lendpay/incomingRequestPage.dart';
import 'package:lendpay/profilePage.dart';
import 'package:lendpay/singleTransaction.dart';
import 'package:provider/provider.dart';
import 'api_helper.dart';
import 'package:intl/intl.dart';
import 'request.dart';

class Dashboard extends StatefulWidget {

  const Dashboard();
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<subTransactions> allsubTransactions = [];

  late User activeUserx;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _getActiveUser();
  }

  Future<void> _fetchTransactions() async {
    try {
      final List<subTransactions> transactions = await ApiHelper.fetchSubTransactions();
      Provider.of<SubtransactionsProvider>(context, listen: false).setAllSubTransactions(transactions);
      setState(() {
        allsubTransactions=transactions;
      });
      // print('all transactions = ${allTransactions}');
    } catch (e) {
      print(e);
      // Handle error and show a proper error message to the user
    }
  }

  Future<void> _getActiveUser() async{
    try{
      final User activeUser = await ApiHelper.getActiveUser();
      Provider.of<UserProvider>(context,listen: false).setActiveUser(activeUser);
      setState(() {
        activeUserx=activeUser;
        _getfCMToken();
      });
    }catch(e){
      print(e);
    }
  }

  Future<void> _getfCMToken() async{
    try{
      String? fCMToken = await FirebaseApi().getfCMToken();
      Provider.of<FCMTokenProvider>(context,listen: false).setfCMToken(fCMToken!);
      await ApiHelper.storeFCMToken(activeUserx.email, fCMToken);
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardHeight = MediaQuery.of(context).size.height * 0.25; // Card height
    double insideCardHeight=cardHeight/3.25;
    double iconSize = cardHeight * 0.25; // Adjust the icon size proportionally

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 0.0), // Add right padding to the notifications button
            child: IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>IncomingRequestPage()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0), // Add right padding to the notifications button
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {

              },
            ),
          ),
        ],
        backgroundColor: Colors.black, // Black background for the top bar
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0), // Add left padding to the logout button
          child: IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
            },
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            color: Colors.black, // Black background for the top section
            height: MediaQuery.of(context).size.height * 0.38, // Divide the height in half
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Card(
                    color: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Add border radius
                    ), // Orange color for the card
                    child: SizedBox(
                      width: double.infinity,
                      height: cardHeight,
                      child: const Center(
                        child: Text("Your Card Content"),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround, 
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E2E2E),
                              borderRadius: BorderRadius.circular(iconSize / 2),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.request_page, color: const Color(0xFF999999), size: iconSize * 0.6),
                              onPressed: () {
                                // Handle Transfer Money button click
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Request(activeUser:activeUserx)));
                              },
                            ),
                          ),
                          const SizedBox(height: 1.0), 
                          Text("Request", style: TextStyle(color: Colors.white,fontSize: iconSize * 0.25,)), 
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E2E2E),
                              borderRadius: BorderRadius.circular(iconSize / 2),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.handshake, color: const Color(0xFF999999), size: iconSize * 0.6),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>AllAgreementsPage(activeUser:activeUserx)));
                              },
                            ),
                          ),
                          const SizedBox(height: 1.0), 
                          Text("Loans", style: TextStyle(color: Colors.white,fontSize: iconSize * 0.25,)), 
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 10)),
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
}
