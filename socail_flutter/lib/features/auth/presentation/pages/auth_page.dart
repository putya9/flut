import 'package:flutter/widgets.dart';
import 'package:socail_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:socail_flutter/features/auth/presentation/pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;
  void tooglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        togglePages: () {
          setState(() {
            showLoginPage = false;
          });
        },
      );
    } else {
      return RegisterPage(
        togglePages: () {
          setState(() {
            showLoginPage = true;
          });
        },
      );
    }
  }
}
