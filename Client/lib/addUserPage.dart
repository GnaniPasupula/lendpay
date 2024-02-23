import 'package:flutter/material.dart';
import 'package:lendpay/api_helper.dart';

class AddUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddUserDialog();
              },
            );
          },
          child: Text('Open Add User Dialog'),
        ),
      ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> addUser(BuildContext context) async {
    try {
      await ApiHelper.addUser(nameController.text);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully added User to contacts'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // print('Error adding user: $e');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: nameController.text.isNotEmpty?const Text('Error: Name already exists'):const Text('Name is required'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    double textMultiplier = 1;

    return Dialog(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Person',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16 * textMultiplier),
              ProfileOption(
                icon: Icons.person,
                label: 'Name',
                value: nameController.text,
                controller: nameController,
              ),
              SizedBox(height: 24 * textMultiplier),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () => addUser(context), 
                    child: Text('Add'),
                  ),
                ],
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
  final String value;
  final TextEditingController? controller;

  ProfileOption({required this.icon, required this.label, required this.value, this.controller});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textMultiplier = 1;
    double widthMultiplier = 1;

    return Container(
      width: screenWidth * 0.9,
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(
        color: Color.fromRGBO(229, 229, 229, 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(width: 9 * widthMultiplier),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: MediaQuery.of(context).size.height * 0.06 * 0.5, color: Color.fromRGBO(0, 0, 0, 1)),
            ],
          ),
          SizedBox(width: 16 * widthMultiplier), 
          Expanded(
            child: Center( 
              child: SizedBox( 
                width: screenWidth * 0.6, 
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter $label',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
