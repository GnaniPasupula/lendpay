import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lendpay/API/firebase_api.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/Providers/fCMToken_provider.dart';
import 'package:lendpay/Providers/incomingPaymentRequest_provider.dart';
import 'package:lendpay/Providers/incomingRequest_provider.dart';
import 'package:lendpay/Providers/subTransaction_provider.dart';
import 'package:lendpay/Providers/urgentTransactions_provider.dart';
import 'package:lendpay/Widgets/error_dialog.dart';
import 'package:lendpay/addUserPage.dart';
import 'package:lendpay/allAgreementsPage.dart';
import 'package:lendpay/incomingRequestPage.dart';
import 'package:lendpay/profilePage.dart';
import 'package:lendpay/singleAgreementPage.dart';
import 'package:lendpay/singleTransaction.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_helper.dart';
import 'package:intl/intl.dart';
import 'request.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Dashboard extends StatefulWidget {
  const Dashboard();
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<subTransactions> allsubTransactions = [];
  List<Transaction> allUrgentTransactions= [];
  DateTime? adjustedEndDate;
  late User activeUserx;
  late SharedPreferences prefs;

  late final SubtransactionsProvider subtransactionsProvider;
  late final UrgentTransactionProvider urgentTransactionProvider;
  late final IncomingRequestProvider incomingRequestProvider;
  late final IncomingPaymentRequestProvider incomingPaymentRequestProvider;

  bool shouldUpdate=false;

  late IO.Socket socket;
  
  static String apiUrl = dotenv.env['API_BASE_URL']!;

  @override
  void initState() {
    super.initState();
    _getActiveUser();
    subtransactionsProvider = Provider.of<SubtransactionsProvider>(context,listen: false);
    urgentTransactionProvider =  Provider.of<UrgentTransactionProvider>(context,listen: false);
    incomingRequestProvider = Provider.of<IncomingRequestProvider>(context,listen: false);
    incomingPaymentRequestProvider = Provider.of<IncomingPaymentRequestProvider>(context,listen: false);
  }

  Future<void> _getActiveUser() async {
    try {
      final User activeUser = await ApiHelper.getActiveUser();
      Provider.of<UserProvider>(context, listen: false).setActiveUser(activeUser);
      setState(() {
        activeUserx = activeUser;
        _fetchSubTransactions();
        _fetchUrgentPayment();
        _getfCMToken();
      });
    } catch (e) {
      print(e);
    } finally{
      _initializeSocket();
    }
  }

  void _initializeSocket(){

    socket = IO.io(apiUrl, <String, dynamic>{ 
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      socket.emit('joinRoom', activeUserx.email);
      print('Connected to server');
    });

    socket.on('transactionRequest', (data) {
      Transaction transaction =
          Transaction.fromJson(Map<String, dynamic>.from(data['transaction']));
        setState(() {
            incomingRequestProvider.addRequest(transaction);         
        });
    });

    socket.on('transactionPaymentRequest', (data) {
      subTransactions subtransaction =
          subTransactions.fromJson(Map<String, dynamic>.from(data['subTransaction']));
        setState(() {
            incomingPaymentRequestProvider.addPaymentRequest(subtransaction);         
        });
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });

  }

  handleUpdateEmergency(){
    setState(() {
      if(shouldUpdate==false){
        urgentTransactionProvider.setAllSubTransactions(allUrgentTransactions);
        allUrgentTransactions=urgentTransactionProvider.allUrgentTransactions;
      }else{
        allUrgentTransactions=urgentTransactionProvider.allUrgentTransactions;
      }
      _saveUrgentTransactionsToPrefs();
    });
  }

  handleUpdateSubTransactions(){
    setState(() {
      if(shouldUpdate==false){
        subtransactionsProvider.setAllSubTransactions(allsubTransactions);
        allsubTransactions=subtransactionsProvider.allSubTransactions;
      }else{
        allsubTransactions=subtransactionsProvider.allSubTransactions;
      }
      _saveTransactionsToPrefs();
    });
  }

  Future<void> _fetchSubTransactions() async {
    try {
      prefs = await SharedPreferences.getInstance();

      List<String>? transactionsString = prefs.getStringList('${activeUserx.email}/subTransactions');
      if (transactionsString != null) {
        transactionsString = prefs.getStringList('${activeUserx.email}/subTransactions');
        allsubTransactions=transactionsString!.map((transactionString) =>subTransactions.fromJson(jsonDecode(transactionString))).toList();
        if(allsubTransactions!=subtransactionsProvider.allSubTransactions){
          handleUpdateSubTransactions();
        }
      }
      else{
        await fetchSubTransactionsFromAPI();
      }

    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchSubTransactionsFromAPI() async {
    try {
      final List<subTransactions> fetchedSubTransactions= await ApiHelper.fetchSubTransactions();
      
      setState(() {
        subtransactionsProvider.setAllSubTransactions(fetchedSubTransactions);
        allsubTransactions=fetchedSubTransactions;
      });
      
      _saveTransactionsToPrefs();
    } catch (e) {
      ErrorDialogWidget.show(context, "Error fetching subtransactions from API");
      print(e);
    }
  }

  Future<void> _saveTransactionsToPrefs() async {
    final List<String> transactionsString = allsubTransactions.map(
        (transaction) => jsonEncode(transaction.toJson())
    ).toList();

    await prefs.setStringList('${activeUserx.email}/subTransactions', transactionsString);
  }

  Future<void> _fetchUrgentPayment() async {
    try {
      prefs = await SharedPreferences.getInstance();

      List<String>? transactionsString = prefs.getStringList('${activeUserx.email}/urgentTransactions');
      if (transactionsString != null) {
        transactionsString = prefs.getStringList('${activeUserx.email}/urgentTransactions');
        allUrgentTransactions=transactionsString!.map((transactionString) =>Transaction.fromJson(jsonDecode(transactionString))).toList();
        if(urgentTransactionProvider.allUrgentTransactions!=allUrgentTransactions){
          handleUpdateEmergency();
        }
      }
      else{
        await _fetchUrgentPaymentFromAPI();
      }

    } catch (e) {
      print(e);
    }
  } 

  Future<void> _fetchUrgentPaymentFromAPI() async {
    try {
      List<Transaction> transactions = await ApiHelper.getUrgentTransaction();
      setState(() {
        urgentTransactionProvider.setAllSubTransactions(transactions);
        allUrgentTransactions=transactions;
      });
      _saveUrgentTransactionsToPrefs();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _saveUrgentTransactionsToPrefs() async {
    final List<String> transactionsString = allUrgentTransactions.map(
        (transaction) => jsonEncode(transaction.toJson())
    ).toList();

    await prefs.setStringList('${activeUserx.email}/urgentTransactions', transactionsString);
  }

  Future<void> _getfCMToken() async {
    try {
      String? fCMToken = await FirebaseApi().getfCMToken();
      Provider.of<FCMTokenProvider>(context, listen: false)
          .setfCMToken(fCMToken!);
      await ApiHelper.storeFCMToken(
          activeUserx.email!, fCMToken);
    } catch (e) {
      print(e);
    }
  }

  void _showFirstLoginPopup(BuildContext context) {
    List<String> currencies = ['\$', '€', '₹']; 
    String selectedCurrency = currencies[2]; 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( 
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Welcome!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('This is your first login. Please select your preferred currency:'),
                  DropdownButton<String>(
                    value: selectedCurrency,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() { 
                          selectedCurrency = newValue; 
                        });                        
                      }
                    },
                    items: currencies.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    _saveCurrency(selectedCurrency);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _saveCurrency(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('${activeUserx.email}/currencySymbol', currency);
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 375-260

    // double searchBarWidth=(screenWidth/375)*260;
    // double searchBarHeight=35;

    double textMultiplier = 1;
    double widthMultiplier = 1;
    // double textMultiplier = screenHeight/812;
    // double widthMultiplier = screenWidth/375;
    //H=812 , W=375

    double cardHeight =
    MediaQuery.of(context).size.height * 0.25; // Card height
    double iconSize = cardHeight * 0.25; // Adjust the icon size proportionally

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstLogin = prefs.getBool('firstLogin') ?? true;
      if (isFirstLogin) {
        _showFirstLoginPopup(context);
        await prefs.setBool('firstLogin', false);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right: 0.0), // Add right padding to the notifications button
            child: IconButton(
              icon: const Icon(Icons.chat),
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => IncomingRequestPage())).then((_) => setState(() {_fetchSubTransactions(); _fetchUrgentPayment();shouldUpdate=true;}));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0), 
            child: IconButton(
              icon: const Icon(Icons.notifications),
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () {},
            ),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface, 
        leading: Padding(
          padding: const EdgeInsets.only(
              left: 16.0), // Add left padding to the logout button
          child: IconButton(
            icon: const Icon(Icons.person),
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(activeUser:activeUserx)));
            },
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background, 
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface, 
            height: MediaQuery.of(context).size.height * 0.40,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 16, right: 16, bottom: 7),
                  child:allUrgentTransactions.isEmpty? 
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: 
                            SizedBox(
                              width: screenWidth-42, 
                              height: cardHeight,
                              child: const Center(
                                child: Text("No payments"),
                              ),
                            ),
                      ):
                   SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: allUrgentTransactions.map((transaction) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: SizedBox(
                            width: screenWidth-42, 
                            height: cardHeight,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Amount to pay",
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            transaction.subAmount.toString(),
                                            style: const TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Days remaining",
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            (transaction.endDate.day - DateTime.now().day).toString(),
                                            style: const TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "To",
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            transaction.receiver,
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).colorScheme.primary, 
                                              foregroundColor: Theme.of(context).colorScheme.onPrimary, 
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,  
                                              )
                                            ),
                                            onPressed: () => {
                                              Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleAgreementPage(viewAgreement:transaction))).then((_) => setState(() {_fetchSubTransactions();_fetchUrgentPayment();shouldUpdate=true;}))
                                            },
                                            child: const Text("Details")
                                        )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(iconSize / 2),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.contacts,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: iconSize * 0.6),
                              onPressed: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Request(activeUser: activeUserx))).then((_) => setState(() {_fetchSubTransactions();_fetchUrgentPayment();shouldUpdate=true;}));
                              },
                            ),
                          ),
                          const SizedBox(height: 1.0),
                          Text("Contacts",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: iconSize * 0.25,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(iconSize / 2),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.handshake,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: iconSize * 0.6),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AllAgreementsPage(
                                            activeUser: activeUserx))).then((_) => setState(() {_fetchSubTransactions();_fetchUrgentPayment();shouldUpdate=true;}));
                              },
                            ),
                          ),
                          const SizedBox(height: 1.0),
                          Text("Loans",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: iconSize * 0.25,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: allsubTransactions.isEmpty
                ? Center(child: Text('No payments available.',style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7), fontSize: 16, 
                ),))
                : ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24.0), // Top left corner
                      topRight: Radius.circular(24.0), // Top right corner
                    ),
                    child: Container(
                      color: Theme.of(context).colorScheme.surface, 
                      child: ListView.builder(
                        itemCount: allsubTransactions.length,
                        itemBuilder: (context, index) {
                          final subTransaction = allsubTransactions[index];

                          final transactionDate = subTransaction.date;
                          String formattedDate;
                          final now = DateTime.now();

                          // if (transactionDate.year == now.year &&
                          //     transactionDate.month == now.month &&
                          //     transactionDate.day == now.day) {
                          //   // Show time in 12hr format along with the date if it's today
                          //   formattedDate = DateFormat('d MMM h:mm a').format(transactionDate);
                          // } else if (transactionDate.year == now.year &&
                          //     transactionDate.month == now.month &&
                          //     transactionDate.day == now.day - 1) {
                          //   // Show "Yesterday" along with the time if it's yesterday
                          //   formattedDate = 'Yesterday ' + DateFormat.jm().format(transactionDate);
                          // } else if (transactionDate.year == now.year) {
                          //   // Show date in the format "day Month" along with the time if it's this year
                          //   formattedDate = DateFormat('d MMM').format(transactionDate) +
                          //       ' ' +
                          //       DateFormat.jm().format(transactionDate);
                          // } else {
                          //   // Show date in the format "day Month Year" along with the time
                          //   formattedDate = DateFormat('d MMM y').format(transactionDate) +
                          //       ' ' +
                          //       DateFormat.jm().format(transactionDate);
                          // }
                          return Padding(
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            child: Container(
                              margin: const EdgeInsets.only(top: 8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                height: screenHeight * 0.07,
                                width: screenWidth * 0.9,
                                child: InkWell(
                                  onTap: () async{
                                    await Navigator.push(context,MaterialPageRoute(builder: (context) =>SingleTransactionsPage(subTransaction:subTransaction))).then((_) => setState(() {_fetchSubTransactions();_fetchUrgentPayment();shouldUpdate=true;}));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                              radius:screenHeight * 0.07 * 0.75 * 0.5,
                                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant, 
                                              child: Icon(Icons.person,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant, 
                                              size: screenHeight * 0.07 * 0.75),
                                        ),
                                        SizedBox(width: 23 * widthMultiplier),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    subTransaction.sender,
                                                    style: TextStyle(
                                                        fontSize:
                                                            textMultiplier * 14,
                                                        color: Theme.of(context).colorScheme.onSurfaceVariant, 
                                                        fontWeight:FontWeight.w500),
                                                  ),
                                                  Text(
                                                    DateFormat('dd-MM-yyyy').format(subTransaction.date),
                                                    style: TextStyle(fontSize:textMultiplier * 12,
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7), 
                                                        fontWeight:FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                subTransaction.amount.toString(),
                                                style: TextStyle(
                                                    fontSize:textMultiplier * 16,
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                    fontWeight:FontWeight.w600
                                                ),
                                              ),
                                            ],
                                          ),
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
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddUserDialog();
            },
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary, 
        foregroundColor: Theme.of(context).colorScheme.onPrimary, 
        child: const Icon(Icons.add),
      ),
    );
  }
}
