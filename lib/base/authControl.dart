import 'package:flutter/material.dart';
import 'package:teklif/bloc/auth_bloc.dart';
import 'package:teklif/pages/auth/login_page.dart';
import 'package:teklif/states/auth_state.dart';

class AuthUtils {
  static Future<bool> checkUserState(BuildContext context, AuthBloc authBloc) async {
    if (authBloc.state is AuthSuccess) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oturum açmanız gerekiyor.')),
      );
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      return false;
    }
  }
}