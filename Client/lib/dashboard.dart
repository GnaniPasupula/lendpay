import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lendpay/API/firebase_api.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/Providers/fCMToken_provider.dart';
import 'package:lendpay/Providers/subTransaction_provider.dart';
import 'package:lendpay/addUserPage.dart';
import 'package:lendpay/allAgreementsPage.dart';
import 'package:lendpay/incomingRequestPage.dart';
import 'package:lendpay/profilePage.dart';
import 'package:lendpay/singleAgreementPage.dart';
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

  Transaction? urgentTransaction;
  late User activeUserx;

  @override
  void initState() {
    super.initState();
    _fetchUrgentPayment();
    _fetchTransactions();
    _getActiveUser();
  }

  Future<void> _fetchTransactions() async {
    try {
      final List<subTransactions> transactions =
          await ApiHelper.fetchSubTransactions();
      Provider.of<SubtransactionsProvider>(context, listen: false)
          .setAllSubTransactions(transactions);
      setState(() {
        allsubTransactions = transactions;
      });
      // print('all transactions = ${allTransactions}');
    } catch (e) {
      print(e);
      // Handle error and show a proper error message to the user
    }
  }

  Future<void> _fetchUrgentPayment() async {
    try {
      Transaction? transaction = await ApiHelper.getUrgentTransaction();
      setState(() {
        urgentTransaction = transaction;
      });
      // print('all transactions = ${allTransactions}');
    } catch (e) {
      print(e);
      // Handle error and show a proper error message to the user
    }
  }

  Future<void> _getActiveUser() async {
    try {
      final User activeUser = await ApiHelper.getActiveUser();
      Provider.of<UserProvider>(context, listen: false)
          .setActiveUser(activeUser);
      setState(() {
        activeUserx = activeUser;
        _getfCMToken();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getfCMToken() async {
    try {
      String? fCMToken = await FirebaseApi().getfCMToken();
      Provider.of<FCMTokenProvider>(context, listen: false)
          .setfCMToken(fCMToken!);
      await ApiHelper.storeFCMToken(
          activeUserx.email, fCMToken);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
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

    double cardHeight =
        MediaQuery.of(context).size.height * 0.25; // Card height
    double iconSize = cardHeight * 0.25; // Adjust the icon size proportionally

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right: 0.0), // Add right padding to the notifications button
            child: IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => IncomingRequestPage()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 10.0), // Add right padding to the notifications button
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ),
        ],
        backgroundColor: Colors.black, // Black background for the top bar
        leading: Padding(
          padding: const EdgeInsets.only(
              left: 10.0), // Add left padding to the logout button
          child: IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height * 0.40,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 14, right: 14, bottom: 7),
                  child: Card(
                    color: const Color.fromRGBO(229, 229, 229, 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: urgentTransaction == null
                        ? SizedBox(
                            width: double.infinity,
                            height: cardHeight,
                            child: const Center(
                              child: Text("No payments"),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.all(14.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: cardHeight,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Amount to pay",
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              urgentTransaction?.subAmount
                                                      .toString() ??
                                                  '',
                                              style: const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Days remaining",
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              urgentTransaction?.endDate
                                                      .difference(
                                                          urgentTransaction!
                                                              .startDate)
                                                      .inDays
                                                      .toString() ??
                                                  '',
                                              style: const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "To",
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            urgentTransaction?.receiver ?? '',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if(urgentTransaction!=null)              
                                        ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                            ),
                                            onPressed: () => {
                                              Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleAgreementPage(viewAgreement:urgentTransaction!)))
                                            },
                                            child: Text("Details")
                                        )
                                    ],
                                  )
                                ],
                              ),
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
                              icon: Icon(Icons.contacts,
                                  color: const Color(0xFF999999),
                                  size: iconSize * 0.6),
                              onPressed: () {
                                // Handle Transfer Money button click
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Request(activeUser: activeUserx)));
                              },
                            ),
                          ),
                          const SizedBox(height: 1.0),
                          Text("Contacts",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: iconSize * 0.25,
                              )),
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
                              icon: Icon(Icons.handshake,
                                  color: const Color(0xFF999999),
                                  size: iconSize * 0.6),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AllAgreementsPage(
                                            activeUser: activeUserx)));
                              },
                            ),
                          ),
                          const SizedBox(height: 1.0),
                          Text("Loans",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: iconSize * 0.25,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
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
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            child: Container(
                              margin: const EdgeInsets.only(top: 14.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromRGBO(229, 229, 229, 0.3),
                              ),
                              child: SizedBox(
                                height: screenHeight * 0.07,
                                width: screenWidth * 0.9,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SingleTransactionsPage(
                                                    subTransaction:
                                                        subTransaction)));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius:
                                              screenHeight * 0.07 * 0.75 * 0.5,
                                          backgroundColor: const Color.fromRGBO(
                                              218, 218, 218, 1),
                                          child: Icon(Icons.person,
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              size: screenHeight * 0.07 * 0.75),
                                        ),
                                        SizedBox(width: 23 * widthMultiplier),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    subTransaction.sender,
                                                    style: TextStyle(
                                                        fontSize:
                                                            textMultiplier * 14,
                                                        color: const Color
                                                            .fromRGBO(
                                                            0, 0, 0, 1),
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Text(
                                                    DateFormat('dd-MM-yyyy')
                                                        .format(subTransaction
                                                            .date),
                                                    style: TextStyle(
                                                        fontSize:
                                                            textMultiplier * 12,
                                                        color: const Color
                                                            .fromRGBO(
                                                            107, 114, 120, 1),
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                subTransaction.amount
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize:
                                                        textMultiplier * 16,
                                                    color: const Color.fromRGBO(
                                                        0, 0, 0, 1),
                                                    fontWeight:
                                                        FontWeight.w600),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddUserDialog();
            },
          );
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
