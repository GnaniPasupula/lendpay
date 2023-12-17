import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/api_helper.dart';

class Request extends StatefulWidget{
  @override
  _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request>{

  TextEditingController searchController = TextEditingController();

  List<User> searchedUsers = [];

  List<Transaction> allTransactionsUser=[];
  bool foundUser = false;

  late String username;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void handleSearch(){
    setState(() {
      username=searchController.text;
    });
    // print(username);
    verifyUser();
  }

  Future<void> _fetchTransactions() async {
    try {
      final List<Transaction> transactions = await ApiHelper.fetchUserTransactions(username);
      setState(() {
        allTransactionsUser = transactions;
      });
      print(allTransactionsUser);
    } catch (e) {
      print(e);
      // Handle error and show a proper error message to the user
    }
  }

  Future<void> fetchUsers() async{
    try {
      final List<User> users = await ApiHelper.fetchUsers();
      setState(() {
        searchedUsers=users;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> verifyUser() async{
    final User? searchedUser = await ApiHelper.verifyUser(username);
    try{
      setState(() {
        if(searchedUser==null){
          foundUser=false;
          _showErrorDialog("No user with that ID");
        }else{
          foundUser=true;
          bool userExists = searchedUsers.any((user) => user.email==searchedUser.email);

          if (!userExists) {
            searchedUsers.add(searchedUser);
          } else {
            searchedUsers.removeWhere((user) => user.email == searchedUser.email);
            searchedUsers.add(searchedUser);
          }
        }
      }); 
    }catch(e){ 
      _showErrorDialog("Error seaechiomg");
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
    body: searchedUsers.isEmpty
        ? Center(child: Text('No Users available.'))
        : ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), // Top left corner
              topRight: Radius.circular(24.0), // Top right corner
            ),
            child: Container(
              color: Colors.white, // Set the background color to white
              child: ListView.builder(
                itemCount: searchedUsers.length,
                itemBuilder: (context, index) {
                  final user = searchedUsers.elementAt(index);

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        height: insideCardHeight, // Set the individual card's height
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.person, color: Colors.white, size: insideCardHeight * 0.75),
                          ),
                          title: Text(
                            "User name",
                            style: TextStyle(fontSize: insideCardHeight * 0.325),
                          ),
                          subtitle: Row(
                            children: [
                              Text("UID", style: TextStyle(fontSize: insideCardHeight * 0.225)),
                            ],
                          ),
                          trailing: Text("Three dot icon", style: TextStyle(fontSize: insideCardHeight * 0.3)),
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