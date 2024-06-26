import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dermaleens/Auth/signup.dart';
import 'package:dermaleens/pages/home.dart';
import 'package:dermaleens/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  bool _isLoading = false;  // Add this line

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;  // Show loading indicator
      });
      try {
        final UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Fetch additional user data from Firestore
        final DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(userCredential.user!.uid).get();
        // ignore: unused_local_variable
        final userData = userSnapshot.data() as Map<String, dynamic>;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          _showErrorSnackbar(context, 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          _showErrorSnackbar(context, 'Wrong password provided for that user.');
        } else {
          _showErrorSnackbar(context, 'Invalid Email or Password.');
        }
      } finally {
        setState(() {
          _isLoading = false;  // Hide loading indicator
        });
      }
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: size.width,
              height: size.height,
              decoration: const BoxDecoration(color: Color(0xFF191919)),
              child: Form(
                key: _formKey,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: size.height * 0.08,
                      child: Text(
                        'Login',
                        style: SafeGoogleFont(
                          'Poppins',
                          color: Colors.white,
                          fontSize: 60 * textScaleFactor,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.22,
                      child: Text(
                        'Please login to continue',
                        style: SafeGoogleFont(
                          'Poppins',
                          color: const Color(0xFFAEAEAE),
                          fontSize: 28 * textScaleFactor,
                          fontWeight: FontWeight.w300,
                          height: 1,
                        ),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.32,
                      child: Container(
                        width: size.width * 0.36,
                        height: size.height * 0.08,
                        decoration: const ShapeDecoration(
                          color: Color(0xFF262626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9.14)),
                          ),
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Image.asset('lib/icons/Email.png', scale: 2.5),
                            border: InputBorder.none,
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Color(0xffaeaeae)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          onSaved: (value) => _email = value!,
                          style: SafeGoogleFont(
                            'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.43,
                      child: Container(
                        width: size.width * 0.36,
                        height: size.height * 0.08,
                        decoration: const ShapeDecoration(
                          color: Color(0xFF262626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9.14)),
                          ),
                        ),
                        child: TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Image.asset('lib/icons/Password.png', scale: 2.5),
                            border: InputBorder.none,
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Color(0xffaeaeae)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          onSaved: (value) => _password = value!,
                          style: SafeGoogleFont(
                            'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.55,
                      child: InkWell(
                        onTap: () => _signInWithEmailAndPassword(context),
                        child: Container(
                          width: size.width * 0.25,
                          height: size.height * 0.1,
                          decoration: const ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-1.00, -0.05),
                              end: Alignment(1, 0.05),
                              colors: [Color(0xFF023994), Color(0xFF12AAFF)],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(66)),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Continue',
                              style: SafeGoogleFont(
                                'Poppins',
                                color: Colors.white,
                                fontSize: 43 * textScaleFactor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.68,
                      child: InkWell(
                        onTap: () async {
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Sent via email"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Text(
                          'Forget password?',
                          style: SafeGoogleFont(
                            'Poppins',
                            color: const Color(0xFF11A3F8),
                            fontSize: 30 * textScaleFactor,
                            fontWeight: FontWeight.w300,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.76,
                      child: Text(
                        'You don’t have an account?',
                        style: SafeGoogleFont(
                          'Poppins',
                          color: const Color(0xFFAEAEAE),
                          fontSize: 30 * textScaleFactor,
                          fontWeight: FontWeight.w300,
                          height: 1,
                        ),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.83,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Signup()),
                          );
                        },
                        child: Text(
                          'Click here',
                          style: SafeGoogleFont(
                            'Poppins',
                            color: const Color(0xFF11A3F8),
                            fontSize: 35 * textScaleFactor,
                            fontWeight: FontWeight.w300,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
  
Center(
  child: TweenAnimationBuilder(
    duration: const Duration(seconds: 1),
    tween: Tween<double>(begin: 0, end: 1),
    builder: (BuildContext context, double value, Widget? child) {
      return Transform.rotate(
        angle: value * 2 * 3.141,
         child: Image.asset('assets/page-1/images/ellipse-2-EMc.png') 
      );
    },
  ),
)

         
        ],
      ),
    );
  }
}
