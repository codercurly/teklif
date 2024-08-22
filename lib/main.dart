import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teklif/bloc/business_bloc.dart';
import 'package:teklif/bloc/customer_bloc.dart';
import 'package:teklif/bloc/product_bloc.dart';
import 'package:teklif/bloc/auth_bloc.dart';
import 'package:teklif/bloc/repair_bloc.dart';
import 'package:teklif/bloc/service_bloc.dart';
import 'package:teklif/bloc/worker_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:teklif/pages/general/home_page.dart';
import 'package:teklif/pages/forbusiness/manager_page.dart';
import 'package:teklif/pages/auth/register_page.dart';
import 'package:teklif/states/auth_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );


  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            firebaseAuth: FirebaseAuth.instance,
            firebaseFirestore: FirebaseFirestore.instance,
            firebaseStorage: FirebaseStorage.instance
          ),),
        BlocProvider(
        create: (context) => ProductBloc(
          authBloc:  BlocProvider.of<AuthBloc>(context),
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
      auth: FirebaseAuth.instance,
    ),),
        BlocProvider(
          create: (context) => CustomerBloc(
            authBloc:  BlocProvider.of<AuthBloc>(context),
            firebaseFirestore: FirebaseFirestore.instance,
            firebaseStorage: FirebaseStorage.instance,
            firebaseAuth: FirebaseAuth.instance,
          ),),
        BlocProvider(
          create: (context) => RepairBloc()),
        BlocProvider(
          create: (context) => WorkerBloc(
            authBloc:  BlocProvider.of<AuthBloc>(context),
            firebaseFirestore: FirebaseFirestore.instance,
            firebaseStorage: FirebaseStorage.instance,
            firebaseAuth: FirebaseAuth.instance,
          ),),
        BlocProvider(
          create: (context) => BusinessBloc(
            authBloc:  BlocProvider.of<AuthBloc>(context),
            firebaseFirestore: FirebaseFirestore.instance,
            firebaseStorage: FirebaseStorage.instance,
            firebaseAuth: FirebaseAuth.instance,
          ),),
        BlocProvider(
          create: (context) => ServiceBloc(),),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Teklif Oluşturucu',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
          locale: Locale('tr', 'TR'),
          supportedLocales: [
            Locale('en', 'US'),
            Locale('tr', 'TR'),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        home: ManagerPage()

      ),
    );
        // ManagerPage(),
  }
}

class ManagerPageWithSlider extends StatelessWidget {
  const ManagerPageWithSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ManagerPage(),
          Positioned(
            bottom: 50.0,
            left: 0.0,
            right: 0.0,
            child: Column(
              children: const [
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 20),
                HomePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


