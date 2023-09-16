import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadImageToFirebaseStorage(File imageFile, String path) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child(path);
  UploadTask uploadTask = ref.putFile(imageFile);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
  String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  return downloadUrl;
}

// Future<bool> isValidImageData(Uint8List bytes) async {
//   try {
//     await ui.instantiateImageCodec(bytes);
//     return true;
//   } catch (e) {
//     return false;
//   }
// }
