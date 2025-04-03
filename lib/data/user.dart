import 'package:image_picker/image_picker.dart';

class AppUser {
  String userName;
  String email;
  String password;
  String birthDate;
  String phoneNumber;
  String id;
  String profileImagePath;

  AppUser(this.userName, this.email, this.password, this.birthDate,
      this.phoneNumber, this.id, this.profileImagePath);
}