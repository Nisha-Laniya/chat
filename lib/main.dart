import 'package:auth/forgot_password.dart';
import 'package:auth/helper/helper_function.dart';
import 'package:auth/home_page.dart';
import 'package:auth/services/auth.dart';
import 'package:auth/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'add_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isUserLoggedIn = false;

  @override
  void initState() {
    // TODO: implement initState
    getLoggedInState();
    super.initState();

  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        isUserLoggedIn = value!;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.light,
      darkTheme: ThemeData(brightness: Brightness.dark),
      home:isUserLoggedIn ? const HomePage() : const LoginPage() ,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailTextController = TextEditingController();

  final TextEditingController _passwordTextController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  QuerySnapshot? snapshotInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: _isLoading ? CircularProgressIndicator() : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: formKey,
            autovalidateMode: _autoValidate,
            child: Column(
              children: [
                TextFormField(
                    decoration: InputDecoration(hintText: 'Email'),
                    controller: _emailTextController,
                  validator: (val) {
                    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(val!) ? null : "Please enter valid Email address";
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Password'),
                  controller: _passwordTextController,
                  validator: (val) {
                    return val!.length < 6 ? "Please enter more than 6 character" : null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Forgot(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                    onPressed: () {
                      if(formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        HelperFunctions.saveUserEmailSharedPreference(_emailTextController.text);
                        FirebaseServices().getUserByUserEmail(_emailTextController.text).then((val) {
                          snapshotInfo = val;
                          HelperFunctions.saveUserNameSharedPreference(snapshotInfo?.docs[0]['Name']);
                        });

                        FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                            email: _emailTextController.text,
                            password: _passwordTextController.text)
                            .then(
                              (value) {
                                HelperFunctions.saveUserLoggedInSharedPreference(true);
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                              }
                        );
                      } else {
                        setState(() {
                          _autoValidate = AutovalidateMode.always;
                        });
                      }
                    },
                    child: const Text('Login')),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      50,
                    ),
                  ),
                  onPressed: () {
                    FirebaseServices().signInWithGoogle();
                  },
                  child: const Text(
                    'Sign In With Google',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Signup()));
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
