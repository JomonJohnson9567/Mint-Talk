import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();

/// External/third-party dependencies that need manual registration
/// (they don't have @injectable annotations themselves) go in a @module.
@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio(BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;
}

// Usage in main.dart:
// await Firebase.initializeApp();
// configureDependencies();
// runApp(const MyApp());
//
// After adding/changing @injectable classes, regenerate with:
// dart run build_runner build --delete-conflicting-outputs
