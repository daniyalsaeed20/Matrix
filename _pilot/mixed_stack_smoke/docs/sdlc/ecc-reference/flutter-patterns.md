# Flutter patterns (adapted from ECC dart-flutter-patterns)

Use with **m4trix-flutter**. m4tr!x default for **new** apps: **BLoC + GoRouter**. Keep existing stacks.

## Must-haves

- Prefer `?.` / `??` / switches over `!`
- Immutable / sealed states; exhaustive `switch`
- After `await`, guard `mounted` before using `BuildContext`
- Extract widgets as **classes**, not private builder methods
- Propagate `const` where possible; scope rebuilds
- GoRouter: `refreshListenable` + auth `redirect`
- Networking: timeouts, auth interceptor, one-time 401 retry guard
- Global error hooks + production `ErrorWidget` when shipping
- Tests: `blocTest` for cubits/blocs; widget tests for UI AC

## BLoC sketch

```dart
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._auth) : super(const AuthState.initial());
  final AuthService _auth;

  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    try {
      final user = await _auth.login(email, password);
      emit(AuthState.authenticated(user));
    } on AuthException catch (e) {
      emit(AuthState.error(e.message));
    }
  }
}
```

## Theme

Build the design-system theme catalog **before** feature screens (m4trix-design-system).
