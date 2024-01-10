import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/incomingRequest.dart';

class IncomingRequestPage extends StatefulWidget{

  @override
  _IncomingRequestPageState createState() => _IncomingRequestPageState();
}

class _IncomingRequestPageState extends State<IncomingRequestPage>{

TextEditingController searchController = TextEditingController();

  List<Transaction> requestTransactions = [];

  bool foundUser = false;

  late String username;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  void handleSearch(){
    setState(() {
      username=searchController.text;
    });
    // print(username);
  }

  Future<void> fetchRequests() async{
    try {
      final List<Transaction> requests = await ApiHelper.fetchUserRequests();
      setState(() {
        requestTransactions=requests;
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
  double cardHeight = MediaQuery.of(context).size.height * 0.25; // Card height
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
    body: requestTransactions.isEmpty
        ? Center(child: Text('No requests available.'))
        : ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0), // Top left corner
              topRight: Radius.circular(24.0), // Top right corner
            ),
            child: Container(
              color: Colors.white, // Set the background color to white
              child: ListView.builder(
                itemCount: requestTransactions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        height: insideCardHeight, // Set the individual card's height
                        child: ListTile(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>IncomingRequest(requestTransaction: requestTransactions[index])));
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.person, color: Colors.white, size: insideCardHeight * 0.75),
                          ),
                          title: Text(
                            requestTransactions[index].receiver,
                            style: TextStyle(fontSize: insideCardHeight * 0.325),
                          ),
                          subtitle: Row(
                            children: [
                              Text(DateFormat('dd-MM-yyyy').format(requestTransactions[index].startDate),style: TextStyle(fontSize: insideCardHeight * 0.225)),
                            ],
                          ),
                          trailing: Icon(Icons.more_vert, color: const Color.fromARGB(255, 0, 0, 0), size: insideCardHeight * 0.5),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
    );
  }
}