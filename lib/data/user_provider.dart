import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymedic1/data/user.dart';

class UserProvider with ChangeNotifier {
  AppUser? _appUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter: 외부에서 appUser 가져오기
  AppUser? get appUser => _appUser;

  // Firebase에서 유저 데이터 가져오기
  Future<void> fetchUserData(String uid) async {
    var snap = await _firestore.collection('user').doc(uid).get();
    if (snap.exists) {
      _appUser = AppUser(
        snap['userName'],
        snap['email'],
        snap['password'],
        snap['birthDate'],
        snap['phoneNumber'],
        snap.id,
        snap['profileImagePath'],
      );
      notifyListeners(); // UI 업데이트
    }
  }
}
