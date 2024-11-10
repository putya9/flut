import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/features/auth/domain/enties/app_user.dart';
import 'package:socail_flutter/features/auth/presentation/components/my_text_field.dart';
import 'package:socail_flutter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socail_flutter/features/post/domain/entities/post.dart';
import 'package:socail_flutter/features/post/presentation/cubit/post_cubit.dart';
import 'package:socail_flutter/responsive/constraide_scaffold.dart';

class PostUploadPage extends StatefulWidget {
  const PostUploadPage({super.key});

  @override
  State<PostUploadPage> createState() => _PostUploadPageState();
}

class _PostUploadPageState extends State<PostUploadPage> {
  PlatformFile? imagePickerFile;
  Uint8List? webImage;
  final postTextController = TextEditingController();
  AppUser? currentUser;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: kIsWeb);

    if (result != null) {
      setState(() {
        imagePickerFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickerFile!.bytes;
        }
      });
    }
  }

  void uploadPost() {
    if (imagePickerFile == null || postTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Добавьте фото и текст записи')));
      return;
    }
    final String text = postTextController.text;
    final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: text,
        imageUrl: '',
        timestamp: DateTime.now(),
        likes: [],
        comments: []);
    final postCubit = context.read<PostCubit>();
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickerFile?.bytes);
    } else {
      postCubit.createPost(newPost, imagePath: imagePickerFile?.path);
    }
  }

  @override
  void dispose() {
    postTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(builder: (context, state) {
      if (state is PostsLoading || state is PostsUploading) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      return buildUploadPage();
    }, listener: (context, state) {
      if (state is PostsLoaded) {
        Navigator.pop(context);
      }
    });
  }

  Widget buildUploadPage() {
    return ConstraideScaffold(
      appBar: AppBar(
        title: const Text('Создание поста'),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: uploadPost, icon: const Icon(Icons.upload))
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (kIsWeb && webImage != null) Image.memory(webImage!),
              if (!kIsWeb && imagePickerFile != null)
                Image.file(File(imagePickerFile!.path!)),
              const SizedBox(height: 10),
              Center(
                child: MaterialButton(
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: pickImage,
                  child: const Text('Выбрать фото'),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: MyTextField(
                    controller: postTextController,
                    hintText: 'Подпись',
                    obscureText: false),
              )
            ],
          ),
        ),
      ),
    );
  }
}
