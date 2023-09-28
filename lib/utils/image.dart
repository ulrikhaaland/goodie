import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';

class MediaItem {
  final String url;
  final MediaType type;

  MediaItem({required this.url, required this.type});
}

enum MediaType { Image, Video }

Future<String> uploadAssetToFirebaseStorage(File assetFile, String path) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child(path);
  UploadTask uploadTask = ref.putFile(assetFile);
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
