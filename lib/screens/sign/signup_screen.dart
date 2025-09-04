import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mymedic1/screens/home/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymedic1/config/palette.dart';
import 'package:mymedic1/screens/myapp.dart';

import '../../data/user.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _authentication = FirebaseAuth.instance;

  bool showSpinner = false;
  final _formKey = GlobalKey<FormState>();
  List<AppUser> users = [];

  String userName = '';
  String userEmail = '';
  String userPassword = '';
  String userBirthDate = '';
  String userPhoneNumber = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  Future<void> _tryValidation() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //로고
              Container(
                height: 135,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo_black.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),

              //텍스트폼
              Container(
                width: MediaQuery.of(context).size.width - 60,
                margin: EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    Container(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 335,
                              height: 55,
                              child: TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.emailAddress,
                                key: ValueKey(3),
                                validator: (value) {
                                  if (value!.isEmpty || value.length < 4) {
                                    return 'Please enter at least 4 characters';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  userName = value!;
                                },
                                onChanged: (value) {
                                  userName = value;
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
                                  labelText: 'Name',
                                  labelStyle: TextStyle(
                                      fontSize: 14, color: Palette.textColor1),
                                  hintText: '이름을 입력해주세요.',
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Palette.textColor1),
                                ),
                              ),
                            ),
                            //name
                            SizedBox(
                              height: 10,
                            ),

                            SizedBox(
                              width: 335,
                              height: 55,
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                key: ValueKey(7),
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
                                  hintText: '이메일을 입력해주세요.',
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Palette.textColor1),
                                ),
                              ),
                            ),
                            //email
                            SizedBox(
                              height: 10,
                            ),

                            SizedBox(
                              width: 335,
                              height: 55,
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                key: ValueKey(8),
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
                                  hintText: '비밀번호를 입력해주세요.',
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Palette.textColor1),
                                ),
                              ),
                            ),
                            //password
                            SizedBox(
                              height: 10,
                            ),

                            SizedBox(
                              width: 335,
                              height: 55,
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                key: ValueKey(8),
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      _confirmPasswordController.text !=
                                          _passwordController.text) {
                                    return 'confirm password.';
                                  }
                                  return null;
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
                                  labelText: 'ConfirmPassword',
                                  labelStyle: TextStyle(
                                      fontSize: 14, color: Palette.textColor1),
                                  hintText: '비밀번호를 입력해주세요.',
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Palette.textColor1),
                                ),
                              ),
                            ),
                            //password
                            SizedBox(
                              height: 10,
                            ),

                            SizedBox(
                              width: 335,
                              height: 55,
                              child: TextFormField(
                                controller: _birthDateController,
                                keyboardType: TextInputType.emailAddress,
                                key: ValueKey(4),
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      value.length > 8 ||
                                      value.length < 8) {
                                    return 'birth date.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  userBirthDate = value!;
                                },
                                onChanged: (value) {
                                  userBirthDate = value;
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
                                  labelText: 'birth date',
                                  labelStyle: TextStyle(
                                      fontSize: 14, color: Palette.textColor1),
                                  hintText: '생년월일을 입력해주세요. (YYYYMMDD)',
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Palette.textColor1),
                                ),
                              ),
                            ),
                            //birth date
                            SizedBox(
                              height: 10,
                            ),

                            SizedBox(
                              width: 335,
                              height: 55,
                              child: TextFormField(
                                controller: _phoneNumberController,
                                key: ValueKey(5),
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      value.length < 11 ||
                                      value.length > 11) {
                                    return 'Phone number must be at least 11 characters long.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  userPhoneNumber = value!;
                                },
                                onChanged: (value) {
                                  userPhoneNumber = value;
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
                                  labelText: 'phone number',
                                  labelStyle: TextStyle(
                                      fontSize: 14, color: Palette.textColor1),
                                  hintText: '전화번호를 입력해주세요.',
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Palette.textColor1),
                                ),
                              ),
                            ),
                            //phone number
                            SizedBox(
                              height: 10,
                            ),

                            // SizedBox(
                            //   width: 335,
                            //   height: 55,
                            //   child: TextFormField(
                            //     key: ValueKey(6),
                            //     validator: (value) {
                            //       if (value!.isEmpty ||
                            //           value.length < 11 ||
                            //           value.length > 11) {
                            //         return 'Phone number must be at least 11 characters long.';
                            //       }
                            //       return null;
                            //     },
                            //     decoration: InputDecoration(
                            //       border: OutlineInputBorder(
                            //         borderSide:
                            //             BorderSide(color: Palette.textColor1),
                            //         borderRadius: BorderRadius.all(
                            //           Radius.circular(5.0),
                            //         ),
                            //       ),
                            //       focusedBorder: OutlineInputBorder(
                            //         borderSide:
                            //             BorderSide(color: Palette.textColor1),
                            //         borderRadius: BorderRadius.all(
                            //           Radius.circular(5.0),
                            //         ),
                            //       ),
                            //       labelText: 'phone number',
                            //       labelStyle: TextStyle(
                            //           fontSize: 14, color: Palette.textColor1),
                            //       hintText: '전화번호를 입력해주세요.',
                            //       hintStyle: TextStyle(
                            //           fontSize: 14, color: Palette.textColor1),
                            //     ),
                            //   ),
                            // ), //phone number(mom)
                            // SizedBox(
                            //   height: 10,
                            // ),

                            /*SizedBox(
                              width: 335,
                              height: 55,
                              child: TextFormField(
                                obscureText: true,
                                key: ValueKey(9),
                                validator: (value) {
                                  if (value!.isEmpty || value.length < 6) {
                                    return 'Password must be at least 7 characters long.';
                                  }
                                  return null;
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
                                  labelText: 'Confirm Password',
                                  labelStyle: TextStyle(
                                      fontSize: 14, color: Palette.textColor1),
                                  hintText: '비밀번호를 한 번 더 확인해주세요.',
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Palette.textColor1),
                                ),
                              ),
                            ), //confirmpassword
                            SizedBox(
                              height: 10,
                            ),*/
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //전송버튼
              GestureDetector(
                onTap: () async {
                  _tryValidation();

                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      final newUser =
                          await _authentication.createUserWithEmailAndPassword(
                        email: userEmail,
                        password: userPassword,
                      );

                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(newUser.user!.uid)
                          .set({
                        'userName': userName,
                        'email': userEmail,
                        'password': userPassword,
                        'birthDate': userBirthDate,
                        'phoneNumber': userPhoneNumber,
                        'profileImage': 'null',
                      });

                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return App();
                            },
                          ),
                        );
                        // setState(() {
                        //   showSpinner = false;
                        // });
                      }
                    }
                    // on FirebaseAuthException catch (e) {
                    //   Navigator.pop(context);
                    // }
                    catch (e) {
                      setState(() {
                        showSpinner = false;
                      });
                      print(e);
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content:
                      //     Text('Please check your email and password'),
                      //     backgroundColor: Colors.blue,
                      //   ),
                      // );
                    }
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
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(
              //   height: 50,
              // ),
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
              //         Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 10.0),
              //           child: Text(
              //             'Or continue with',
              //             style: TextStyle(color: Colors.grey[700]),
              //           ),
              //         ),
              //         Expanded(
              //           child: Divider(
              //             thickness: 0.5,
              //             color: Colors.grey[400],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   height: 35,
              // ),
              //구글애플
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
              SizedBox(
                height: 25,
              )
            ],
          ),
        ),
      ),
    );
  }
}
