import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class UserFirestoreDataSource {
  Future<UserModel> getUser(String id);
  Stream<UserModel> watchUser(String id);
}

@LazySingleton(as: UserFirestoreDataSource)
class UserFirestoreDataSourceImpl implements UserFirestoreDataSource {
  final FirebaseFirestore firestore;

  UserFirestoreDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('users');

  @override
  Future<UserModel> getUser(String id) async {
    try {
      final doc = await _users.doc(id).get();
      if (!doc.exists) throw ServerException('User not found');
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<UserModel> watchUser(String id) {
    return _users.doc(id).snapshots().map(
          (doc) => UserModel.fromJson(doc.data()!),
        );
  }
}
