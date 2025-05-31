import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerButton extends StatefulWidget {
  final Function(File image)? onImagePicked;
  final String label;
  final IconData icon;
  final ImageSource source; // camera or gallery

  const ImagePickerButton({
    Key? key,
    required this.source,
    this.onImagePicked,
    this.label = 'Pick Image',
    this.icon = Icons.image,
  }) : super(key: key);

  @override
  _ImagePickerButtonState createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: widget.source);

    if (pickedFile != null && widget.onImagePicked != null) {
      widget.onImagePicked!(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _pickImage,
      icon: Icon(widget.icon),
      label: Text(widget.label),
    );
  }
}
