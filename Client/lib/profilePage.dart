import 'package:flutter/material.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final User activeUser;

  ProfileScreen({required this.activeUser});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String currencySymbol = '';
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  void _saveCurrency(String currency) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.activeUser.email}/currencySymbol', currency);
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    currencySymbol = prefs.getString('${widget.activeUser.email}/currencySymbol')!;
    setState(() {}); 
  }

    void showCurrencySelectionPopup() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ListView(
            children: <Widget>[
              ListTile(
                title: Text('₹ - IND Rupee'),
                onTap: () {
                  setState(() {
                    currencySymbol = '₹'; 
                    _saveCurrency('₹') ;
                  });
                  Navigator.pop(context); 
                },
              ),
              ListTile(
                title: Text('\$ - US Dollar'),
                onTap: () {
                  setState(() {
                    currencySymbol = '\$';
                    _saveCurrency('\$') ;
                  });
                  Navigator.pop(context); 
                },
              ),
              ListTile(
                title: Text('€ - Euro'),
                onTap: () {
                  setState(() {
                    currencySymbol = '€';
                    _saveCurrency('€') ; 
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
    
    Future<void> _showChangeNamePopup() async {
      String newName = '';

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Name'),
            content: TextField(
              onChanged: (value) {
                newName = value;
              },
              decoration: InputDecoration(labelText: 'New Name'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (newName.isNotEmpty) {
                    try{
                      await ApiHelper.changeName(newName, widget.activeUser.email!);  
                      setState(() {
                        widget.activeUser.name = newName;
                      });
                    }catch(e){
                      print(e);
                    }
                  }
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    }

    Future<void> _showChangePasswordPopup() async {
      String oldPassword = '';
      String newPassword = '';
      String confirmNewPassword = '';

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    oldPassword = value;
                  },
                  decoration: InputDecoration(labelText: 'Old Password'),
                  obscureText: true,
                ),
                TextField(
                  onChanged: (value) {
                    newPassword = value;
                  },
                  decoration: InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
                TextField(
                  onChanged: (value) {
                    confirmNewPassword = value;
                  },
                  decoration: InputDecoration(labelText: 'Confirm New Password'),
                  obscureText: true,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (newPassword == confirmNewPassword) {
                    ApiHelper.changePassword(widget.activeUser.email!, oldPassword, newPassword);
                  }
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double textMultiplier = 1;
    double widthMultiplier = 1;
    // double textMultiplier = screenHeight/812;
    // double widthMultiplier = screenWidth/375;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, 
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: 18,color: Theme.of(context).colorScheme.onBackground)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileOption(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: widget.activeUser.name,
                  onPressed: () {
                    _showChangeNamePopup();
                  },
                  editOption: true,
                ),
                SizedBox(height: 7*textMultiplier),
                ProfileOption(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  value: widget.activeUser.email!,
                  onPressed: () {
                    Null;
                  },
                  editOption: false,
                ),
                SizedBox(height: 7*textMultiplier),
                ProfileOption(
                  icon: Icons.lock_outline,
                  label: 'Password',
                  value: "*****",
                  onPressed: () {
                    _showChangePasswordPopup();
                  },
                  editOption: true,
                ),
                SizedBox(height: 7*textMultiplier),
                ProfileOption(
                  icon: currencyIcons[currencySymbol]??Icons.attach_money, 
                  label: 'Currency Symbol',
                  value: currencySymbol, 
                  onPressed: () {
                    showCurrencySelectionPopup(); 
                  },
                  editOption: true, 
                ),
                SizedBox(height: 7*textMultiplier),
                ProfileOption(
                  icon: Icons.login_outlined,
                  label: 'Log out',
                  value: '',
                  onPressed: () {
                    ApiHelper.logout(context);
                  },
                  editOption: false,
                ),
                SizedBox(height: 7*textMultiplier),
                ProfileOption(
                  icon: Icons.power_settings_new_outlined,
                  label: 'Close account',
                  value: '',
                  onPressed: () {
                    _showChangePasswordPopup();
                  },
                  editOption: false,
                ),
                SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () {
                //     ApiHelper.logout(context);
                //   },
                //   child: Text('Logout'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Map<String, IconData> currencyIcons = {
  '\$': Icons.attach_money, 
  '€': Icons.euro_symbol,   
  '₹': Icons.currency_rupee,  
};


class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onPressed;
  final bool editOption;

  ProfileOption({required this.icon, required this.label, required this.value, required this.onPressed, required this.editOption});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double textMultiplier = 1;
    double widthMultiplier = 1;
    // double textMultiplier = screenHeight/812;
    // double widthMultiplier = screenWidth/375;
    //H=812 , W=375

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight* 0.06,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Row(
              children: [
                SizedBox(width: 9 * widthMultiplier), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: MediaQuery.of(context).size.height * 0.06 * 0.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ],
                ),
                SizedBox(width: 16 * widthMultiplier), 
                Column(
                  mainAxisAlignment: (value.isNotEmpty) ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: textMultiplier * 14, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                    ),
                    if (value.isNotEmpty)
                      Text(
                        value,
                        style: TextStyle(fontSize: textMultiplier * 12,color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),fontWeight: FontWeight.w500),
                      )
                    else
                      SizedBox(), 
                  ],
                ),

              ],
            ),          
            editOption ?
              Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 9.0, right: 9.0),
                  child: Text(
                    "Change",
                    style: TextStyle(fontSize: textMultiplier * 14, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ) 
              ],
              ): SizedBox(),             
          ],
        ),

      ),
    );
  }
}
