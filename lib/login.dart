import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:scheduler_app/ChatRoom/home_screen.dart';
import 'package:scheduler_app/register.dart';
import 'package:scheduler_app/scheduler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  // declaring variables
  late String password, email;
  // form key parameter for validating
  final _formkey = GlobalKey<FormState>();
  // editting controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //email field
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      // validator: (value) {},
      onSaved: (value) {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.mail),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: 'Email',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please Enter your email';
        }
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return 'Please Enter a valid Email';
        }
        return null;
      },
      onChanged: (value) => email = value,
    );
    // password field
    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: true,
      // validator: (value) {},
      onSaved: (value) {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      maxLength: 6,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.vpn_key),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: 'Password',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        if (value.trim().length < 6) {
          return 'Password must be at least 6 characters in length';
        }
        // Return null if the entered password is valid
        return null;
      },
    );

    // login button
    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.orange,
      child: MaterialButton(
        onPressed: () async {
          if (_formkey.currentState!.validate()) {
            setState(() {
              isLoading = true;
            });
            try {
              final User? user =
                  (await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text,
              ))
                      .user;

              if (user != null) {
                // User is verified, proceed with login
                // Success
                checkUser();
              } else {
                // await user?.sendEmailVerification();
                // User is not verified, show an error message
                // ignore: use_build_context_synchronously
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Alert!'),
                      content: const Text(
                          'Please check in your inbox to verify the email before signing in.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Color(0xFF8352A1)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            } on FirebaseAuthException catch (error) {
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(
                msg: error.message ?? "Something went wrong",
                gravity: ToastGravity.TOP,
                toastLength: Toast.LENGTH_LONG,
                backgroundColor: Colors.white,
                textColor: Colors.red,
              );
            }
          }
        },
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                'Login',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        child: RichText(
                            text: const TextSpan(
                                text: 'Your\n',
                                style: TextStyle(
                                  fontSize: 32,
                                  color: Color(0xFFE8D33F),
                                  fontWeight: FontWeight.bold,
                                ),
                                children: <TextSpan>[
                              TextSpan(
                                  text: ' Staff Scheduler',
                                  style: TextStyle(
                                    color: Colors.black87,
                                  ))
                            ])),
                      ),
                      SizedBox(
                        width: size.width,
                        height: size.height * .3,
                        child: Lottie.asset(
                            'assets/lottie/34526-coding-in-office.json'),
                      ),
                      const Text(
                        'Login Here',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      emailField,
                      const SizedBox(
                        height: 25,
                      ),
                      passwordField,
                      const SizedBox(
                        height: 5,
                      ),
                      forgetPassword(context),
                      loginButton,
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Don't have an account?"),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage()));
                            },
                            child: const Text(
                              " Sign Up",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  // function for forget password
  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
          child: const Text(
            "Forgot Password?",
            style: TextStyle(color: Colors.orange),
            textAlign: TextAlign.right,
          ),
          onPressed: () => {}
          //  Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => const ResetPasswordPage())),
          ),
    );
  }

  // get the user data
  void checkUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('SheduleUsers')
        .doc(uid)
        .get();
    // get the balance to decrypt
    final userRole = userDoc.get("role");

    if (userRole == "Staff Member") {
      Fluttertoast.showToast(
        msg: "Signed in as $email",
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
      );
      //Success
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    } else if (userRole == "Admin") {
      Fluttertoast.showToast(
        msg: "Signed in as $email",
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
      );
      //Success
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => StaffListScreen()));
    } else {
      // UserType is not known, show an error message
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alert!'),
            content: const Text(
                'No data found for user, try to register a new account'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF8352A1)),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
