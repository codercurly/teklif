import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teklif/bloc/auth_bloc.dart';
import 'package:teklif/components/custom_text.dart';
import 'package:teklif/form/offer_form.dart';
import 'package:teklif/model/events/auth_event.dart';
import 'package:teklif/pages/auth/register_page.dart';
import 'package:teklif/pages/forbusiness/manager_page.dart';
import 'package:teklif/states/auth_state.dart';
import 'package:teklif/animation/wave.dart';
import 'package:teklif/base/dimension.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        firebaseStorage: FirebaseStorage.instance,
        firebaseAuth: FirebaseAuth.instance,
        firebaseFirestore: FirebaseFirestore.instance,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print("Dinliyoz");
          if (state is AuthSuccess) {
            print("başarılı");
            if (state.role == 'Pazarlamacı-Satıcı') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OfferForm(sector: 'Ürün')),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManagerPage()),
              );
            }
          } else if (state is AuthFailure) {
            print("hataaa");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade900,
                        Colors.orange.shade500,
                        Colors.orange.shade300
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(Dimension.getWidth15(context)),
                child: Form(
                  key: _formKey,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView(
                        children: [
                          SizedBox(height: Dimension.getHeight10(context) * 15),
                          Text(
                            'Giriş Yap',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: Dimension.getHeight20(context)),
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            icon: Icons.email,
                          ),
                          SizedBox(height: Dimension.getHeight20(context)),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'Şifre',
                            icon: Icons.lock,
                            obscureText: true,
                          ),
                          SizedBox(height: Dimension.getHeight20(context)),
                          GestureDetector(
                            onTap: () {
                            //  _login();
                              if (_formKey.currentState!.validate()) {

                                BlocProvider.of<AuthBloc>(context).add(
                                  LoginEvent(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lütfen tüm alanları doldurun ve geçerli bir email girin.'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.orange.shade300,
                                    Colors.orange.shade500,
                                    Colors.orange.shade900
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Text(
                                'Giriş Yap',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: Dimension.getHeight30(context)),
                          
                          GestureDetector(
                              onTap:(){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                RegisterPage(role: "Yönetici")));
                              },
                              child: Row(

                                children: [
                                  CustomText(text: "Bir hesabın yok mu? ",
                                    color: Colors.grey,fontSize: Dimension.getFont18(context),),
                                  Text( " KAYIT OL",
                                    style:TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.orange.shade900,
                                      color: Colors.orange.shade800,fontSize:
                                    Dimension.getFont23(context),))

                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              ))
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimension.getRadius30(context)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(Dimension.getWidth20(context) / 1.4),
          hintStyle: TextStyle(fontSize: Dimension.getFont18(context)),
        ),
        validator: (value) {
          if (hintText != 'Telefon' && (value == null || value.isEmpty)) {
            return 'Lütfen $hintText girin';
          }
          return null;
        },
      ),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        LoginEvent(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen tüm alanları doldurun ve geçerli bir email girin.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
