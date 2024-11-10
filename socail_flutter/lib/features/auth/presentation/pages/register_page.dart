import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/features/auth/presentation/components/my_button.dart';
import 'package:socail_flutter/features/auth/presentation/components/my_text_field.dart';
import 'package:socail_flutter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socail_flutter/responsive/constraide_scaffold.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();
  void register() {
    final String name = nameController.text;
    final String email = emailController.text;
    final String pw = pwController.text;
    final String confirmPw = confirmPwController.text;
    final authCubit = context.read<AuthCubit>();
    if (email.isNotEmpty &&
        pw.isNotEmpty &&
        name.isNotEmpty &&
        confirmPw.isNotEmpty) {
      if (pw == confirmPw) {
        authCubit.register(email, pw, name);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Пароли не совпадают')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вы ввели не все данные')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstraideScaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 50),
                Text(
                  'Создание учетной записи',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16),
                ),
                const SizedBox(height: 25),
                MyTextField(
                    controller: nameController,
                    hintText: 'Имя',
                    obscureText: false),
                const SizedBox(height: 15),
                MyTextField(
                    controller: emailController,
                    hintText: 'Почта',
                    obscureText: false),
                const SizedBox(height: 15),
                MyTextField(
                    controller: pwController,
                    hintText: 'Пароль',
                    obscureText: true),
                const SizedBox(height: 15),
                MyTextField(
                    controller: confirmPwController,
                    hintText: 'Подтвердите пароль',
                    obscureText: true),
                const SizedBox(height: 25),
                MyButton(onTap: register, text: 'Зарегестрироваться'),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: widget.togglePages,
                  child: Text(
                    'Вы уже зарегестрированы?',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
