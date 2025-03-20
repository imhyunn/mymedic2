import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mymedic1/screens/home/home_screen.dart';
import 'package:mymedic1/screens/myapp.dart';
import 'package:mymedic1/screens/sign/signup_screen.dart';
import '../../config/palette.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class Test{

}
class _LoginScreenState extends State<LoginScreen> {
  final _authentication = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  String userEmail = '';
  String userPassword = '';
  late Test test;

  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //로고
            Container(
              height: 130,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo_black.png'),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),

            //텍스트폼
            Container(
              width: MediaQuery.of(context).size.width - 60,
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              key: ValueKey(1),
                              validator: (value) {
                                if (value!.isEmpty || !value.contains('@')) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                userEmail = value!;
                              },
                              onChanged: (value) {
                                userEmail = value;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Palette.textColor1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Palette.textColor1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                    fontSize: 14, color: Palette.textColor1),
                                hintText: 'Enter your Email',
                                hintStyle: TextStyle(
                                    fontSize: 14, color: Palette.textColor1),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              obscureText: true,
                              key: ValueKey(2),
                              validator: (value) {
                                if (value!.isEmpty || value.length < 6) {
                                  return 'Password must be at least 7 characters long.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                userPassword = value!;
                              },
                              onChanged: (value) {
                                userPassword = value;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Palette.textColor1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Palette.textColor1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                    fontSize: 14, color: Palette.textColor1),
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(
                                    fontSize: 14, color: Palette.textColor1),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            //전송버튼
            GestureDetector(
              onTap: () async {
                _tryValidation();

                try {
                  final newUser =
                      await _authentication.signInWithEmailAndPassword(
                    email: userEmail,
                    password: userPassword,
                  );
                  if (newUser.user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return App();
                        },
                      ),
                    );
                  }
                } catch (e) {
                  print(e);
                }
              },
              child: Container(
                padding: EdgeInsets.all(15),
                height: 60,
                width: MediaQuery.of(context).size.width - 60,
                margin: EdgeInsets.symmetric(horizontal: 30.0),
                decoration: BoxDecoration(
                  color: Color(0xE61D4097),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: const Center(
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            //선
            // Container(
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 25.0),
            //     child: Row(
            //       children: [
            //         Expanded(
            //           child: Divider(
            //             thickness: 0.5,
            //             color: Colors.grey[400],
            //           ),
            //         ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    //   child: Text(
                    //     'Or continue with',
                    //     style: TextStyle(color: Colors.grey[700]),
                    //   ),
                    // ),
                    // Expanded(
                    //   child: Divider(
                    //     thickness: 0.5,
                    //     color: Colors.grey[400],
                    //   ),
                    // ),
            //       ],
            //     ),
            //   ),
            // ),
            // SizedBox(
            //   height: 30,
            // ),
            // //구글애플
            // Container(
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Container(
            //         child: InkWell(
            //           onTap: () {},
            //           child: Padding(
            //             padding: EdgeInsets.all(6),
            //             child: Image.asset(
            //               "assets/images/google.png",
            //               width: 40,
            //               height: 40,
            //             ),
            //           ),
            //         ),
            //       ),
            //       SizedBox(
            //         width: 50,
            //       ),
            //       Container(
            //         child: InkWell(
            //           onTap: () {},
            //           child: Padding(
            //             padding: EdgeInsets.all(6),
            //             child: Image.asset(
            //               "assets/images/apple.png",
            //               width: 40,
            //               height: 40,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(
            //   height: 30,
            // ),
            //회원가입버튼
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '계정이 없으신가요?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext) => SignupScreen(),
                        ),
                      );
                    },
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
