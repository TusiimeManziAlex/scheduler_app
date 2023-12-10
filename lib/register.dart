import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:scheduler_app/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  bool isLoading = false;
  late String _password, confirmpassword;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                width: size.width,
                height: size.height * .3,
                child: Lottie.asset('assets/lottie/animation_lnkezkdt.json'),
              ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                    ),
                  ),
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      if (value.trim().length < 6) {
                        return 'Pin must be at least 6 characters in length';
                      }
                      // Return null if the entered password is valid
                      return null;
                    },
                    onChanged: (value) => _password = value,
                    decoration: const InputDecoration(
                      labelText: "Password",
                    ),
                  ),
                  TextFormField(
                    controller: confirmPassword,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      if (value != _password) {
                        return 'Passwords do not match the entered password';
                      }
                      // Return null if the entered password is valid
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Confirm Password",
                    ),
                  ),
                  TextFormField(
                    controller: name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }

                      // Return null if the entered password is valid
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Name",
                    ),
                  ),
                  TextFormField(
                    controller: phoneNumber,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.orange)),
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });
                        
                        register();

                        Future.delayed(const Duration(seconds: 5), () {
                          setState(() {
                            isLoading = false;
                          });
                          
                        });
                      },
                      child: isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                Text(
                                  'Loading...',
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ],
                            )
                          : const Text(
                              "REGISTER",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text("Already a member?"),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ));
                      },
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(color: Colors.orange),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.text, password: password.text);
        final User? user = _auth.currentUser;
        final _uid = user?.uid;

        await FirebaseFirestore.instance.collection('SheduleUsers').doc(_uid).set({
          'uid': _uid,
          'mame': name.text,
          'emailAddress': email.text,
          'passWord': password.text,
          'role': "Staff Member",
          'createdAt': Timestamp.now(),
        });

        //Success
        // ignore: use_build_context_synchronously
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      } on FirebaseAuthException catch (error) {
        print("Error:$error");
      }
    }
  }
}
