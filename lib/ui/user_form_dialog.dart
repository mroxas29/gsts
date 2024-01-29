import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sysadmindb/app/models/sendemail.dart';
import 'package:sysadmindb/app/models/user.dart';

class UserData {
  Map<String, String> displayname = {};
  late String email;
  late int idnumber;
  late String role;
  late String password;
  String degree = '';
}

void showAddUserForm(BuildContext context, GlobalKey<FormState> formKey) {
  List<String> roles = ['Coordinator', 'Graduate Student', 'Admin'];
  List<String> degrees = ['No degree', 'MIT', 'MSIT'];

  final UserData _userData = UserData();

  String selectedDegree = degrees[0];
  String selectedRole = roles[0];
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isStudent = false;

  print("Add user form executed");
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add New User'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userData.displayname['firstname'] = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userData.displayname['lastname'] = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }

                    if (!value.contains('@dlsu.edu.ph')) {
                      return 'Enter a valid @dlsu.edu.ph email';
                    }

                    // Add email validation if needed
                    return null;
                  },
                  onSaved: (value) {
                    _userData.email = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'ID Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter ID number';
                    }
                    if (!users
                        .every((user) => user.idnumber != int.parse(value))) {
                      return 'ID number already exists';
                    }

                    // Add ID number validation if needed
                    return null;
                  },
                  onSaved: (value) {
                    _userData.idnumber = int.parse(value ?? '0');
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Add the necessary setState method if needed
                    selectedRole = value!;
                    selectedDegree = '';
                    if (selectedRole.contains('Student')) {
                      isStudent = true;
                    } else {
                      isStudent = false;
                      selectedDegree = '';
                    }
                    print(isStudent.toString());
                  },
                  onSaved: (value) {
                    _userData.role = value ?? '';
                  },
                  decoration: InputDecoration(labelText: 'Role'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedDegree,
                  items: degrees.map((degree) {
                    return DropdownMenuItem<String>(
                      value: degree,
                      child: Text(degree),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Add the necessary setState method if needed
                    selectedDegree = value!;
                  },
                  onSaved: (value) {
                    if (isStudent) {
                      _userData.degree = value ?? '';
                    }
                  },
                  decoration: InputDecoration(labelText: 'Degree'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }

                    String password = value.trim();

                    if (password.length < 12 || password.length > 64) {
                      return 'Password must be between 12 and 64 characters';
                    }

                    if (!password.contains(RegExp(r'[0-9]'))) {
                      return 'Password must contain at least one number';
                    }

                    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                      return 'Password must contain at least one special character';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _userData.password = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  controller: confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm the password';
                    } else if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: _userData.email,
                    password: _userData.password,
                  );

                  User? user = userCredential.user;
                  await user?.sendEmailVerification();
                  sendEmail(
                      firstname: _userData.displayname['firstname'],
                      email: _userData.email,
                      toemail: _userData.email,
                      subject:
                          'New account at the Graduate Student Tracking System',
                      password: _userData.password);

                  String userID = userCredential.user!.uid;

                  if (isStudent) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userID)
                        .set({
                      'displayname': {
                        'firstname': _userData.displayname['firstname']!,
                        'lastname': _userData.displayname['lastname']!,
                      },
                      'role': _userData.role,
                      'email': _userData.email.toLowerCase(),
                      'idnumber': _userData.idnumber,
                      'degree': _userData.degree
                    });
                  } else {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userID)
                        .set({
                      'displayname': {
                        'firstname': _userData.displayname['firstname']!,
                        'lastname': _userData.displayname['lastname']!,
                      },
                      'role': _userData.role,
                      'email': _userData.email.toLowerCase(),
                      'idnumber': _userData.idnumber,
                    });
                  }
                  Navigator.pop(context);
                  users.clear();

                  addUserFromFirestore();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User created'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  print('Error creating user: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error creating user: $e'),
                    ),
                  );
                }
              }
            },
            child: Text('Submit'),
          ),
        ],
      );
    },
  );
}
