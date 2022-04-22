//import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/auth_controller.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photo_memo.dart';
import 'package:lesson3/viewscreen/addphotomemo_screen.dart';
import 'package:lesson3/viewscreen/detailedview_screen.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';
  const UserHomeScreen(
      {required this.user, required this.photoMemoList, Key? key})
      : super(key: key);

  final User user;
  final List<PhotoMemo> photoMemoList;

  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  late _Controller con;
  late final String email;
  late final List<PhotoMemo> newList;
  var formKey = GlobalKey<FormState>();
  List<PhotoMemo> items = [];
  bool loading = false, allLoaded = false;

  @override
  void initState() {
    super.initState();
    newList = widget.photoMemoList;
    mockFetch();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !loading) {
        mockFetch();
      }
    });
    con = _Controller(this);
    email = widget.user.email ?? ' No email';
  }

  mockFetch() async {
    if (allLoaded) {
      return;
    }
    setState(() {
      loading = true;
    });

    List<PhotoMemo> newData = items.length >= newList.length
        ? []
        : newList.length < 8
            ? List<PhotoMemo>.generate(
                newList.length,
                (index) => index <= newList.length
                    ? newList[index]
                    : newList[index + items.length],
                growable: false)
            : List<PhotoMemo>.generate(
                8,
                (index) => index <= newList.length
                    ? newList[index]
                    : newList[index + items.length],
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
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          // title: const Text('User Home'),
          actions: [
            con.selected.isEmpty
                ? Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Search (empty for all)',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          autocorrect: true,
                          onSaved: con.saveSearchKey,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: con.cancel,
                    icon: const Icon(Icons.cancel),
                  ),
            con.selected.isEmpty
                ? IconButton(
                    onPressed: con.search,
                    icon: const Icon(Icons.search),
                  )
                : IconButton(
                    onPressed: con.delete,
                    icon: const Icon(Icons.delete),
                  )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: const Icon(
                  Icons.person,
                  size: 70.0,
                ),
                accountName: const Text('Profile'),
                accountEmail: Text(email),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Direct Messages'),
                onTap: con.sharedWith,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: con.addButton,
          child: const Icon(Icons.add),
        ),
        body: LayoutBuilder(
          builder: ((context, constraints) {
            if (items.isNotEmpty) {
              return Stack(
                children: [
                  ListView.separated(
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      if (index < newList.length) {
                        return ListTile(
                          title: Container(
                            margin: const EdgeInsets.all(10.0),
                            child: ListTile(
                              minVerticalPadding: 8.0,
                              selected: con.selected.contains(index),
                              selectedTileColor: Colors.blue[100],
                              tileColor: Colors.white,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        newList[index].likes.toString(),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            con.like(newList[index]),
                                        icon: const Icon(
                                          Icons.thumb_up_sharp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      DocKeyComments.photoDocId.name !=
                                              newList[index].docId
                                          ? const Text("")
                                          : const Icon(Icons.done),
                                      SizedBox(
                                        width: 200.0,
                                        child: WebImage(
                                          url: newList[index].photoURL,
                                          context: context,
                                        ),
                                      ),
                                      Text(newList[index].title),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        newList[index].dislikes.toString(),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            con.dislike(newList[index]),
                                        icon: const Icon(
                                          Icons.thumb_down_sharp,
                                          size: 26.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    con.photoMemoList[index].memo.length >= 60
                                        ? con.photoMemoList[index].memo
                                                .substring(0, 60) +
                                            '...'
                                        : con.photoMemoList[index].memo,
                                  ),
                                  Text(
                                      'Created By: ${con.photoMemoList[index].createdBy}'),
                                ],
                              ),
                              onTap: () => con.onTap(index),
                              onLongPress: () => con.onLongPress(index),
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
                    itemCount: newList.length + (allLoaded ? 1 : 0),
                  ),
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
              return const Text("No PhotoMemos available!");
            }
          }),
        ),
      ),
    );
  }
}

class _Controller {
  _UserHomeState state;
  late List<PhotoMemo> photoMemoList;
  String? searchKeyString;
  List<int> selected = [];

  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
  }

  void addComment(String? docId) async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    if (!currentState.validate()) return;
    currentState.save();
    List<Comments> commentList =
        await FireStoreController.getCommentList(docId: docId);
  }

  void like(PhotoMemo index) {
    // want to get the current number of likes and increment and store in firebase.
    Map<String, dynamic> update = {};
    int currentLikes = index.likes;
    currentLikes++;
    update[DocKeyPhotoMemo.likes.name] = currentLikes;
    FireStoreController.updatePhotoMemo(docId: index.docId!, update: update);
    state.setState(() {
      index.likes = currentLikes;
    });
  }

  void dislike(PhotoMemo index) {
    Map<String, dynamic> update = {};
    int currentDislikes = index.dislikes;
    currentDislikes++;
    update[DocKeyPhotoMemo.dislikes.name] = currentDislikes;
    FireStoreController.updatePhotoMemo(docId: index.docId!, update: update);
    state.setState(() {
      index.dislikes = currentDislikes;
    });
  }

  void sharedWith() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FireStoreController.getPhotoMemoListSharedWithMe(
        email: state.email,
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

  void cancel() {
    state.render(() => selected.clear());
  }

  void delete() async {
    startCircularProgress(state.context);
    selected.sort();
    for (int i = selected.length - 1; i >= 0; i--) {
      try {
        PhotoMemo p = photoMemoList[selected[i]];
        await FireStoreController.deleteDoc(docId: p.docId!);
        await CloudStorageController.deleteFile(filename: p.photoFilename);
        state.render(() {
          photoMemoList.removeAt(selected[i]);
        });
      } catch (e) {
        stopCircularProgress(state.context);
        if (Constant.devMode) print('=========== failed to delete: $e');
        showSnackBar(
          context: state.context,
          seconds: 20,
          message: 'Failed! Sign Out and In again to get updated List\n $e',
        );
        break; //quit further processing
      }
    }
    state.render(() => selected.clear());
    stopCircularProgress(state.context);
  }

  void saveSearchKey(String? value) {
    searchKeyString = value;
  }

  void search() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    currentState.save();

    List<String> keys = [];
    if (searchKeyString != null) {
      var toekns = searchKeyString!.split(RegExp('(,| )+')).toList();
      for (var t in toekns) {
        if (t.trim().isNotEmpty) {
          keys.add(t.trim().toLowerCase());
        }
      }
    }
    startCircularProgress(state.context);
    try {
      late List<PhotoMemo> results;
      if (keys.isEmpty) {
        results =
            await FireStoreController.getPhotoMemoList(email: state.email);
      } else {
        results = await FireStoreController.searchImages(
          email: state.email,
          searchLabel: keys,
        );
      }
      stopCircularProgress(state.context);
      state.render(() {
        photoMemoList = results;
      });
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('=============== failed to search: $e');
      showSnackBar(
          context: state.context, seconds: 20, message: 'failed to search: $e');
    }
  }

  void addButton() async {
    await Navigator.pushNamed(state.context, AddPhotoMemoScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.photoMemoList: photoMemoList,
        });
    state.render(() {});
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

  void onTap(int index) async {
    if (selected.isNotEmpty) {
      onLongPress(index);
      return;
    }
    Navigator.pushNamed(
      state.context,
      DetailedViewScreen.routeName,
      arguments: {
        ArgKey.user: state.widget.user,
        ArgKey.onePhotoMemo: photoMemoList[index],
      },
    );
  }

  void onLongPress(int index) {
    state.render(() {
      if (selected.contains(index)) {
        selected.remove(index);
      } else {
        selected.add(index);
      }
    });
  }
}
