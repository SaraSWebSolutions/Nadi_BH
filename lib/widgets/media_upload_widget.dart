import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';

class MediaUploadWidget extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onAddTap;
  final Function(int index) onRemoveTap;

  const MediaUploadWidget({
    super.key,
    required this.images,
    required this.onAddTap,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ADD MEDIA BUTTON — always first
              InkWell(
                onTap: onAddTap,
                child: Container(
                  width: 110,
                  decoration: BoxDecoration(
                    color: AppColors.app_background_clr,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 35),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.addMedia,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (images.isNotEmpty) const SizedBox(width: 10),

              /// IMAGE ITEMS
              ...List.generate(images.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(right: index != images.length - 1 ? 10 : 0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(images[index].path),
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      ),
                      /// REMOVE ICON
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onRemoveTap(index),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.close, size: 16, color: Colors.black),
                          ),
                        ),
                      ),
                      /// VIEW ICON
                      Positioned.fill(
                        child: Center(
                          child: Icon(
                            Icons.remove_red_eye,
                            color: Colors.white.withOpacity(0.8),
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
}
}
