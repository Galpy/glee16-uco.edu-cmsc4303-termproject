enum DocKeyComments {
  photoAttached,
  comment,
  photoId,
  timeStamp,
}

class Comments {
  String? docId;
  late String comment;
  late String photoId;
  DateTime? timeStamp;

  Comments({
    String? docId,
    this.comment = '',
    this.photoId = '',
    this.timeStamp,
  });

  Comments.clone(Comments p) {
    docId = p.docId;
    comment = p.comment;
    photoId = p.photoId;
    timeStamp = p.timeStamp;
  }

  void copyFrom(Comments p) {
    docId = p.docId;
    comment = p.comment;
    photoId = p.photoId;
    timeStamp = p.timeStamp;
  }

  // serialization
  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyComments.comment.name: comment,
      DocKeyComments.photoId.name: photoId,
      DocKeyComments.timeStamp.name: timeStamp,
    };
  }

  static Comments? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    return Comments(
      docId: docId,
      comment: doc[DocKeyComments.comment.name] ??= 'N/A',
      photoId: doc[DocKeyComments.photoId.name] ??= 'N/A',
      timeStamp: doc[DocKeyComments.timeStamp.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyComments.timeStamp.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
    );
  }

  static String? validateComment(String? value) {
    return (value == null || value.isEmpty) ? 'Comment too short' : null;
  }
}
