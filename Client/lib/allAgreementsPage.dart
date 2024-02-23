import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Widgets/error_dialog.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/singleAgreementPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

class AllAgreementsPage extends StatefulWidget {
  final User activeUser;

  AllAgreementsPage({required this.activeUser});

  @override
  _AllAgreementsPageState createState() => _AllAgreementsPageState();
}

class _AllAgreementsPageState extends State<AllAgreementsPage> {

  List<Transaction> allTransactions = [];

  late SharedPreferences prefs;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllTransactions();
  }

  Future<void> _fetchAllTransactions() async {
    try {
      prefs = await SharedPreferences.getInstance();
      final List<String>? transactionsString =
          prefs.getStringList('${widget.activeUser.email}/alltransactions');

      if (transactionsString != null) {
        allTransactions = transactionsString
            .map((transactionString) =>
                Transaction.fromJson(jsonDecode(transactionString)))
            .toList();
      }

      if (allTransactions.isEmpty) {
        await fetchAllTransactionsFromAPI();
      }

      setState(() {
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorDialogWidget.show(context, "Error fetching transactions");
      print("Error: Fetching transaction details from local storage ${e}");
    }
  }


  Future<void> fetchAllTransactionsFromAPI() async {
    try {
      final List<Transaction> fetchedTransactions = await ApiHelper.fetchUserLoans();

      setState(() {
        allTransactions = fetchedTransactions;
      });

      saveTransactionsToPrefs();
    } catch (e) {
      ErrorDialogWidget.show(context, "Error fetching transactions from API");
      print(e);
    }
  }


  Future<void> saveTransactionsToPrefs() async {
    final List<String> transactionsString = allTransactions
        .map((transaction) => jsonEncode(transaction.toJson()))
        .toList();

    await prefs.setStringList('${widget.activeUser.email}/alltransactions', transactionsString);
  }

  TextEditingController searchController = TextEditingController();

  bool foundUser = false;

  late String username;

  void handleSearch(){
    setState(() {
      username=searchController.text;
    });
    // print(username);
    verifyUser();
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
        }
      }); 
    }catch(e){ 
      ErrorDialogWidget.show(context,"Error searching");
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
    body: allTransactions.isEmpty
        ? Center(child: Text('No Loans available.'))
        : ListView.builder(
              itemCount: allTransactions.length,
              itemBuilder: (context, index) {
                final otheruser = allTransactions.elementAt(allTransactions.length-1-index);
                return Padding(
                  padding: EdgeInsets.only(left: 14,right: 14,bottom: 5*textMultiplier),
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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleAgreementPage(viewAgreement:allTransactions[index])));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12), 
                          decoration: BoxDecoration(
                            color: Colors.transparent, 
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: screenHeight * 0.07 * 0.75 * 0.5,
                                backgroundColor: Color.fromRGBO(218, 218, 218, 1),
                                child: Icon(Icons.person, color: const Color.fromARGB(255, 0, 0, 0), size: screenHeight * 0.07 * 0.75),
                              ),
                              SizedBox(width: 23*widthMultiplier), 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    otheruser.sender,
                                    style: TextStyle(fontSize: textMultiplier * 14, color: Color.fromRGBO(0, 0, 0, 1), fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    otheruser.receiver,
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


