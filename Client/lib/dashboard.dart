import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
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
            height: MediaQuery.of(context).size.height * 0.365, // Divide the height in half
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround, // Center the buttons vertically
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        width: iconSize, // Set the width proportionally
                        height: iconSize, // Set the height proportionally
                        decoration: BoxDecoration(
                          color: Color(0xFF2E2E2E), // RGB(46,46,46) for the background
                          borderRadius: BorderRadius.circular(iconSize / 2), // Adjust border radius
                        ),
                        child: IconButton(
                          icon: Icon(Icons.request_page, color: Color(0xFF999999), size: iconSize * 0.6), // Adjust icon size
                          onPressed: () {
                            // Handle Request Money button click
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        width: iconSize, // Set the width proportionally
                        height: iconSize, // Set the height proportionally
                        decoration: BoxDecoration(
                          color: Color(0xFF2E2E2E), // RGB(46,46,46) for the background
                          borderRadius: BorderRadius.circular(iconSize / 2), // Adjust border radius
                        ),
                        child: IconButton(
                          icon: Icon(Icons.attach_money, color: Color(0xFF999999), size: iconSize * 0.6), // Adjust icon size
                          onPressed: () {
                            // Handle Transfer Money button click
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), // Top left corner
                  topRight: Radius.circular(24), // Top right corner
                ),
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 20, top: 10),
                    child: Center(
                      child: Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 18, // Adjust the font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Add your card items here
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Add border radius
                      ),
                      child: ListTile(
                        leading: CircleAvatar( // Circular icon on the left
                          backgroundColor: Colors.orange, // Color for the circular icon
                          child: Icon(Icons.person, color: Colors.white), // Adjust icon size
                        ),
                        title: Text('Name'), // Name
                        subtitle: Row(
                          children: [
                            Text('Date'), // Date
                            SizedBox(width: 8.0), // Add some spacing
                            Text('Time'), // Time
                          ],
                        ),
                        trailing: Text('Amount'), // Amount on the right
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Add border radius
                      ),
                      child: ListTile(
                        leading: CircleAvatar( // Circular icon on the left
                          backgroundColor: Colors.orange, // Color for the circular icon
                          child: Icon(Icons.person, color: Colors.white), // Adjust icon size
                        ),
                        title: Text('Name'), // Name
                        subtitle: Row(
                          children: [
                            Text('Date'), // Date
                            SizedBox(width: 8.0), // Add some spacing
                            Text('Time'), // Time
                          ],
                        ),
                        trailing: Text('Amount'), // Amount on the right
                      ),
                    ),
                  ),
                  // Add more card items as needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
