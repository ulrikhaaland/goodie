import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadImageToFirebaseStorage(File imageFile, String path) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child(path);
  UploadTask uploadTask = ref.putFile(imageFile);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
  String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  return downloadUrl;
}
