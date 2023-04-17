// Flutter Packages
import 'package:bluerandom/services/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Models
import '/models/user.dart';

// My Controller are a mix between the Controller and Repository from the
// Riverpod Architecture (https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/).
// It handles the management of the widget state. (Riverpod Controller's job)
// It handles the data parsing and serialilzation from api's. (Riverpod Repository's job).

@immutable
class UserState {
  const UserState({
    required this.user,
  });

  final User? user;

  UserState copyWith({User? user}) {
    return UserState(
      user: user ?? this.user,
    );
  }
}

class UserController extends StateNotifier<UserState> {
  UserController({required this.ref}) : super(const UserState(user: null));

  Ref ref;
  // Persist Data
  SecureStorage storage = SecureStorage();
}

final userProvider = StateNotifierProvider<UserController, UserState>((ref) {
  return UserController(ref: ref);
});
