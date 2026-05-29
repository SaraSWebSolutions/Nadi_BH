import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';

class IdCardSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTakePhoto;
  final VoidCallback? onUploadGallery;
  final File? previewImage;

  const IdCardSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTakePhoto,
    this.onUploadGallery,
    this.previewImage,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),

          const SizedBox(height: 8),

          /// SUBTITLE
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          /// IMAGE PREVIEW
          previewImage == null
              ? Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(18),

                    child: Row(
                      children: [
                        /// PHOTO BOX
                        Container(
                          width: 74,
                          height: 86,

                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.photo,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        /// PLACEHOLDER LINES
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _line(150),
                              const SizedBox(height: 18),
                              _line(130),
                              const SizedBox(height: 18),
                              _line(120),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  height: 150,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(previewImage!, fit: BoxFit.cover),
                  ),
                ),

          const SizedBox(height: 22),

          /// TAKE PHOTO BUTTON
          SizedBox(
            height: 52,
            width: double.infinity,

            child: OutlinedButton.icon(
              onPressed: onTakePhoto,

              icon: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),

              label: Text(
                AppLocalizations.of(context)!.takePhoto,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400, width: 1.3),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          const SizedBox(height: 15),

          /// UPLOAD GALLERY BUTTON
          SizedBox(
            height: 52,
            width: double.infinity,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.app_background_clr,
                elevation: 0,

                padding: const EdgeInsets.symmetric(horizontal: 16),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: onUploadGallery,

              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.uploadGallery,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Container(
                    height: 34,
                    width: 34,

                    padding: const EdgeInsets.all(6),

                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),

                    child: Icon(
                      Icons.file_upload_outlined,
                      size: 18,
                      color: AppColors.app_background_clr,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // small grey line
  Widget _line(double width) {
    return Container(
      height: 3,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
