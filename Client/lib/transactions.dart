import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Providers/requestUsers_provider.dart';
import 'package:lendpay/Providers/transactionsUser_provider.dart';
import 'package:lendpay/Widgets/error_dialog.dart';
import 'package:lendpay/agreementPage.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/singleAgreementPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionsPage extends StatefulWidget {
  final User otheruser;
  final User activeuser;

  TransactionsPage({required this.otheruser,required this.activeuser});
  

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<TransactionsPage> {
  TextEditingController messageController = TextEditingController();

  List<Transaction> allTransactionsUser = [];
  late SharedPreferences prefs;

  late final TransactionsUser transactionsUserProvider;

  bool isLoading = true;
  bool isManual = false;
  bool isCredit =true;
  bool isEmpty = true;
  bool shouldUpdate=false;

  String? currencySymbol;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    setState(() {
      isManual=!widget.otheruser.fCMToken.contains((widget.activeuser.id))?false:true;
    });
    messageController.addListener(updateSendButtonState);
    transactionsUserProvider = Provider.of<TransactionsUser>(context,listen: false);
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    currencySymbol = prefs.getString('${widget.activeuser.email}/currencySymbol');
    setState(() {}); 
  }

  void updateSendButtonState(){
    setState(() {
      isEmpty=messageController.text.isEmpty;
    });
  }

  handleUpdateTransactions(){
    setState(() {
      if(shouldUpdate==false){
        transactionsUserProvider.setAllTransactionUsers(allTransactionsUser);
        allTransactionsUser=transactionsUserProvider.allTransactionsUser;
      }else{
        allTransactionsUser=transactionsUserProvider.allTransactionsUser;
      }
      saveTransactionsToPrefs();
    });
  }

  Future<void> _fetchTransactions() async {
    try {
      prefs = await SharedPreferences.getInstance();
      List<String>? transactionsString = prefs.getStringList('${widget.activeuser.email}/${widget.otheruser.email??widget.otheruser.name}/transactions');

      if (transactionsString != null) {
          transactionsString = prefs.getStringList('${widget.activeuser.email}/${widget.otheruser.email??widget.otheruser.name}/transactions');
          allTransactionsUser = transactionsString!.map((transactionString) =>Transaction.fromJson(jsonDecode(transactionString))).toList();
          if(transactionsUserProvider.allTransactionsUser!=allTransactionsUser){
            handleUpdateTransactions();
          }
      }
      else{
        await fetchTransactionsFromAPI();
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

  Future<void> fetchTransactionsFromAPI() async {
    try {
      List<Transaction> fetchedTransactions = [];

      if(!isManual){
        fetchedTransactions = await ApiHelper.fetchUserTransactions(widget.otheruser.email!);
        setState(() {
          transactionsUserProvider.setAllTransactionUsers(fetchedTransactions);
          allTransactionsUser = fetchedTransactions;
        });
      }else{
        fetchedTransactions = await ApiHelper.fetchManualUserTransactions(widget.otheruser.name);
        setState(() {
          transactionsUserProvider.setAllTransactionUsers(fetchedTransactions);
          allTransactionsUser = fetchedTransactions;
        });
        saveTransactionsToPrefs();
      }
    } catch (e) {
      ErrorDialogWidget.show(context, "Error fetching transactions from API");
      print(e);
    }
  }

  Future<void> saveTransactionsToPrefs() async {
    final List<String> transactionsString = allTransactionsUser
        .map((transaction) => jsonEncode(transaction.toJson()))
        .toList();

    await prefs.setStringList('${widget.activeuser.email}/${widget.otheruser.email??widget.otheruser.name}/transactions', transactionsString);
  }

  Future<void> _deleteUser(String userId, BuildContext context) async {
    final requestUsersProvider = Provider.of<RequestUsersProvider>(context,listen: false);
    
    try { 
      final deletedUser= await ApiHelper.deleteUser(userId);
      requestUsersProvider.deleteUser(deletedUser); 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
        ),
      );
      Navigator.pop(context,true);
    } catch (error) {
      print('Error deleting user: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete user. Please try again.'),
        ),
      );
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
        title: Container(
            decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, 
            borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: screenHeight * 0.07 * 0.75 * 0.5,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant, 
                  child: Icon(Icons.person,color: Theme.of(context).colorScheme.onSurfaceVariant, size: screenHeight * 0.07 * 0.75),
                ),
                SizedBox(width: 23 * widthMultiplier),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.otheruser.name,
                      style: TextStyle(fontSize: textMultiplier * 14, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      widget.otheruser.email??'',
                      style: TextStyle(fontSize: textMultiplier * 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),        
        backgroundColor: Theme.of(context).colorScheme.background,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        
        actions: [
          isManual==true?
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteUser(widget.otheruser.id, context);
              }
            },
            color:  Theme.of(context).colorScheme.surface, 
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Container(
                    width: 112, 
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), 
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 24, color: Theme.of(context).colorScheme.error), 
                        const SizedBox(width: 12), 
                        Expanded(
                          child: Text(
                            'Delete',
                            textAlign: TextAlign.start, 
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onError 
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
          ):const SizedBox(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: allTransactionsUser.length,
              reverse: true,
              itemBuilder: (context, index) {
                final transaction = allTransactionsUser[index];
                return buildTransactionItem(transaction);
              },
            ),
          ),
          Container(
            width: searchBarWidth,
            height: searchBarHeight,
            margin: const EdgeInsets.only(bottom: 10), 
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant, 
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // const SizedBox(width: 8), 
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: TextStyle(
                      fontSize: textMultiplier * 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      hintStyle: TextStyle(
                        fontSize: textMultiplier * 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7), 
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: widget.otheruser.fCMToken.contains(widget.otheruser.name)?IconButton(
                        icon: isCredit 
                          ? const Icon(Icons.add_circle_outline_outlined, color: Colors.green)
                          : const Icon(Icons.remove_circle_outline_outlined, color: Colors.red),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title: const Text('Credit'),
                                      onTap: () {
                                        Navigator.pop(context, true); 
                                      },
                                    ),
                                    ListTile(
                                      title: const Text('Debit'),
                                      onTap: () {
                                        Navigator.pop(context, false); 
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).then((value) {
                            if (value != null) {
                              setState(() {
                                isCredit = value; 
                              });
                              // print(value);
                            }
                          });
                        },
                      ):null,
                    suffixIcon: IgnorePointer(
                      ignoring: isEmpty,
                      child: Opacity(
                        opacity: !isEmpty ? 1.0 : 0.5,
                        child:Container(
                          padding: const EdgeInsets.all(4.0), 
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(50), 
                          ),                       
                          child: IconButton(
                            icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AgreementPage(amount: int.parse(messageController.text), otheruser: widget.otheruser, fetchTransactionsFromAPI: fetchTransactionsFromAPI,isCredit: isCredit)));
                            },
                          ),
                        )
                      ),
                    ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8), 
                      border: InputBorder.none,
                    ),
                    cursorColor: Theme.of(context).colorScheme.onSurfaceVariant, 
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTransactionItem(Transaction transaction) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleAgreementPage(viewAgreement:transaction))).then((_) => setState(() {_fetchTransactions();shouldUpdate=true;}));
      },
      child: Align(
        alignment: transaction.sender==widget.activeuser.email ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7, 
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: transaction.isCredit ? Colors.green[400] : Colors.blue[400],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${transaction.type=="req" ? "Request":(transaction.isCredit ? "Credit" : "Debit")}: $currencySymbol${transaction.amount}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 1.0,
                  color: Theme.of(context).colorScheme.background,
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Note: ${transaction.note}',
                        style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(transaction.time),
                      style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
