import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/auth_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photo_memo.dart';
import 'package:lesson3/viewscreen/addphotomemo_screen.dart';
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
  late String email;
  late _Controller con;
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    email = widget.user.email ?? 'No email';
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Home'),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: const Icon(Icons.person, size: 70.0),
                accountName: const Text('no profile'),
                accountEmail: Text(email),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: widget.photoMemoList.isEmpty
            ? Text(
                'No PhotoMemo Found',
                style: Theme.of(context).textTheme.headline6,
              )
            : ListView.builder(
                itemCount: widget.photoMemoList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: WebImage(
                      url: widget.photoMemoList[index].photoURL,
                      context: context,
                    ),
                    title: Text(widget.photoMemoList[index].title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.photoMemoList[index].memo.length >= 40
                              ? widget.photoMemoList[index].memo
                                      .substring(0, 40) +
                                  '...'
                              : widget.photoMemoList[index].memo,
                        ),
                        Text(
                          'Created By: ${widget.photoMemoList[index].createdBy}',
                        ),
                        Text(
                          'Shared With: ${widget.photoMemoList[index].sharedWith}',
                        ),
                        Text(
                          'Timestamp: ${widget.photoMemoList[index].timeStamp}',
                        ),
                      ],
                    ),
                  );
                }),
      ),
    );
  }
}

class _Controller {
  _UserHomeState state;
  _Controller(this.state);

  void addButton() async {
    await Navigator.pushNamed(
      state.context,
      AddPhotoMemoScreen.routeName,
      arguments: {
        ArgKey.user: state.widget.user,
        ArgKey.photoMemoList: state.widget.photoMemoList,
      },
    );
    state.render(() {}); // rerender the screen
  }

  Future<void> signOut() async {
    try {
      await AuthController.signout();
    } catch (e) {
      if (Constant.devMode) print('============= sign out error: $e');
      showSnackBar(context: state.context, message: 'Sign out error: $e');
    }
    Navigator.of(state.context).pop(); // close the drawer
    Navigator.of(state.context).pop(); // return to start screen
  }
}
