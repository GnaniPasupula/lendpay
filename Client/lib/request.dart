import 'package:flutter/material.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Widgets/error_dialog.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/transactions.dart';

class Request extends StatefulWidget{
  @override
  _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request>{

  TextEditingController searchController = TextEditingController();

  List<User> searchedUsers = [];

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
    try{
      final User? searchedUser = await ApiHelper.verifyUser(username);
      setState(() {
        if(searchedUser==null){
          foundUser=false;
          ErrorDialogWidget.show(context,"No user with that ID");
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
      ErrorDialogWidget.show(context,"Error seaechiomg");
      print(e);
    }
  }

@override
Widget build(BuildContext context) {

  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  double cardHeight = screenHeight * 0.25; 
  double insideCardHeight = cardHeight / 3.25;

  // 375-260

  double searchBarWidth=(screenWidth/375)*260;
  double searchBarHeight=35;

  
  double textMultiplier = 1;
  double widthMultiplier = 1;
  // double textMultiplier = screenHeight/812;
  // double widthMultiplier = screenWidth/375;
  //H=812 , W=375

  return Scaffold(
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
    ),
    body: searchedUsers.isEmpty
        ? Center(child: Text('No Users available.'))
        : ListView.builder(
              itemCount: searchedUsers.length,
              itemBuilder: (context, index) {
                final otheruser = searchedUsers.elementAt(index);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(229, 229, 229, 0.3),
                    ),
                    child: SizedBox(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.9,
                      child:InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionsPage(otheruser: otheruser)));
                        },
                        child: Container(
                          height: screenHeight * 0.07,
                          width: screenWidth * 0.9,
                          padding: EdgeInsets.symmetric(horizontal: 12), 
                          decoration: BoxDecoration(
                            color: Colors.transparent, 
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: screenHeight * 0.07 * 0.75*0.5,
                                backgroundColor: Color.fromRGBO(218, 218, 218, 1),
                                child: Icon(Icons.person, color: const Color.fromARGB(255, 0, 0, 0), size: screenHeight * 0.07 * 0.75),
                              ),
                              SizedBox(width: 23*widthMultiplier), 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    otheruser.name,
                                    style: TextStyle(fontSize: textMultiplier * 14, color: Color.fromRGBO(0, 0, 0, 1), fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    otheruser.email,
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
            ),
          );
  }
}