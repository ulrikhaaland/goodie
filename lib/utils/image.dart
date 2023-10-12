import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:goodie/bloc/create_review_provider.dart';
import 'package:video_player/video_player.dart';

class MediaItem {
  final int index;
  final String url;
  final MediaType type;
  VideoPlayerController? videoPlayerController;
  final Reference? ref;

  MediaItem({
    required this.index,
    required this.url,
    required this.type,
    this.ref,
  });
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

bool isValidUrl(String url) {
  final Uri? uri = Uri.tryParse(url);
  return uri != null && uri.scheme.isNotEmpty && uri.host.isNotEmpty;
}


// Future<bool> isValidImageData(Uint8List bytes) async {
//   try {
//     await ui.instantiateImageCodec(bytes);
//     return true;
//   } catch (e) {
//     return false;
//   }
// }
