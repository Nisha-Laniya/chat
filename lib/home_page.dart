import 'package:auth/helper/constants.dart';
import 'package:auth/helper/helper_function.dart';
import 'package:auth/models/user.dart';
import 'package:auth/services/auth.dart';
import 'package:auth/widgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    getUserInfo();
    super.initState();
  }

  getUserInfo() async{
    Constants.myName = (await HelperFunctions.getUsernameSharedPreference()) ?? '';
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        drawer: CommonDrawer());
  }
}

class EditProfile extends StatefulWidget {
  EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();

  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  TextEditingController dateInputController = TextEditingController();

  TextEditingController usernameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController genderController = TextEditingController();

  TextEditingController phoneNoController = TextEditingController();

  DocumentSnapshot? snapshot;

  DateTime selectedDate = DateTime.now();

  QuerySnapshot? snapshotInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit your profile'),
      ),
      drawer: CommonDrawer(),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder(
                future: FirebaseServices().getUserDetails(
                    FirebaseAuth.instance.currentUser?.uid ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      UserModel userModel = snapshot.data as UserModel;
                      usernameController.text = userModel.name;
                      emailController.text = userModel.email;
                      dateInputController.text = userModel.dob;
                      genderController.text = userModel.gender;
                      phoneNoController.text = userModel.phoneNo;
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Form(
                            key: formKey,
                            autovalidateMode: _autoValidate,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 30,
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
                                      hintText:
                                          "Enter Birthdate" //label text of field
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
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickedDate);
                                      print(formattedDate);
                                      dateInputController.text = formattedDate;
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
                                  hint: Text(
                                    genderController.text,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_downward),
                                  iconSize: 24,
                                  elevation: 16,
                                  // validator: (value) {
                                  //   return value == null
                                  //       ? 'Please Select Gender'
                                  //       : null;
                                  // },
                                  onChanged: (String? newValue) {
                                    genderController.text = newValue!;
                                  },
                                  items: <String>[
                                    'Male',
                                    'Female',
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
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
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: Size.fromHeight(50)),
                                  onPressed: () async {
                                    // isLoading = true;

                                    if (formKey.currentState!.validate()) {
                                      HelperFunctions.saveUserEmailSharedPreference(emailController.text);
                                      FirebaseServices().getUserByUserEmail(emailController.text).then((val) {
                                        snapshotInfo = val;
                                        HelperFunctions.saveUserNameSharedPreference(snapshotInfo?.docs[0]['Name']);
                                      });

                                      // Constants.myName = (await HelperFunctions.getUsernameSharedPreference()) ?? '';
                                      // setState(() {
                                      //
                                      // });

                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(userModel.id)
                                          .update({
                                        'Name': usernameController.text,
                                        'Email': emailController.text,
                                        'Dob': dateInputController.text,
                                        'Gender': genderController.text,
                                        'Phone no': phoneNoController.text
                                      }).then((value) {
                                        FirebaseAuth.instance.currentUser
                                            ?.updateEmail(emailController.text)
                                            .then((value) {
                                          print('Change email');
                                        });
                                        FirebaseAuth.instance.currentUser
                                            ?.updateDisplayName(
                                                usernameController.text)
                                            .then((value) {
                                          print('Change Name');
                                        });
                                      });
                                    }
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()));
                                  },
                                  child: const Text(
                                    'Submit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return Center(
                        child: Text('Something went wrong'),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
      ),
    );
  }
}
