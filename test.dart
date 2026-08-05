import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<void> testCrop(BuildContext context) async {
  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (picked != null) {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: picked.path,
      uiSettings: [
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
        ),
      ],
    );
    if (croppedFile != null) {
      final file = XFile(croppedFile.path);
      print(file.path);
    }
  }
}
