import 'package:flutter/material.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'api_helper.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Transaction> allTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final List<Transaction> transactions = await ApiHelper.fetchTransactions();
      setState(() {
        allTransactions = transactions;
      });
    } catch (e) {
      print(e);
      // Handle error and show a proper error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardHeight = MediaQuery.of(context).size.height * 0.25; // Card height

    double iconSize = cardHeight * 0.25; // Adjust the icon size proportionally

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0), // Add right padding to the notifications button
            child: IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Handle notifications button click
              },
            ),
          ),
        ],
        backgroundColor: Colors.black, // Black background for the top bar
        leading: Padding(
          padding: EdgeInsets.only(left: 20.0), // Add left padding to the logout button
          child: IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle logout button click
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
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Card(
                    color: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Add border radius
                    ), // Orange color for the card
                    child: SizedBox(
                      width: double.infinity,
                      height: cardHeight,
                      child: Center(
                        child: Text("Your Card Content"),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround, 
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Color(0xFF2E2E2E),
                              borderRadius: BorderRadius.circular(iconSize / 2),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.request_page, color: Color(0xFF999999), size: iconSize * 0.6),
                              onPressed: () {
                                // Handle Transfer Money button click
                              },
                            ),
                          ),
                          SizedBox(height: 1.0), 
                          Text("Request", style: TextStyle(color: Colors.white,fontSize: iconSize * 0.25,)), 
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Color(0xFF2E2E2E),
                              borderRadius: BorderRadius.circular(iconSize / 2),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.attach_money, color: Color(0xFF999999), size: iconSize * 0.6),
                              onPressed: () {
                                // Handle Transfer Money button click
                              },
                            ),
                          ),
                          SizedBox(height: 1.0), 
                          Text("Transfer", style: TextStyle(color: Colors.white,fontSize: iconSize * 0.25)), 
                        ],
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          Expanded(
            child: allTransactions.isEmpty
                ? Center(child: Text('No transactions available.'))
                : ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0), // Top left corner
                    topRight: Radius.circular(24.0), // Top right corner
                  ),
                  child: Container(
                    color: Colors.white, // Set the background color to white
                    child: ListView.builder(
                      itemCount: allTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = allTransactions[index];

                        final transactionDate = transaction.date;
                        String formattedDate;
                        final now = DateTime.now();

                        if (transactionDate.year == now.year &&
                            transactionDate.month == now.month &&
                            transactionDate.day == now.day) {
                          // Show time in 12hr format along with the date if it's today
                          formattedDate = DateFormat('d MMM h:mm a').format(transactionDate);
                        } else if (transactionDate.year == now.year &&
                            transactionDate.month == now.month &&
                            transactionDate.day == now.day - 1) {
                          // Show "Yesterday" along with the time if it's yesterday
                          formattedDate = 'Yesterday ' + DateFormat.jm().format(transactionDate);
                        } else if (transactionDate.year == now.year) {
                          // Show date in the format "day Month" along with the time if it's this year
                          formattedDate = DateFormat('d MMM').format(transactionDate) +
                              ' ' +
                              DateFormat.jm().format(transactionDate);
                        } else {
                          // Show date in the format "day Month Year" along with the time
                          formattedDate = DateFormat('d MMM y').format(transactionDate) +
                              ' ' +
                              DateFormat.jm().format(transactionDate);
                        }
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(transaction.receiver), 
                              subtitle: Row(
                                children: [
                                  Text(formattedDate), 
                                ],
                              ),
                              trailing: Text(transaction.amount.toString()), 
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          )
        ],
      ),
    );
  }
}
