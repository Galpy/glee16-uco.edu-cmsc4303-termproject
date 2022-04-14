import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photo_memo.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class AddCommentScreen extends StatefulWidget {
  static const routeName = '/addCommentScreen';
  final User user;
  final List<Comments> commentList;
  final PhotoMemo photoMemo;

  const AddCommentScreen(
      {required this.photoMemo,
      required this.user,
      required this.commentList,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddCommentState();
  }
}

class _AddCommentState extends State<AddCommentScreen> {
  var formKey = GlobalKey<FormState>();
  late _Controller con;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Comment Screen'),
      ),
      body: con.commentList.isEmpty
          ? Text(
              'No Comments Found!',
              style: Theme.of(context).textTheme.headline6,
            )
          : Column(
              children: [
                PaginateFirestore(
                  itemsPerPage: 4,
                  query: FirebaseFirestore.instance
                      .collection(Constant.commentCollection)
                      .orderBy(DocKeyComments.comment)
                      .limit(Constant.commentCollection.length),
                  itemBuilderType: PaginateBuilderType.listView,
                  itemBuilder: (context, commentList, index) => Container(
                    margin: const EdgeInsets.all(10.0),
                    child: ListTile(
                      tileColor: Colors.white,
                      title: Column(
                        children: [
                          Text(con.commentList[index].comment),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Created By: ${con.commentList[index].timeStamp}'),
                        ],
                      ),
                    ),
                  ),
                  isLive: true,
                ),
                Column(
                  children: [
                    Text(
                      'Add A Comment',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(hintText: 'Enter Comment'),
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      validator: con.validateComment,
                      onSaved: con.saveComment,
                    ),
                    ElevatedButton(
                      onPressed: con.addComment,
                      child: Text(
                        'Comment',
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}

class _Controller {
  _AddCommentState state;
  String? comment;
  String? progressMessage;
  late List<Comments> commentList;
  Comments tempComment = Comments();
  _Controller(this.state);

  void addComment() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;

    currentState.save();
    if (comment == null) {
      showSnackBar(
        context: state.context,
        seconds: 20,
        message: 'Comment is empty',
      );
      return;
    }

    try {
      Map result = await CloudStorageController.uploadComment(
        comment: comment!,
        uid: state.widget.user.uid,
        listener: (int progress) {
          state.render(() {
            if (progress == 100) {
              progressMessage = null;
            } else {
              progressMessage = 'Uploading: $progress %';
            }
          });
        },
      );
      tempComment.comment = result[ArgKey.comment];
      tempComment.photoId = result[state.widget.photoMemo.docId];
      String docId =
          await FireStoreController.createComment(comment: tempComment);
      tempComment.docId = docId;

      state.widget.commentList.insert(0, tempComment);
    } catch (e) {
      if (Constant.devMode) print('=============== add comment failed: $e');
      showSnackBar(
        context: state.context,
        seconds: 20,
        message: 'Cannot add Comment: $e',
      );
    }
  }

  String? validateComment(String? value) {
    if (value == null) return 'Comment is empty';
  }

  void saveComment(String? value) {
    comment = value;
  }
}
