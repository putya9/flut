import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/features/auth/presentation/components/my_text_field.dart';
import 'package:socail_flutter/features/profile/domain/entities/profile_user.dart';
import 'package:socail_flutter/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:socail_flutter/features/profile/presentation/cubits/profile_states.dart';
import 'package:socail_flutter/responsive/constraide_scaffold.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  PlatformFile? imagePickedFile;
  Uint8List? webImage;
  final bioTextController = TextEditingController();

  Future<void> pickImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: kIsWeb);

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  void updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();
    final String uid = widget.user.uid;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;
    if (imagePickedFile != null || newBio != null) {
      profileCubit.updateProfile(
          uid: uid,
          newBio: newBio,
          mobileFilePath: imageMobilePath,
          imageWebBytes: imageWebBytes);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(builder: (context, state) {
      if (state is ProfileLoading) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        return builEditPage();
      }
    }, listener: (context, state) {
      if (state is ProfileLoaded) {
        Navigator.pop(context);
      }
    });
  }

  Widget builEditPage() {
    return ConstraideScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit profile'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
              onPressed: () => updateProfile(),
              icon: Icon(
                Icons.upload,
                color: bioTextController.text.isEmpty
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.inversePrimary,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 200,
                  height: 200,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle),
                  child: (!kIsWeb && imagePickedFile != null)
                      ? Image.file(File(imagePickedFile!.path!),
                          fit: BoxFit.cover)
                      : (kIsWeb && webImage != null)
                          ? Image.memory(webImage!, fit: BoxFit.cover)
                          : CachedNetworkImage(
                              imageUrl: widget.user.profileImageUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 72,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              imageBuilder: (context, imageProvider) => Image(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            )),
            ),
            const SizedBox(height: 10),
            Center(
              child: MaterialButton(
                color: Theme.of(context).colorScheme.secondary,
                onPressed: pickImage,
                child: const Text('Выбрать фото'),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Bio',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 10),
            MyTextField(
                controller: bioTextController,
                hintText:
                    widget.user.bio.isEmpty ? 'Enter bio' : widget.user.bio,
                obscureText: false)
          ],
        ),
      ),
    );
  }
}
