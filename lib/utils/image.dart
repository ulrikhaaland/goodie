import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

class MediaItem {
  final String url;
  final MediaType type;
  VideoPlayerController? videoController;
  final Reference? ref;

  MediaItem({required this.url, required this.type, this.ref});
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
