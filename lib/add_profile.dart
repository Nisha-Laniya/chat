import 'package:auth/helper/helper_function.dart';
import 'package:auth/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';

class AddProfileScreen extends StatefulWidget {
  const AddProfileScreen({Key? key}) : super(key: key);

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  TextEditingController dateInputController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isLoading = false;
  String? newDocId;
  QuerySnapshot? snapshotInfo;

  @override
  void initState() {
    super.initState();
    initUser();
    retrieveValue();
  }

  initUser() {
    user = _auth.currentUser!;
  }


  retrieveValue() {
    usernameController.text = user!.displayName ?? '';
    emailController.text = user!.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Form(
                    key: formKey,
                    autovalidateMode: _autoValidate,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Complete your profile',
                          style: TextStyle(fontSize: 30),
                        ),
                        const SizedBox(
                          height: 80,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter UserName',
                          ),
                          controller: usernameController,
                          validator: (val) {
                            return val!.isEmpty || val.length < 2
                                ? 'Please Enter Username'
                                : null;
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter Email',
                          ),
                          controller: emailController,
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val!)
                                ? null
                                : "Please enter valid Email address";
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: dateInputController,
                          decoration: const InputDecoration(
                              hintText: "Enter Birthdate" //label text of field
                              ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101));
                            if (pickedDate != null) {
                              print(pickedDate);
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                              print(formattedDate);

                              setState(() {
                                dateInputController.text = formattedDate;
                              });
                            } else {
                              print("Date is not selected");
                            }
                          },
                          validator: (val) {
                            return val!.isEmpty
                                ? 'Please enter date of birth'
                                : null;
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        DropdownButtonFormField<String>(
                          hint: const Text('Select Gender'),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          validator: (value) {
                            return value == null
                                ? 'Please Select Gender'
                                : null;
                          },
                          onChanged: (String? newValue) {
                            genderController.text = newValue!;
                          },
                          items: <String>[
                            'Male',
                            'Female',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter Phone no',
                          ),
                          controller: phoneNoController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            return value!.isEmpty || value.length < 10
                                ? 'Please enter Phone no'
                                : null;
                          },
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size.fromHeight(50)),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });

                              HelperFunctions.saveUserNameSharedPreference(usernameController.text);
                              HelperFunctions.saveUserEmailSharedPreference(emailController.text);
                              FirebaseServices().getUserByUserEmail(emailController.text).then((val) {
                                  snapshotInfo = val;
                                  HelperFunctions.saveUserNameSharedPreference(snapshotInfo?.docs[0]['Name']);
                              });
                              await FirebaseFirestore.instance
                                  .collection('Users').doc(user?.uid)
                                  .set({
                                'Name': usernameController.text,
                                'Email': emailController.text,
                                'Dob': dateInputController.text,
                                'Gender': genderController.text,
                                'Phone no': phoneNoController.text,
                                'UserId': user?.uid,
                              }).then((value) {
                                HelperFunctions.saveUserLoggedInSharedPreference(true);
                               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                                // debugPrint(value.id);
                              });
                            }
                            setState(
                              () {
                                _autoValidate = AutovalidateMode.always;
                              },
                            );
                          },
                          child: const Text(
                            'Submit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
