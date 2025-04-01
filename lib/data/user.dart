import 'package:image_picker/image_picker.dart';

class AppUser {
  String userName;
  String email;
  String password;
  int birthDate;
  int phoneNumber;
  String id;
  XFile profileImage;

  AppUser(this.userName, this.email, this.password, this.birthDate,
      this.phoneNumber, this.id, this.profileImage);
}