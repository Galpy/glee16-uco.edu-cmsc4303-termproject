enum PhotoSource { camera, gallery }

enum DocKeyPhotoMemo {
  createdBy,
  title,
  memo,
  photoFilename,
  photoURL,
  timestamp,
  imageLabels,
  sharedWith,
  comments
}

class PhotoMemo {
  String? docId; // Firestore auto-generated id
  late String createdBy; // email = user id
  late String title;
  late String memo;
  late String photoFilename; // image/photo at Cloud Storage
  late String photoURL; // URL of image
  DateTime? timeStamp;
  late List<dynamic> imageLabels; // ML generated image labels
  late List<dynamic> sharedWith; // list of emails
  late List<dynamic> comments;

  PhotoMemo({
    this.docId,
    this.createdBy = '',
    this.title = '',
    this.memo = '',
    this.photoFilename = '',
    this.photoURL = '',
    this.timeStamp,
    List<dynamic>? imageLabels,
    List<dynamic>? sharedWith,
    List<dynamic>? comments,
  }) {
    this.imageLabels = imageLabels == null ? [] : [...imageLabels];
    this.sharedWith = sharedWith == null ? [] : [...sharedWith];
    this.comments = comments == null ? [] : [...comments];
  }

  PhotoMemo.clone(PhotoMemo p) {
    docId = p.docId;
    createdBy = p.createdBy;
    title = p.title;
    memo = p.memo;
    photoFilename = p.photoFilename;
    photoURL = p.photoURL;
    timeStamp = p.timeStamp;
    sharedWith = [...p.sharedWith];
    imageLabels = [...p.imageLabels];
    comments = [...p.comments];
  }

  // a.copyFrom(b) ==> a = b
  void copyFrom(PhotoMemo p) {
    docId = p.docId;
    createdBy = p.createdBy;
    title = p.title;
    memo = p.memo;
    photoFilename = p.photoFilename;
    photoURL = p.photoURL;
    timeStamp = p.timeStamp;
    sharedWith.clear();
    sharedWith.addAll(p.sharedWith);
    imageLabels.clear();
    imageLabels.addAll(p.imageLabels);
    comments.clear();
    comments.addAll(p.comments);
  }

  // serialization
  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyPhotoMemo.title.name: title,
      DocKeyPhotoMemo.createdBy.name: createdBy,
      DocKeyPhotoMemo.memo.name: memo,
      DocKeyPhotoMemo.photoFilename.name: photoFilename,
      DocKeyPhotoMemo.photoURL.name: photoURL,
      DocKeyPhotoMemo.timestamp.name: timeStamp,
      DocKeyPhotoMemo.sharedWith.name: sharedWith,
      DocKeyPhotoMemo.imageLabels.name: imageLabels,
      DocKeyPhotoMemo.comments.name: comments,
    };
  }

  // deserialization
  static PhotoMemo? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    return PhotoMemo(
      docId: docId,
      createdBy: doc[DocKeyPhotoMemo.createdBy.name] ??= 'N/A',
      title: doc[DocKeyPhotoMemo.title.name] ??= 'N/A',
      memo: doc[DocKeyPhotoMemo.memo.name] ??= 'N/A',
      photoFilename: doc[DocKeyPhotoMemo.photoFilename.name] ??= 'N/A',
      photoURL: doc[DocKeyPhotoMemo.photoURL.name] ??= 'N/A',
      sharedWith: doc[DocKeyPhotoMemo.sharedWith.name] ??= [],
      imageLabels: doc[DocKeyPhotoMemo.imageLabels.name] ??= [],
      comments: doc[DocKeyPhotoMemo.comments.name] ??= [],
      timeStamp: doc[DocKeyPhotoMemo.timestamp.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyPhotoMemo.timestamp.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
    );
  }

  static String? validateTitle(String? value) {
    return (value == null || value.trim().length < 3)
        ? 'Title too short'
        : null;
  }

  static String? validateMemo(String? value) {
    return (value == null || value.trim().length < 5) ? 'Memo too short' : null;
  }

  static String? validateSharedWith(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    List<String> emailList =
        value.trim().split(RegExp('(,|;| )+')).map((e) => e.trim()).toList();
    for (String e in emailList) {
      if (e.contains('@') && e.contains('.')) {
        continue;
      } else {
        return 'Invalid email address found: comma, semicolon. space separated list';
      }
    }
  }

  static String? validateComment(String? value) {
    return (value == null || value.isEmpty) ? 'Comment too short' : null;
  }
}
