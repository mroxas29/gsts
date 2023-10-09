import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? email;
  final String? password;
  /* final String? email;
  final bool? phonenumber;
  final List<String>? courses;
*/
  User({
    this.email,
    this.password,
    /* this.email,
    this.phonenumber,
    this.courses,
  */
  });

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return User(
      email: data?['email'],
      password: data?['password'],
      /*  email: data?['email'],
      phonenumber: data?['phonenumber'],
      courses:
          data?['courses'] is Iterable ? List.from(data?['courses']) : null,
    */
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) "email": email,
      if (password != null) "password": password,
      /* if (email != null) "email": email,
      if (phonenumber != null) "phonenumber": phonenumber,
      if (courses != null) "courses": courses,
    */
    };
  }
}
