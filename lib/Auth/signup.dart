import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dermaleens/Auth/login.dart';
import 'package:dermaleens/pages/home.dart';
import 'package:dermaleens/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  // ignore: unused_field
  String _confirmPassword = '';
  String _mobilePhone = '';
  String? _selectedCountryCode;
bool _isLoading = false;

  Future<void> _signUpWithUsernameAndEmailAndPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('phone', isEqualTo: _mobilePhone)
            .get();

        final List<DocumentSnapshot> documents = result.docs;
        if (documents.isNotEmpty) {
          _showErrorSnackbar(context, 'The phone number is already in use.');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': _firstName,
          'lastName': _lastName,
          'email': _email,
          'phone': _mobilePhone,
        });

        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (e.code == 'weak-password') {
          _showErrorSnackbar(context, 'The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          _showErrorSnackbar(context, 'The account already exists for that email.');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackbar(context, 'An error occurred. Please try again.');
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
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  decoration: const BoxDecoration(color: Color(0xFF191919)),
                  child: Form(
                    key: _formKey,
                    child: Stack(
                      children: [
                  Positioned(
                    left: constraints.maxWidth * 0.44,
                    top: constraints.maxHeight * 0.03,
                    child: Text(
                      'Signup',
                      style: SafeGoogleFont(
                        'Poppins',
                        color: Colors.white,
                        fontSize: constraints.maxWidth * 0.046,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * 0.39,
                    top: constraints.maxHeight * 0.14,
                    child: Text(
                      'Please Signup to continue',
                      style: SafeGoogleFont(
                        'Poppins',
                        color: const Color(0xFFAEAEAE),
                        fontSize: constraints.maxWidth * 0.02,
                        fontWeight: FontWeight.w300,
                        height: 1,
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * 0.34,
                    top: constraints.maxHeight * 0.22,
                    child: Container(
                      width: constraints.maxWidth * 0.36,
                      height: constraints.maxHeight * 0.07,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF262626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9.14)),
                        ),
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Color(0xFFAEAEAE)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
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
                        color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * 0.34,
                    top: constraints.maxHeight * 0.31,
                    child: Container(
                      width: constraints.maxWidth * 0.17,
                      height: constraints.maxHeight * 0.07,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF262626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9.14)),
                        ),
                      ),
                      child: TextFormField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          hintText: 'First name',
                          hintStyle: TextStyle(color: Color(0xFFAEAEAE)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                         validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your first name';
                              }

                              if (value.length < 3) {
                                return 'At least three letters';
                                          }

                              return null;
                            },
                            onSaved: (value) => _firstName = value!,
                        style: SafeGoogleFont(
                        'Poppins',
                        color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * 0.53,
                    top: constraints.maxHeight * 0.31,
                    child: Container(
                      width: constraints.maxWidth * 0.17,
                      height: constraints.maxHeight * 0.07,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF262626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9.14)),
                        ),
                      ),
                      child: TextFormField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          hintText: 'Last name',
                          hintStyle: TextStyle(color: Color(0xFFAEAEAE)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your last name';
                              }

                              if (value.length < 3) {
                                return 'At least three letters';
                                          }

                              return null;
                            },
                            onSaved: (value) => _lastName = value!,
                       style: SafeGoogleFont(
                        'Poppins',
                        color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * 0.34,
                    top: constraints.maxHeight * 0.40,
                    child: Container(
                      width: constraints.maxWidth * 0.36,
                      height: constraints.maxHeight * 0.07,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF262626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9.14)),
                        ),
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Color(0xFFAEAEAE)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                         validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
                        }

                        if (value.length < 8) {
                          return 'The weak password must be at least 8 words or numbers';
                        }

                        return null;
                      },
                      onSaved: (value) => _password = value!,
                       style: SafeGoogleFont(
                        'Poppins',
                        color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * 0.34,
                    top: constraints.maxHeight * 0.49,
                    child: Container(
                      width: constraints.maxWidth * 0.36,
                      height: constraints.maxHeight * 0.07,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF262626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9.14)),
                        ),
                      ),
                      child: TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(color: Color(0xFFAEAEAE)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                          validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (passwordController.text != confirmPasswordController.text) {
                          return "Password does not match";
                        }

                        return null;
                      },
                      onSaved: (value) => _confirmPassword = value!,
                        style: SafeGoogleFont(
                        'Poppins',
                        color: Colors.white),
                      ),
                    ),
                  ),
                 Positioned(
  left: constraints.maxWidth * 0.34,
  top: constraints.maxHeight * 0.58,
  child: Container(
    width: constraints.maxWidth * 0.36,
    height: constraints.maxHeight * 0.07,
    decoration: const ShapeDecoration(
      color: Color(0xFF262626),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(9.14)),
      ),
    ),
    child: Row(
      children: [
        SizedBox(
          width: constraints.maxWidth * 0.1, // عرض مناسب لقائمة رمز الدولة
          child: DropdownButtonFormField<String>(
            value: _selectedCountryCode,
            hint: const Text(
              '+20',
              style: TextStyle(color: Color(0xffaeaeae)),
            ),
            items: <String>['+1', '+20', '+44', '+91'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: SafeGoogleFont(
                        'Poppins',
                        color: Color(0xffaeaeae)),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedCountryCode = newValue;
              });
            },
            dropdownColor: const Color(0xFF262626),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            ),
            style: SafeGoogleFont(
                        'Poppins',
              fontSize: constraints.maxWidth * 0.017,
              fontWeight: FontWeight.w300,
              height: 1,
              color: const Color(0xffaeaeae),
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Phone',
              hintStyle: TextStyle(color: Color(0xFFAEAEAE)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your phone number';
                              }

                              if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                                return 'Please enter a valid phone number';
                              }

                              return null;
                            },
            onSaved: (value) => _mobilePhone = value!,
            style: SafeGoogleFont(
                        'Poppins',
              color: Colors.white,
              fontSize: constraints.maxWidth * 0.017,
              fontWeight: FontWeight.w300,
              height: 1,
            ),
          ),
        ),
      ],
    ),
  ),
),

                Positioned(
                          left: constraints.maxWidth * 0.40,
                          top: constraints.maxHeight * 0.68,
                          child: InkWell(
                            onTap: () => _signUpWithUsernameAndEmailAndPassword(context),
                            child: Container(
                              width: constraints.maxWidth * 0.25,
                              height: constraints.maxHeight * 0.1,
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
                                    fontSize: constraints.maxWidth * 0.033,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                  Positioned(
                    left: constraints.maxWidth * 0.35,
                    top: constraints.maxHeight * 0.80,
                    child: Text(
                      'already have an account?',
                      style: SafeGoogleFont(
                        'Poppins',
                        color: const Color(0xFFAEAEAE),
                        fontSize: constraints.maxWidth * 0.018,
                        fontWeight: FontWeight.w300,
                        height: 1,
                      ),
                    ),
                  ),
                 Positioned(
  left: constraints.maxWidth * 0.59,
  top: constraints.maxHeight * 0.80,
  child: InkWell(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
      // ضع هنا الوظيفة التي تريد تنفيذها عند الضغط على الزر
    },
    child: Text(
      'Click here',
      style: SafeGoogleFont(
                        'Poppins',
        color: const Color(0xFF11A3F8),
        fontSize: constraints.maxWidth * 0.02,
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
              );
            },
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
