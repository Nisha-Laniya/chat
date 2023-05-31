import 'package:auth/add_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: _isLoading ? const CircularProgressIndicator() : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: formKey,
            autovalidateMode: _autovalidate,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Username'),
                  controller: _usernameTextController,
                  validator: (val) {
                    return val!.isEmpty || val.length < 2 ? 'Please Enter Username' : null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Email'),
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
                  height: 30,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50)),
                    onPressed: () async {
                      if(formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading  = true;
                        });
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                            email: _emailTextController.text,
                            password: _passwordTextController.text)
                            .then(
                                (value) async {
                                  final auth = FirebaseAuth.instance.currentUser;
                                  await auth!.updateDisplayName(_usernameTextController.text).then((value) {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AddProfileScreen()));
                                  });
                                }
                        );
                      } else {
                        setState(() {
                          _autovalidate = AutovalidateMode.always;
                        });
                      }
                    },
                    child: Text('Sign Up')),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
