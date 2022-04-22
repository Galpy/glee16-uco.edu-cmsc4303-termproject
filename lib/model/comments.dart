enum DocKeyComments {
  createdBy,
  photoDocId,
  comment,
  timeStamp,
}

class Comments {
  String? docId;
  late String createdBy; //email = user id
  late String comment;
  late String photoDocId; // image/photo at Cloud Storage
  DateTime? timeStamp;

  Comments({
    String? docId,
    this.createdBy = '',
    this.comment = '',
    this.photoDocId = '',
    this.timeStamp,
  });

  Comments.clone(Comments p) {
    createdBy = p.createdBy;
    docId = p.docId;
    comment = p.comment;
    photoDocId = p.photoDocId;
    timeStamp = p.timeStamp;
  }

  void copyFrom(Comments p) {
    createdBy = p.createdBy;
    docId = p.docId;
    comment = p.comment;
    photoDocId = p.photoDocId;
    timeStamp = p.timeStamp;
  }

  // serialization
  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyComments.comment.name: comment,
      DocKeyComments.photoDocId.name: photoDocId,
      DocKeyComments.timeStamp.name: timeStamp,
      DocKeyComments.createdBy.name: createdBy,
    };
  }

  static Comments? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    return Comments(
      docId: docId,
      createdBy: doc[DocKeyComments.createdBy.name] ??= 'N/A',
      comment: doc[DocKeyComments.comment.name] ??= 'N/A',
      photoDocId: doc[DocKeyComments.photoDocId.name] ??= 'N/A',
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
