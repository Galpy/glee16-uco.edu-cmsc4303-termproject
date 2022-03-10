import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/auth_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/photo_memo.dart';
import 'package:lesson3/viewscreen/signup_screen.dart';
import 'package:lesson3/viewscreen/userhome_screen.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';

import '../model/constant.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  static const routeName = '/startScreen';

  @override
  State<StatefulWidget> createState() {
    return _StartState();
  }
}

class _StartState extends State<StartScreen> {
  late _Controller con;
  final formKey = GlobalKey<FormState>();

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
        title: const Text('Sign In'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'PhotoMemo',
                style: Theme.of(context).textTheme.headline3,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Email address',
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: con.validateEmail,
                onSaved: con.saveEmail,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
                obscureText: true,
                autocorrect: false,
                validator: con.validatePass,
                onSaved: con.savePass,
              ),
              ElevatedButton(
                onPressed: con.signIn,
                child: Text(
                  'Sign In',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              OutlinedButton(
                onPressed: con.signUp,
                child: Text(
                  'Create a new account',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _StartState state;
  String? email;
  String? password;

  _Controller(this.state);

  void signUp() {
    Navigator.pushNamed(state.context, SignUpScreen.routeName);
  }

  void signIn() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;

    if (!currentState.validate()) return;

    currentState.save();

    startCircularProgress(state.context);

    User? user;
    try {
      if (email == null || password == null) {
        throw 'Email or Password is null';
      }
      user = await AuthController.signin(email: email!, password: password!);

      List<PhotoMemo> photoMemoList =
          await FireStoreController.getPhotoMemoList(email: email!);

      stopCircularProgress(state.context);

      Navigator.pushNamed(
        state.context,
        UserHomeScreen.routeName,
        arguments: {
          ArgKey.user: user,
          ArgKey.photoMemoList: photoMemoList,
        },
      );
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('********************** SIgn In Error: $e');
      showSnackBar(
          context: state.context, seconds: 20, message: 'Sign In Error: $e');
    }
  }

  String? validateEmail(String? value) {
    if (value == null) {
      return 'No email provided';
    } else if (!(value.contains('@') && value.contains('.'))) {
      return 'Invalid email format';
    } else {
      return null;
    }
  }

  void saveEmail(String? value) {
    if (value != null) {
      email = value;
    }
  }

  String? validatePass(String? value) {
    if (value == null) {
      return 'password not provided';
    } else if (value.length < 6) {
      return ' Password too short';
    } else {
      return null;
    }
  }

  void savePass(String? value) {
    if (value != null) {
      password = value;
    }
  }
}
