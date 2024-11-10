import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/features/%D1%81cubit/cubit/test_cubit.dart';
import 'package:socail_flutter/responsive/constraide_scaffold.dart';
import 'package:socail_flutter/themes/theme_cubit.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    bool isDarkMode = themeCubit.isDarkMode;
    return ConstraideScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.inversePrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              'Темная тема',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            trailing: Switch.adaptive(
                value: isDarkMode,
                onChanged: (value) {
                  themeCubit.toogleTheme();
                }),
          ),
          BlocProvider(
            create: (context) => TestCubit(),
            child: BlocBuilder<TestCubit, TestState>(builder: (context, state) {
              print(state);
              if (state is TestTaped) {
                return Container(
                  color: Colors.red,
                  width: 20,
                  height: 20,
                );
              } else {
                print('123');
                return GestureDetector(
                  onTap: () => context.read<TestCubit>().testTaped(),
                  child: Container(
                    color: Colors.green,
                    width: 20,
                    height: 20,
                  ),
                );
              }
            }),
          )
        ],
      ),
    );
  }
}
