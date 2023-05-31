import 'package:auth/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Forgot extends StatefulWidget {
  Forgot({Key? key}) : super(key: key);

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final TextEditingController _emailTextController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: _isLoading ? const CircularProgressIndicator() :  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: formKey,
            autovalidateMode: _autoValidate,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'Email'
                  ),
                  controller: _emailTextController,
                  validator: (val) {
                    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(val!) ? null : "Please enter valid Email address";
                  },
                ),
                const SizedBox(height: 50,),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)
                    ),
                    onPressed: () async {
                      if(formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailTextController.text).then((value) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                        });
                      } else {
                        setState(() {
                          _autoValidate = AutovalidateMode.always;
                        });
                      }
                    },
                    child: const Text('Forgot Password')
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
