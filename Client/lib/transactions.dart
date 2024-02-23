import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Widgets/error_dialog.dart';
import 'package:lendpay/agreementPage.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/singleAgreementPage.dart';
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

  bool isLoading = true;
  bool isManual = false;
  bool isCredit =true;
  bool isEmpty = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    setState(() {
      isManual=!widget.otheruser.fCMToken.contains((widget.otheruser.name))?false:true;
    });
    messageController.addListener(updateSendButtonState);
  }

  void updateSendButtonState(){
    setState(() {
      isEmpty=messageController.text.isEmpty;
    });
  }

  Future<void> _fetchTransactions() async {
    try {
      prefs = await SharedPreferences.getInstance();
      final List<String>? transactionsString =
          prefs.getStringList('${widget.activeuser.email}/${widget.otheruser.email}/transactions');

      if (transactionsString != null) {
        allTransactionsUser = transactionsString
            .map((transactionString) =>
                Transaction.fromJson(jsonDecode(transactionString)))
            .toList();
      }

      if (allTransactionsUser.isEmpty) {
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
        fetchedTransactions = await ApiHelper.fetchUserTransactions(widget.otheruser.email);
      }else{
        fetchedTransactions = await ApiHelper.fetchManualUserTransactions(widget.otheruser.name);
      }

      setState(() {
        allTransactionsUser = fetchedTransactions;
      });

      saveTransactionsToPrefs();
    } catch (e) {
      ErrorDialogWidget.show(context, "Error fetching transactions from API");
      print(e);
    }
  }

  Future<void> saveTransactionsToPrefs() async {
    final List<String> transactionsString = allTransactionsUser
        .map((transaction) => jsonEncode(transaction.toJson()))
        .toList();

    await prefs.setStringList('${widget.activeuser.email}/${widget.otheruser.email}/transactions', transactionsString);
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await ApiHelper.deleteUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
        ),
      );
      Navigator.of(context).pop();
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
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        title: Container(
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
                SizedBox(width: 23 * widthMultiplier),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.otheruser.name,
                      style: TextStyle(fontSize: textMultiplier * 14, color: const Color.fromRGBO(0, 0, 0, 1), fontWeight: FontWeight.w500),
                    ),
                    Text(
                      widget.otheruser.email,
                      style: TextStyle(fontSize: textMultiplier * 12, color: const Color.fromRGBO(107, 114, 120, 1), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),        
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteUser(widget.otheruser.id);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Container(
                    width: 112, 
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), 
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 24), 
                        SizedBox(width: 12), 
                        Expanded(
                          child: Text(
                            'Delete',
                            textAlign: TextAlign.start, 
                            style: TextStyle(
                              fontSize: 16, 
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
          ),

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
              color: const Color.fromRGBO(229, 229, 229, 1),
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
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      hintStyle: TextStyle(
                        fontSize: textMultiplier * 12,
                        color: const Color.fromRGBO(107, 114, 120, 1),
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: widget.otheruser.fCMToken.contains(widget.otheruser.name)?IconButton(
                        icon: isCredit 
                          ? Icon(Icons.add_circle_outline_outlined, color: Colors.green)
                          : Icon(Icons.remove_circle_outline_outlined, color: Colors.red),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text('Credit'),
                                      onTap: () {
                                        Navigator.pop(context, true); 
                                      },
                                    ),
                                    ListTile(
                                      title: Text('Debit'),
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
                            }
                          });
                        },
                      ):null,
                    suffixIcon: IgnorePointer(
                      ignoring: isEmpty,
                      child: Opacity(
                        opacity: !isEmpty ? 1.0 : 0.5,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Color.fromRGBO(0, 0, 0, 1)),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AgreementPage(amount: int.parse(messageController.text), otheruser: widget.otheruser, fetchTransactionsFromAPI: fetchTransactionsFromAPI,isCredit: isCredit)));
                          },
                        ),
                      ),
                    ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8), 
                      border: InputBorder.none,
                    ),
                    cursorColor: Colors.black,
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
    bool isCredit = transaction.receiver == (widget.otheruser.fCMToken.contains(widget.otheruser.name)?widget.otheruser.name:widget.otheruser.email);
    bool isReq = transaction.type == "req";

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleAgreementPage(viewAgreement:transaction)));
      },
      child: Align(
        alignment: isCredit ? Alignment.centerLeft : Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7, 
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: isCredit ? Colors.green : Colors.blue,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isReq ? "Request":(isCredit ? "Credit" : "Debit")}: \$${transaction.amount}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 1.0,
                  color: Colors.white, 
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Note: ${transaction.note}',
                        style: const TextStyle(fontSize: 16.0, color: Colors.white),
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
                      style: const TextStyle(fontSize: 12.0, color: Colors.white),
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
