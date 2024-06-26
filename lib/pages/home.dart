import 'package:dermaleens/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = false;
  String _progress = "";

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void _launchURL() async {
    var fileId = "1Sf32wSo1BZoBOVIFCYMir8rwlM69dC02";
    var downloadUrl = "https://drive.google.com/uc?export=download&id=$fileId";

    try {
      if (await canLaunch(downloadUrl)) {
        await launch(downloadUrl);
      } else {
        throw 'Could not launch $downloadUrl';
      }
    } catch (e) {
      print('Error launching URL: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to launch URL. Please try again later.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Color(0xFF191919)),
          child: Stack(
            children: [
              Positioned(
                left: screenWidth * 0.20,
                top: screenHeight * 0.50,
                child: InkWell(
                   onTap: _isLoading ? null : _launchURL,
                  child: Container(
                    width: screenWidth * 0.60,
                    height: screenHeight * 0.15,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1D1D1D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.14),
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? Text(
                              _progress,
                              style: SafeGoogleFont(
                                'Poppins',
                                color: const Color(0xFFAEAEAE),
                                fontSize: screenHeight * 0.05,
                                fontWeight: FontWeight.w300,
                                height: 1.0,
                              ),
                            )
                          : Text(
                              'Download',
                              style: SafeGoogleFont(
                                'Poppins',
                                color: const Color(0xFFAEAEAE),
                                fontSize: screenHeight * 0.05,
                                fontWeight: FontWeight.w300,
                                height: 1.0,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: screenWidth * 0.40,
                top: screenHeight * 0.05,
                child: SizedBox(
                  width: screenWidth * 0.20,
                  height: screenHeight * 0.35,
                  child: Image.asset(
                    'assets/page-1/images/dermalens-icon.png',
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
              Positioned(
                left: screenWidth * 0.20,
                top: screenHeight * 0.72,
                child: InkWell(
                  onTap: () async {
                    try {
                      _toggleLoading(); // بداية التحميل
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        'login',
                        (route) => false,
                      );
                    } catch (e) {
                      print('Error signing out: $e');
                      // Handle any errors that might occur during the sign-out process
                    } finally {
                      _toggleLoading(); // نهاية التحميل
                    }
                  },
                  child: Container(
                    width: screenWidth * 0.60,
                    height: screenHeight * 0.15,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1D1D1D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.14),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Log out',
                        style: SafeGoogleFont(
                          'Poppins',
                          color: const Color(0xFFAEAEAE),
                          fontSize: screenHeight * 0.05,
                          fontWeight: FontWeight.w300,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                Center(
                  child: TweenAnimationBuilder(
                    duration: const Duration(seconds: 1),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return Transform.rotate(
                        angle: value * 2 * 3.141,
                        child: Image.asset(
                          'assets/page-1/images/ellipse-2-EMc.png',
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
