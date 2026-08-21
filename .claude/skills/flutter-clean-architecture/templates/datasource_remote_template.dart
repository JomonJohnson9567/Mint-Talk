import 'package:injectable/injectable.dart';
import '../../../core/network/api_client.dart';
import '../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUser(String id);
  Future<void> updateUser(UserModel user);
}

@LazySingleton(as: UserRemoteDataSource)
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> getUser(String id) async {
    try {
      final response = await apiClient.get('/users/$id');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await apiClient.put('/users/${user.id}', data: user.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
