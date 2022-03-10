import 'package:flutter/material.dart';
import 'package:lesson3/controller/auth_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signUpScreen';

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
  var formKey = GlobalKey<FormState>();
  late _Controller con;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in Screen'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Text(
                  'Create a new account',
                  style: Theme.of(context).textTheme.headline5,
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Enter Email'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: con.validateEmail,
                  onSaved: con.saveEmail,
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Enter Password'),
                  obscureText: true,
                  autocorrect: false,
                  validator: con.validatePassword,
                  onSaved: con.savePassword,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(hintText: 'Confirm Password'),
                  obscureText: true,
                  autocorrect: false,
                  validator: con.validatePassword,
                  onSaved: con.saveConfirmPassword,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: con.signUp,
                  child: Text(
                    'Sign Up',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignUpState state;
  _Controller(this.state);
  String? email;
  String? password;
  String? confirmPassword;

  void signUp() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;

    currentState.save();
    if (password != confirmPassword) {
      showSnackBar(
          context: state.context,
          seconds: 20,
          message: 'passwords do not match');
      return;
    }

    try {
      await AuthController.createAccount(
        email: email!,
        password: password!,
      );
      showSnackBar(
        context: state.context,
        seconds: 20,
        message: 'Account Created! Sign in and use the app!',
      );
    } catch (e) {
      if (Constant.devMode) print('============= sign up failed: $e');
      showSnackBar(
        context: state.context,
        seconds: 20,
        message: 'Cannot create account: $e',
      );
    }
  }

  String? validateEmail(String? value) {
    if (value == null || !(value.contains('@') && value.contains('.'))) {
      return 'Invalid email';
    }
  }

  void saveEmail(String? value) {
    email = value;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'password too short (min 6 chars)';
    } else {
      return null;
    }
  }

  void savePassword(String? value) {
    password = value;
  }

  void saveConfirmPassword(String? value) {
    confirmPassword = value;
  }
}
