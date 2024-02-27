import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Widgets/error_dialog.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/transactions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Request extends StatefulWidget{
  final User activeUser;

  Request({required this.activeUser});

  @override
  _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request>{

  TextEditingController searchController = TextEditingController();

  bool foundUser = false;
  late String username;
  bool isLoading = true; 

  List<User> users = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      prefs = await SharedPreferences.getInstance();
      final List<String>? usersString = prefs.getStringList('${widget.activeUser.email}/requestUsers');
      if (usersString != null) {
        users = usersString.map((userString) => User.fromJson(jsonDecode(userString))).toList();
      }
      if (users.isEmpty) {
        await fetchUsersFromAPI();
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorDialogWidget.show(context, "Error fetching users");
      print(e);
    }
  }

  Future<void> fetchUsersFromAPI() async {
    try {
      final List<User> fetchedUsers = await ApiHelper.fetchUsers();
      
      setState(() {
        users = fetchedUsers;
      });
      
      saveUsersToPrefs();
    } catch (e) {
      ErrorDialogWidget.show(context, "Error fetching users from API");
      print(e);
    }
  }

  Future<void> saveUsersToPrefs() async {
    final List<String> usersString = users.map((user) => jsonEncode(user.toJson())).toList();
    
    await prefs.setStringList('${widget.activeUser.email}/requestUsers', usersString);
  }


  void handleSearch(){
    setState(() {
      username=searchController.text;
    });
    // print(username);
    verifyUser();
  }

  Future<void> verifyUser() async {
    try {
      final User? searchedUser = await ApiHelper.verifyUser(username);
      if (searchedUser == null) {
        ErrorDialogWidget.show(context, "No user with that ID");
      } else {
        setState(() {
          bool userExists = users.any((user) => user.email == searchedUser.email);
          if (!userExists) {
            users.add(searchedUser);
            saveUsersToPrefs();
          } else {
            users.removeWhere((user) => user.email == searchedUser.email);
            users.add(searchedUser);
            saveUsersToPrefs();
          }
        });
      }
    } catch (e) {
      ErrorDialogWidget.show(context, "Error searching");
      print(e);
    }
  }

@override
Widget build(BuildContext context) {

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

  return Scaffold(
    backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
    appBar: AppBar(
      leadingWidth: (screenWidth-searchBarWidth-12)/2,
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
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
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search with email',
                    hintStyle: TextStyle(
                      fontSize: textMultiplier * 12,
                      color: const Color.fromRGBO(107, 114, 120, 1),
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Color.fromRGBO(0, 0, 0, 1)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.done, color: Color.fromRGBO(0, 0, 0, 1)),
                      onPressed: handleSearch,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 7),
                    border: InputBorder.none,
                  ),
                  cursorColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
    ),
    body: users.isEmpty
        ? const Center(child: Text('No Users available.'))
        : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final otheruser = users.elementAt(users.length-1-index);
                return Padding(
                  padding: EdgeInsets.only(left: 14,right: 14,bottom: 5*textMultiplier),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromRGBO(229, 229, 229, 0.3),
                    ),
                    child: SizedBox(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.9,
                      child:InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionsPage(otheruser: otheruser,activeuser: widget.activeUser,)));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12), 
                          decoration: BoxDecoration(
                            color: Colors.transparent, 
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: screenHeight * 0.07 * 0.75 * 0.5,
                                backgroundColor: const Color.fromRGBO(218, 218, 218, 1),
                                child: Icon(Icons.person, color: const Color.fromARGB(255, 0, 0, 0), size: screenHeight * 0.07 * 0.75),
                              ),
                              SizedBox(width: 23*widthMultiplier), 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    otheruser.name,
                                    style: TextStyle(fontSize: textMultiplier * 14, color: const Color.fromRGBO(0, 0, 0, 1), fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    otheruser.email??'',
                                    style: TextStyle(fontSize: textMultiplier * 12, color: const Color.fromRGBO(107, 114, 120, 1), fontWeight: FontWeight.w500),
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
            ),
          );
  }
}