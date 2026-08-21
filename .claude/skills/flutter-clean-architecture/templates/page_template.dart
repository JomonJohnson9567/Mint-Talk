import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injection.dart';
import 'cubit/user_cubit.dart';
import 'cubit/user_state.dart';

class UserPage extends StatelessWidget {
  final String userId;

  const UserPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserCubit>()..fetchUser(userId),
      child: const _UserView(),
    );
  }
}

class _UserView extends StatelessWidget {
  const _UserView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User')),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (user) => _UserDetails(user: user),
            error: (message) => Center(child: Text(message)),
          );
        },
      ),
    );
  }
}

class _UserDetails extends StatelessWidget {
  final dynamic user; // replace `dynamic` with the real User entity type

  const _UserDetails({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(user.name));
  }
}
