import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../model/constant.dart';

class CloudStorageController {
  static Future<Map<ArgKey, String>> uploadPhotoFile({
    required File photo,
    String? filename,
    required String uid,
    required Function listener,
  }) async {
    filename ??= '${Constant.photoFileFolder}/$uid/${const Uuid().v1()}';
    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    task.snapshotEvents.listen((TaskSnapshot event) {
      int progress = (event.bytesTransferred / event.totalBytes * 100).toInt();
      listener(progress);
    });

    TaskSnapshot snapshot = await task;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return {
      ArgKey.downloadURL: downloadURL,
      ArgKey.filename: filename,
    };
  }

  static Future<void> deleteFile({
    required String filename,
  }) async {
    await FirebaseStorage.instance.ref().child(filename).delete();
  }

  static Future<Map<ArgKey, String>> uploadComment({
    required String comment,
    String? filename,
    required String uid,
    required Function listener,
  }) async {
    filename ??= '${Constant.photoFileFolder}/$uid/${const Uuid().v1()}';
    UploadTask task = FirebaseStorage.instance.ref(filename).putString(comment);
    task.snapshotEvents.listen((TaskSnapshot event) {
      int progress = (event.bytesTransferred / event.totalBytes * 100).toInt();
      listener(progress);
    });
    TaskSnapshot snapshot = await task;
    String photoComment = await snapshot.ref.name;
    return {
      ArgKey.comment: photoComment,
      ArgKey.filename: filename,
    };
  }
}
