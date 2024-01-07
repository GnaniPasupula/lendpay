import 'package:flutter/material.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Providers/transaction_provider.dart';
import 'package:lendpay/Widgets/error_dialog.dart';
import 'package:lendpay/api_helper.dart';
import 'package:provider/provider.dart';

class AllAgreementsPage extends StatefulWidget {
  @override
  _AllAgreementsPageState createState() => _AllAgreementsPageState();
}

class _AllAgreementsPageState extends State<AllAgreementsPage> {

  List<Transaction> allTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final List<Transaction> transactions = await ApiHelper.fetchUserLoans();
      Provider.of<TransactionsProvider>(context, listen: false).setAllTransactions(transactions);
      setState(() {
        allTransactions=transactions;
      });
      // print('all transactions = ${allTransactions}');
    } catch (e) {
      print(e);
      // Handle error and show a proper error message to the user
    }
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
      ErrorDialogWidget.show(context,"Error seaechiomg");
      print(e);
    }
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
    body: allTransactions.isEmpty
        ? Center(child: Text('No Users available.'))
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
                  final otheruser = allTransactions.elementAt(index);

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
                            
                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionsPage(otheruser: otheruser)));
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.person, color: Colors.white, size: insideCardHeight * 0.75),
                          ),
                          title: Text(
                            otheruser.sender,
                            style: TextStyle(fontSize: insideCardHeight * 0.325),
                          ),
                          subtitle: Row(
                            children: [
                              Text(otheruser.sender, style: TextStyle(fontSize: insideCardHeight * 0.225)),
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


