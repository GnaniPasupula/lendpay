import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Providers/requestUsers_provider.dart';
import 'package:lendpay/Widgets/error_dialog.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/transactions.dart';
import 'package:provider/provider.dart';
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
  bool shouldUpdate=false;
  List<User> users = [];
  late SharedPreferences prefs;

  late final RequestUsersProvider requestUsersProvider;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    requestUsersProvider = Provider.of<RequestUsersProvider>(context,listen: false);
  }

  handleUpdateUser(){
    setState(() {
      if(shouldUpdate==false){
        requestUsersProvider.setAllRequestUsers(users);
      }else{
        users=requestUsersProvider.allrequestUser;
      }
      saveUsersToPrefs();
    });
  }

  Future<void> fetchUsers() async {
    try {
      prefs = await SharedPreferences.getInstance();
      List<String>? usersString= prefs.getStringList('${widget.activeUser.email}/requestUsers');
      if (usersString != null) {
        usersString= prefs.getStringList('${widget.activeUser.email}/requestUsers');
        users = usersString!.map((userString) => User.fromJson(jsonDecode(userString))).toList();
        if(requestUsersProvider.allrequestUser!=users){
          handleUpdateUser();
        }
      }
      else{
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
        requestUsersProvider.setAllRequestUsers(fetchedUsers);
        users=requestUsersProvider.allrequestUser;
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
    backgroundColor: Theme.of(context).colorScheme.background,
    appBar: AppBar(
      leadingWidth: (screenWidth-searchBarWidth-12)/2,
      backgroundColor: Theme.of(context).colorScheme.surface, 
      elevation: 0,
      title: 
        Container(
          width: searchBarWidth,
          height: searchBarHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
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
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    suffixIcon: IconButton(
                      icon:  Icon(Icons.done, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
    body: Consumer<RequestUsersProvider>(
        builder: (context, requestUsersProvider, child) {
          return users.isEmpty?Center(child: Text('No Users available.',style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7))))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final otheruser = users.elementAt(users.length-1-index);
                return Padding(
                  padding: EdgeInsets.only(left: 14,right: 14,bottom: 5*textMultiplier),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.7),
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
                        onTap: () async{
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionsPage(otheruser: otheruser,activeuser: widget.activeUser,))).then((_) => setState(() {fetchUsers();shouldUpdate=true;}));
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
                                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                                child: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant, size: screenHeight * 0.07 * 0.75),
                              ),
                              SizedBox(width: 23*widthMultiplier), 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    otheruser.name,
                                    style: TextStyle(fontSize: textMultiplier * 14, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                                  ),
                                  !otheruser.email!.contains(widget.activeUser.id)?
                                  Text(
                                    otheruser.email??'',
                                    style: TextStyle(fontSize: textMultiplier * 12, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                                  ):const SizedBox(),
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
      ) 
          );
  
  }
}