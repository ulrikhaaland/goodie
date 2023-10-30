import 'dart:io';
import 'dart:ui';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

import '../model/restaurant.dart';

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

// ignore: must_be_immutable
class GoodieAsset extends AssetEntity {
  AssetEntity asset;
  double? scale;
  Offset? offset;
  File? imageFile;
  Restaurant? restaurant;
  VideoPlayerController? videoPlayerController;

  @override
  Duration get videoDuration => Duration(
      seconds: asset.duration == 0
          ? videoPlayerController?.value.duration.inSeconds ?? 0
          : asset.duration);

  GoodieAsset({
    required this.asset,
    this.imageFile,
    this.videoPlayerController,
  }) : super(
          id: asset.id,
          typeInt: asset.typeInt,
          width: asset.width,
          height: asset.height,
          duration: asset.duration,
        );
}

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

Future<List<GoodieAsset>> loadRecentImages() async {
  List<GoodieAsset> recentImages = [];
  List<GoodieAsset> failedVideos =
      []; // List to store videos that failed to initialize

  try {
    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(onlyAll: true);
    final AssetPathEntity recentPath = paths.first;
    final value = await recentPath.getAssetListRange(start: 0, end: 100);
    recentImages = value.map((e) => GoodieAsset(asset: e)).toList();

    final videos = recentImages
        .where((media) => media.asset.type == AssetType.video)
        .toList()
      ..shuffle();

    for (int i = 0; i < videos.length; i++) {
      try {
        final vid = videos[i];
        final controller = await _handleInitVideoController(vid);
        vid.videoPlayerController = controller;
      } catch (e) {
        print("Error initializing controller for video at index $i: $e");

        // Add failed video to the failedVideos list
        failedVideos.add(videos[i]);
      }
    }
  } catch (e) {
    print("Error loading recent images: $e");
  }

  // Remove the videos that failed to initialize from the recentImages list
  recentImages =
      recentImages.where((element) => !failedVideos.contains(element)).toList();

  return recentImages;
}

Future<List<GoodieAsset>> refreshRecentImages(
    List<GoodieAsset> existingImages) async {
  List<GoodieAsset> updatedImages = [];
  List<GoodieAsset> failedVideos =
      []; // List to store videos that failed to initialize

  try {
    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(onlyAll: true);
    final AssetPathEntity recentPath = paths.first;
    final List<GoodieAsset> newRecentImages = await recentPath
        .getAssetListRange(start: 0, end: 100)
        .then((value) => value.map((e) => GoodieAsset(asset: e)).toList());

    final Set<String> existingIds =
        existingImages.map((e) => e.asset.id).toSet();
    final List<GoodieAsset> trulyNewImages = newRecentImages
        .where((e) => !existingIds.contains(e.asset.id))
        .toList();

    final trulyNewVideos = trulyNewImages
        .where((media) => media.asset.type == AssetType.video)
        .toList();

    for (final vid in trulyNewVideos) {
      try {
        vid.videoPlayerController = await _handleInitVideoController(vid);
      } catch (e) {
        print(
            "Error initializing controller for video with id ${vid.asset.id}: $e");

        // Add failed video to the failedVideos list
        failedVideos.add(vid);
      }
    }

    if (trulyNewImages.isNotEmpty) {
      updatedImages = [...trulyNewImages, ...existingImages];
    } else {
      updatedImages = existingImages;
    }
  } catch (e) {
    print("Error refreshing recent images: $e");
  }

  // Remove the videos that failed to initialize from the updatedImages list
  updatedImages = updatedImages
      .where((element) => !failedVideos.contains(element))
      .toList();

  return updatedImages;
}

Future<VideoPlayerController?> _handleInitVideoController(
    GoodieAsset asset) async {
  final File? file;

  if (asset.duration > 60) {
    String inputPath =
        asset.relativePath!; // Replace this with actual input file path
    String outputPath =
        "$inputPath-trimmed.mp4"; // Replace this with actual output file path
    final trimmedVideoFile = await trimVideo(
      inputPath,
      outputPath,
      0,
      60000,
    ); // Trim to 60 seconds
    file = trimmedVideoFile;
  } else {
    file = await asset.originFile;

    // await videoPlayerController.initialize();
  }

  if (file == null) throw Exception("File is null");

  final videoPlayerController = VideoPlayerController.file(file);

  asset.imageFile = file;

  return videoPlayerController;
}

Future<File?> trimVideo(
    String inputPath, String outputPath, int startMs, int endMs) async {
  // Build the ffmpeg command for video trimming
  final String command =
      '-ss ${startMs / 1000.0} -to ${endMs / 1000.0} -accurate_seek -i $inputPath -c copy $outputPath';

  // Execute the ffmpeg command
  File? videoFile = await FFmpegKit.execute(command).then((session) async {
    final returnCode = await session.getReturnCode();

    // Check the return code to determine success or failure
    if (ReturnCode.isSuccess(returnCode)) {
      print("Trim video was successful");

      return File(outputPath);
    } else {
      print("Trim video failed");
      return null;
    }
  });

  return videoFile;
}
