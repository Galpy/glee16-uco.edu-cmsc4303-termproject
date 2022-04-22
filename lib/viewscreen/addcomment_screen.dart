import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/auth_controller.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';

import '../model/photo_memo.dart';

class AddCommentScreen extends StatefulWidget {
  static const routeName = '/addCommentScreen';
  final User user;
  final List<Comments> commentList;
  final String photoDocId;

  const AddCommentScreen(
      {required this.photoDocId,
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
  final ScrollController _scrollController = ScrollController();
  var formKey = GlobalKey<FormState>();
  late _Controller con;
  late final User user;
  String? comment;
  late final List<Comments> newCommentList;
  List<Comments> items = [];
  bool loading = false, allLoaded = false;

  @override
  void initState() {
    super.initState();
    newCommentList = widget.commentList;
    mockFetch();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !loading) {
        mockFetch();
      }
    });
    con = _Controller(this);
    user = widget.user;
  }

  mockFetch() async {
    if (allLoaded) {
      return;
    }
    setState(() {
      loading = true;
    });

    List<Comments> newData = items.length >= newCommentList.length
        ? []
        : newCommentList.length < 8
            ? List<Comments>.generate(
                newCommentList.length,
                (index) => index <= newCommentList.length
                    ? newCommentList[index]
                    : newCommentList[index + items.length],
                growable: false)
            : List<Comments>.generate(
                8,
                (index) => index <= newCommentList.length
                    ? newCommentList[index]
                    : newCommentList[index + items.length],
                growable: false);
    if (newData.isNotEmpty) {
      items.addAll(newData);
    }
    setState(() {
      loading = false;
      allLoaded = newData.isEmpty;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        actions: [
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: TextFormField(
                  decoration: const InputDecoration(hintText: 'Add Comment'),
                  autocorrect: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                  validator: con.validateComment,
                  onSaved: con.saveComment,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: con.save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          if (items.isNotEmpty) {
            return Stack(
              children: [
                ListView.separated(
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      if (index < newCommentList.length) {
                        return ListTile(
                          title: Container(
                            margin: const EdgeInsets.all(10.0),
                            child: ListTile(
                              tileColor: Colors.white,
                              title: Text(newCommentList[index].comment),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Created By: ${newCommentList[index].createdBy}'),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(
                          width: constraints.maxWidth,
                          height: 50,
                          child: const Center(
                            child: Text("Nothing more to load"),
                          ),
                        );
                      }
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 1,
                      );
                    },
                    itemCount: newCommentList.length + (allLoaded ? 1 : 0)),
                if (loading) ...[
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: 80,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ],
              ],
            );
          } else {
            return const Text("No Comments available!");
          }
        }),
      ),
      // body: con.commentList.isEmpty
      //     ? Text(
      //         'No Comments found!',
      //         style: Theme.of(context).textTheme.headline6,
      //       )
      //     : PaginateFirestore(
      //         itemsPerPage: 4,
      //         query: FirebaseFirestore.instance
      //             .collection(Constant.commentCollection)
      //             .orderBy(DocKeyComments.createdBy.name)
      //             .limit(con.commentList.length),
      //         itemBuilderType: PaginateBuilderType.listView,
      //         itemBuilder: (context, commentList, index) => Container(
      //           margin: const EdgeInsets.all(10.0),
      //           child: ListTile(
      //             tileColor: Colors.white,
      //             title: Text(con.commentList[index].comment),
      //             subtitle: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Text('Created By: ${con.commentList[index].createdBy}'),
      //               ],
      //             ),
      //           ),
      //         ),
      //         isLive: true,
      //       ),
    );
  }
}

class _Controller {
  _AddCommentState state;
  String? progressMessage;
  late List<Comments> commentList;
  Comments tempComment = Comments();
  _Controller(this.state) {
    commentList = state.widget.commentList;
  }

  void sharedWith() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FireStoreController.getPhotoMemoListSharedWithMe(
        email: state.user.email!,
      );
      await Navigator.pushNamed(
        state.context,
        SharedWithScreen.routeName,
        arguments: {
          ArgKey.photoMemoList: photoMemoList,
          ArgKey.user: state.widget.user,
        },
      );
      Navigator.of(state.context).pop();
    } catch (e) {
      if (Constant.devMode) print('========== get SharedWith list error: $e');
      showSnackBar(
        context: state.context,
        message: 'Failed to get SharedWith list: $e',
      );
    }
  }

  void save() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();
    if (state.comment == null) {
      showSnackBar(
        context: state.context,
        seconds: 20,
        message: 'Comment is empty',
      );
    }

    try {
      Map result = await CloudStorageController.uploadComment(
        comment: state.comment!,
        uid: state.user.uid,
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
      tempComment.comment = state.comment!;
      tempComment.photoDocId = state.widget.photoDocId;
      tempComment.createdBy = state.widget.user.email!;
      tempComment.timeStamp = DateTime.now();

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
    state.render(() {});
    state.mockFetch();
  }

  Future<void> signOut() async {
    try {
      await AuthController.signout();
    } catch (e) {
      if (Constant.devMode) print('============== Sign out Error: $e');
      showSnackBar(context: state.context, message: 'Sign out Error: $e');
    }
    Navigator.of(state.context).pop();
    Navigator.of(state.context).pop();
  }

  String? validateComment(String? value) {
    return (value == null) ? 'Comment is empty' : null;
  }

  void saveComment(String? value) {
    if (value != null) state.comment = value;
  }
}
