import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photo_memo.dart';

class FireStoreController {
  static Future<String> addPhotoMemo({
    required PhotoMemo photoMemo,
  }) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Constant.photoMemoCollection)
        .add(photoMemo.toFirestoreDoc());
    return ref.id;
  }

  static Future<String> createComment({
    required Comments comment,
  }) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Constant.commentCollection)
        .add(comment.toFirestoreDoc());
    return ref.id;
  }

  static Future<List<Comments>> getCommentList({
    required PhotoMemo photoMemo,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.commentCollection)
        .where(DocKeyComments.photoId.name, isEqualTo: photoMemo.docId!)
        .orderBy(
          DocKeyComments.timeStamp.name,
          descending: true,
        )
        .get();

    var result = <Comments>[];
    for (var doc in querySnapshot.docs) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var p = Comments.fromFirestoreDoc(doc: document, docId: doc.id);
        if (p != null) {
          result.add(p);
        }
      }
    }
    return result;
  }

  static Future<List<PhotoMemo>> getPhotoMemoList({
    required String email,
  }) async {
    print(DocKeyPhotoMemo.createdBy);
    print(email);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.photoMemoCollection)
        .where(DocKeyPhotoMemo.createdBy.name, isEqualTo: email)
        .orderBy(
          DocKeyPhotoMemo.timestamp.name,
          descending: true,
        )
        .get();

    var result = <PhotoMemo>[];
    for (var doc in querySnapshot.docs) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var p = PhotoMemo.fromFirestoreDoc(doc: document, docId: doc.id);
        if (p != null) {
          result.add(p);
        }
      }
    }
    return result;
  }

  static Future<void> updatePhotoMemo({
    required String docId,
    required Map<String, dynamic> update,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.photoMemoCollection)
        .doc(docId)
        .update(update);
  }

  static Future<List<PhotoMemo>> searchImages({
    required String email,
    required List<String> searchLabel,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.photoMemoCollection)
        .where(DocKeyPhotoMemo.createdBy.name, isEqualTo: email)
        .where(DocKeyPhotoMemo.imageLabels.name, arrayContainsAny: searchLabel)
        .orderBy(DocKeyPhotoMemo.timestamp.name, descending: true)
        .get();

    var result = <PhotoMemo>[];
    for (var doc in querySnapshot.docs) {
      var p = PhotoMemo.fromFirestoreDoc(
        doc: doc.data() as Map<String, dynamic>,
        docId: doc.id,
      );
      if (p != null) result.add(p);
    }
    return result;
  }

  static Future<void> deleteDoc({
    required String docId,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.photoMemoCollection)
        .doc(docId)
        .delete();
  }

  static Future<List<PhotoMemo>> getPhotoMemoListSharedWithMe({
    required String email,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.photoMemoCollection)
        .where(DocKeyPhotoMemo.sharedWith.name, arrayContains: email)
        .orderBy(
          DocKeyPhotoMemo.timestamp.name,
          descending: true,
        )
        .get();

    var result = <PhotoMemo>[];
    for (var doc in querySnapshot.docs) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var p = PhotoMemo.fromFirestoreDoc(doc: document, docId: doc.id);
        if (p != null) {
          result.add(p);
        }
      }
    }
    return result;
  }
}
