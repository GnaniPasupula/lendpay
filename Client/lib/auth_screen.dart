import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/Widgets/error_dialog.dart';
import 'package:lendpay/Widgets/sucess_dialog.dart';
import 'package:lendpay/api_helper.dart';
import 'package:lendpay/dashboard.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _signInEmailController = TextEditingController();
  final TextEditingController _signInPasswordController = TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); 
  final TextEditingController _otpController = TextEditingController(); 

  bool _isSignIn = true; 
  bool passwordsMatch = false;
  String? _emailErrorText;
  String? _passwordErrorText;
  String? _confirmPasswordErrorText;

   @override
  void initState() {
    super.initState();
    _signUpPasswordController.addListener(updatePasswordsMatch);
    _confirmPasswordController.addListener(updatePasswordsMatch);
  }

  void updatePasswordsMatch() {
    setState(() {
      passwordsMatch = _signUpPasswordController.text == _confirmPasswordController.text;
    });
  }

  // Future<void> _logout() async {
  //   await ApiHelper.logout(context);
  // }

  Future<void> _signin() async {
    final url = 'http://localhost:3000/auth/signin';
    // const url = 'http://192.168.0.103:3000/auth/signin';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'email': _signInEmailController.text,
          'password': _signInPasswordController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final authToken = responseData['token'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', authToken);

          // await getActiveUserDetails();
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));

        } else {
          final responseBody = json.decode(response.body);
          final errorMessage = responseBody['message'];
          ErrorDialogWidget.show(context,errorMessage);
        }
    
    } 
    catch (error) {
      print('Error during HTTP request: $error');
    }  
  }

  Future<void> _signup() async {
    final url = 'http://localhost:3000/auth/signup';
    // const url = 'http://192.168.0.103:3000/auth/signup';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'email': _signUpEmailController.text,
          'password': _signUpPasswordController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print(response.body);

      if (response.statusCode == 200) {
        _showOtpDialog();
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'];
        ErrorDialogWidget.show(context, errorMessage);
      }
    } catch (error) {
      print('Error during HTTP request: $error');
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Enter OTP'),
        content: TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration
                      (labelText: 'OTP',    
                        labelStyle: TextStyle(color: Colors.black), 
                        focusedBorder: UnderlineInputBorder
                        (borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),),
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _validateOTP();
            },
            child: Text('Submit'),
            
          ),
        ],
      ),
    );
  }

  Future<void> _validateOTP() async {
    final url = 'http://localhost:3000/auth/verify-otp';
    // const url = 'http://192.168.0.103:3000/auth/verify-otp';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'email': _signUpEmailController.text,
          'otp': _otpController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        SucessDialogWidget.show(context, "Account created successfully, sign in to continue");
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'];
        ErrorDialogWidget.show(context, errorMessage);
      }
    } catch (error) {
      print('Error during OTP validation: $error');
    }
  }


  Future<void> getActiveUserDetails() async{
    try{
      final User? activeUser = await ApiHelper.getActiveUser();
      Provider.of<UserProvider>(context, listen: false).setActiveUser(activeUser!);
    }catch(e){ 
      print('Error fetching active user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1), 
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20), // Add some spacing
              ToggleButtons(
                constraints: const BoxConstraints.tightFor(height: 30), 
                isSelected: [_isSignIn, !_isSignIn],
                onPressed: (index) {
                  setState(() {
                    _isSignIn = index == 0; // Toggle the state
                  });
                },
                fillColor: Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(10),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: _isSignIn ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: !_isSignIn ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              if (_isSignIn) // Display Sign In fields
                Column(
                  children: [
                    TextField(
                      controller: _signInEmailController,
                      style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                    ),
                    TextField(
                      controller: _signInPasswordController,
                      style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              if (!_isSignIn) // Display Sign Up fields
                Column(
                  children: [
                    TextField(
                      controller: _signUpEmailController,
                      style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        errorText: _emailErrorText,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        bool isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
                        setState(() {
                          _emailErrorText = isValid ? null : 'Enter valid email';
                        });
                      },
                    ),
                    TextField(
                      controller: _signUpPasswordController,
                      style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        errorText: _passwordErrorText,
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          bool isValid = value.length >= 6;
                          _passwordErrorText = isValid ? null : 'Password must be at least 6 characters';
                        });
                      },
                    ),
                    TextField(
                      controller: _confirmPasswordController,
                      style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        errorText: _confirmPasswordErrorText,
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          bool isValid = value == _signUpPasswordController.text;
                          _confirmPasswordErrorText = isValid ? null : 'Passwords do not match';
                        });
                      },
                    ),
                  ],
                ),
              SizedBox(height: 20),
              AbsorbPointer(
                absorbing: _isSignIn ? false : !passwordsMatch,
                child: ElevatedButton(
                  onPressed: (_isSignIn ? _signin : _signup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    padding: EdgeInsets.symmetric(horizontal: 50),
                  ),
                  child: IgnorePointer(
                    ignoring: (!_isSignIn && !passwordsMatch),
                    child: Opacity(
                      opacity: (passwordsMatch && _signUpPasswordController.text.length>=6) || _isSignIn? 1.0 : 0.5,
                      child: Text(
                        _isSignIn ? 'Sign In' : 'Sign Up',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}