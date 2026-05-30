import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/core/utils/snackbar_helper.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/providers/language_provider.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/services/home_view_service.dart';
import 'package:nadi_user_app/services/request_service.dart';
import 'package:nadi_user_app/widgets/app_back.dart';

import 'package:nadi_user_app/widgets/buttons/primary_button.dart';
import 'package:nadi_user_app/widgets/media_upload_widget.dart';
import 'package:nadi_user_app/widgets/record_widget.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class CreateServiceRequest extends ConsumerStatefulWidget {
  const CreateServiceRequest({super.key});

  @override
  ConsumerState<CreateServiceRequest> createState() =>
      _CreateServiceRequestState();
}

class _CreateServiceRequestState extends ConsumerState<CreateServiceRequest> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];
  bool isChecked = false;
  // final AudioPlayer _audioPlayer = AudioPlayer();
  // bool isRecording = false;
  File? recordedVoice;

  bool isPlaying = false;
  final _formKey = GlobalKey<FormState>();

  String? serviceError;
  String? issueError;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final RequestSerivices _requestSerivices = RequestSerivices();
  final HomeViewService _homeViewService = HomeViewService();

  final TextEditingController _timeController =
      TextEditingController(); // <-- Add this

  List<Map<String, dynamic>> issueList = [];
  List<Map<String, dynamic>> serviceLst = [];
  List<dynamic> filteredIssues = [];
  bool _isLoading = false;
  String? selectedIssueId;
  String? selectcategoryId;
  String? selectedServicePoints;
  // StreamSubscription? _playerCompleteSub;
  // StreamSubscription? _playerStateSub;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    //issuseList();
    serviceList();
  }

  Future<void> issuseList() async {
    try {
      final locale = ref.read(languageProvider);
      final lang = locale.languageCode;

      final response = await _requestSerivices.IssuseList(lang);

      if (!mounted) return;
      if (response != null) {
        setState(() {
          issueList = response;
        });
      }

      AppLogger.debug("response ${jsonEncode(response)}");
    } catch (e) {
      AppLogger.error("issuseList error: $e");
    }
  }

  Future<void> serviceList() async {
    try {
      final local = ref.read(languageProvider);
      final lang = local.languageCode;

      final response = await _homeViewService.servicelists(lang);

      if (!mounted) return;
      setState(() {
        serviceLst = response;
      });

      AppLogger.debug("response ${jsonEncode(response)}");
    } catch (e) {
      AppLogger.error("serviceList error: $e");
    }
  }

  // Future<bool> requestMicPermission() async {
  //   try {
  //     final status = await Permission.microphone.status;

  //     if (status.isGranted) {
  //       return true;
  //     }

  //     final result = await Permission.microphone.request();
  //     return result.isGranted;
  //   } catch (e) {
  //     AppLogger.error("Permission error: $e");
  //     return false;
  //   }
  // }

  // Future<void> playPauseVoice() async {
  //   if (recordedVoice == null) return;

  //   if (isPlaying) {
  //     await _audioPlayer.pause();
  //     setState(() => isPlaying = false);
  //   } else {
  //     await _audioPlayer.stop();
  //     await _audioPlayer.play(
  //       DeviceFileSource(recordedVoice!.path), //  FIX
  //     );
  //     setState(() => isPlaying = true);
  //   }
  // }

  Future<void> pickImage(ImageSource source) async {
    final loc = AppLocalizations.of(context)!;

    // Prevent more than 10 images
    if (selectedImages.length >= 10) {
      SnackbarHelper.showError(context, loc.maximum10ImagesAllowed);
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 40,
      maxWidth: 1280,
      maxHeight: 1280,
    );

    if (image != null) {
      setState(() {
        selectedImages.add(image);
      });
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    // _playerCompleteSub?.cancel();
    // _playerStateSub?.cancel();

    super.dispose();
  }

  Future<void> SendRequest() async {
    final loc = AppLocalizations.of(context)!;

    setState(() {
      serviceError = null;
      issueError = null;
    });

    bool hasError = false;

    if (selectcategoryId == null) {
      serviceError = loc.selectServices;
      hasError = true;
    }

    if (selectedIssueId == null) {
      issueError = loc.selectIssue;
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    if (_isLoading) return;

    if (selectedImages.length > 10) {
      SnackbarHelper.showError(context, loc.maximum10ImagesAllowed);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final File? voiceFile =
          (recordedVoice != null && recordedVoice!.existsSync())
          ? recordedVoice
          : null;

      final response = await _requestSerivices.createServiceRequestes(
        serviceId: selectcategoryId!,
        issuesId: selectedIssueId!,
        feedback: descriptionController.text.trim(),
        scheduleService: _dateController.text.trim(),
        immediateAssistance: isChecked,
        time: _timeController.text.trim(),
        images: selectedImages.map((e) => File(e.path)).toList(),

        // FIXED
        voice: voiceFile,
      );

      AppLogger.warn(response?['message']);
      final serviceRequestId = response?['data']?['serviceRequestID']
          ?.toString();

      AppLogger.warn("serviceRequestID $serviceRequestId");

      if (!mounted) return;

      // SUCCESS
      if (response != null) {
        final message = response['message'];

        if (message == "Service created successfully" &&
            serviceRequestId != null) {
          context.push(RouteNames.requestcreatesucess, extra: serviceRequestId);
        } else {
          SnackbarHelper.showError(context, message);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.somethingWentWrongTryAgain),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      AppLogger.error("SendRequest error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.unexpectedErrorOccurred),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.createServiceRequest,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 38,
              height: 38,
              child: FittedBox(
                child: AppCircleIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ),
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    t.serviceCategory,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    dropdownColor: Theme.of(
                      context,
                    ).colorScheme.surface, // 🔥 important

                    decoration: InputDecoration(
                      labelText: t.selectServices,
                      labelStyle: TextStyle(color: Theme.of(context).hintColor),
                      errorText: serviceError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.app_background_clr,
                          width: 1.5,
                        ),
                      ),

                      floatingLabelStyle: const TextStyle(
                        color: AppColors.app_background_clr,
                      ),

                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    items: serviceLst.map((isuse) {
                      return DropdownMenuItem<String>(
                        value: isuse["_id"],
                        child: Text(
                          isuse["name"],
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectcategoryId = value;
                        serviceError = null;
                        // find selected service
                        final selectedService = serviceLst.firstWhere(
                          (service) => service["_id"] == value,
                          orElse: () => {},
                        );

                        selectedServicePoints = selectedService["points"];

                        // 🔥 filter issues based on selected service
                        filteredIssues = selectedService["issues"] ?? [];

                        // reset selected issue
                        selectedIssueId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (selectedServicePoints != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.app_background_clr.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.app_background_clr.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          /// POINT ICON
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.btn_primery,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.stars_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// TEXT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.servicePointsRequired,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (int.tryParse(selectedServicePoints ?? '0') ??
                                              0) ==
                                          0
                                      ? t.serviceFree
                                      : t.pointsLabel(
                                          selectedServicePoints.toString(),
                                        ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  Text(
                    t.issueDetails,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value:
                        filteredIssues.any(
                          (issue) => issue['_id'] == selectedIssueId,
                        )
                        ? selectedIssueId
                        : null,

                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),

                    dropdownColor: Theme.of(context).colorScheme.surface,

                    decoration: InputDecoration(
                      labelText: t.selectIssue,
                      labelStyle: TextStyle(color: Theme.of(context).hintColor),
                      errorText: issueError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.app_background_clr,
                          width: 1.5,
                        ),
                      ),
                      floatingLabelStyle: const TextStyle(
                        color: AppColors.app_background_clr,
                      ),

                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),

                    items: filteredIssues.map<DropdownMenuItem<String>>((
                      issue,
                    ) {
                      return DropdownMenuItem<String>(
                        value: issue['_id'],
                        child: Text(issue['issue']),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedIssueId = value;
                        issueError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    controller: descriptionController,
                    minLines: 5,

                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: t.describeIssue,
                      labelStyle: TextStyle(color: Theme.of(context).hintColor),
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      floatingLabelStyle: const TextStyle(
                        color: AppColors.app_background_clr,
                      ),
                      alignLabelWithHint: true,
                      contentPadding: EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.app_background_clr,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // const Text(
                  //   "Perfered Date",
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                  // const SizedBox(height: 10),

                  // AppDatePicker(
                  //   controller: _dateController,
                  //   label: "Select Date",
                  //   onDateSelected: (date) {
                  //     print("Selected Date: $date");
                  //   },
                  // ),
                  // const SizedBox(height: 18),
                  // const Text(
                  //   "Preferred Time",
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                  // const SizedBox(height: 10),
                  // AppTimePicker(
                  //   controller: _timeController,
                  //   label: "Preferred Time",
                  //   onTimeSelected: (time) {
                  //     // Do something with the selected time
                  //     print("User selected: $time");
                  //   },
                  // ),
                  const SizedBox(height: 18),
                  Text(
                    t.mediaUploadOptional,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 3),
                  Text(
                    t.imagesSelectedCount(selectedImages.length.toString()),
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedImages.length == 10
                          ? Colors.red
                          : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MediaUploadWidget(
                    images: selectedImages,
                    onAddTap: () {
                      showImagePickerSheet(context);
                    },
                    onRemoveTap: (index) {
                      setState(() {
                        selectedImages.removeAt(index);
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  const SizedBox(height: 5),
                  RecordWidget(
                    onRecordComplete: (file) {
                      debugPrint("Recorded file path: ${file?.path}");
                      setState(() {
                        recordedVoice = file;
                      });
                    },
                  ),

                  // Row(
                  //   children: [
                  //     Checkbox(
                  //       value: isChecked,
                  //       activeColor: AppColors.btn_primery,
                  //       checkColor: Colors.white,
                  //       onChanged: (bool? newValue) {
                  //         setState(() {
                  //           isChecked = newValue!;
                  //         });
                  //       },
                  //     ),
                  //     const Text("Need immitated Asstience"),
                  //   ],
                  // ),
                  SizedBox(height: 10),
                  AppButton(
                    text: t.sendRequest,
                    onPressed: () {
                      SendRequest();
                    },
                    isLoading: _isLoading,
                    color: AppColors.btn_primery,
                    width: double.infinity,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showImagePickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                title: Text(
                  AppLocalizations.of(context)!.camera,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                title: Text(
                  AppLocalizations.of(context)!.gallery,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
