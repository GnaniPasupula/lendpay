import 'package:flutter/material.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/api_helper.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';

  @override
  Widget build(BuildContext context) {

    UserProvider userProvider = Provider.of<UserProvider>(context);
    User activeUser = userProvider.activeUser;

    setState(() {
      userName=activeUser.name;
    });
    
    Future<void> _showChangeNamePopup() async {
      String newName = '';

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Change Name'),
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
                      await ApiHelper.changeName(newName, activeUser.email);  
                      setState(() {
                        activeUser.name = newName;
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
                  // Implement logic to change the password
                  if (newPassword == confirmNewPassword) {
                    // Password change logic
                    // You can call an API or update the state accordingly
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                activeUser.email,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ProfileOption(
                icon: Icons.edit,
                label: 'Change Name',
                onPressed: () {
                  _showChangeNamePopup();
                },
              ),
              ProfileOption(
                icon: Icons.lock,
                label: 'Change Password',
                onPressed: () {
                  _showChangePasswordPopup();
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ApiHelper.logout(context);
                },
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  ProfileOption({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 30),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
    );
  }
}
