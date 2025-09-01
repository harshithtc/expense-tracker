import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider()..checkAuthStatus(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final router = GoRouter(
            initialLocation: authProvider.isAuthenticated ? '/home' : '/login',
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => LoginScreen(),
              ),
              GoRoute(
                path: '/home',
                builder: (context, state) => HomeScreen(),
              ),
              GoRoute(
                path: '/add-expense',
                builder: (context, state) => AddExpenseScreen(),
              ),
            ],
            redirect: (context, state) {
              final isAuth = authProvider.isAuthenticated;
              final isLoading = authProvider.isLoading;

              if (isLoading) return null;

              final isLoginRoute = state.matchedLocation == '/login';

              if (!isAuth && !isLoginRoute) {
                return '/login';
              }

              if (isAuth && isLoginRoute) {
                return '/home';
              }

              return null;
            },
          );

          return MaterialApp.router(
            title: 'Expense Tracker',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
