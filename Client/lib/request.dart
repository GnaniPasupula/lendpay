import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lendpay/Models/Transaction.dart';
import 'package:lendpay/api_helper.dart';

class Request extends StatefulWidget{
  @override
  _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request>{
  TextEditingController searchController = TextEditingController();
  List<Transaction> allTransactions=[];
  late String username;

  void handleSearch(){
    username=searchController.text;
    print(username);
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final List<Transaction> transactions = await ApiHelper.fetchUserTransactions(username);
      setState(() {
        allTransactions = transactions;
      });
      print(allTransactions);
    } catch (e) {
      print(e);
      // Handle error and show a proper error message to the user
    }
  }


  @override
  Widget build(BuildContext context){
    return(
      Scaffold(appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),onPressed: () => Navigator.pop(context),),
          title: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search user',prefixIcon: Icon(Icons.search),
                  ),
                  cursorColor: Colors.white
                  
                  )
              ),
              IconButton(
                icon:const Icon(Icons.done),
                onPressed: handleSearch,
              )
            ],
          )
      ))
    );
  }
}