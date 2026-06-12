import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/core/utils/Time_Date.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/models/technician_model.dart';
import 'package:nadi_user_app/services/request_service.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';
import 'package:shimmer/shimmer.dart';

class ServiceRequestDetails extends StatelessWidget {
  final Map<String, dynamic> serviceData;
  const ServiceRequestDetails({super.key, required this.serviceData});

  @override
  Widget build(BuildContext context) {
    /// ---------- IMAGES ----------
    final List<String> images = getServiceImages(serviceData);

    /// ---------- TIMELINE ----------
    final timestamps =
        (serviceData["statusTimestamps"] as Map<String, dynamic>?) ?? {};
    final String serviceStatus = serviceData["serviceStatus"];
    final List acceptedTechnicians = serviceData["acceptedTechnicians"] ?? [];
    String? serviceError;
    String? issueError;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final l10n = AppLocalizations.of(context)!;
    final steps = [
      {
        "key": "submitted",
        "title": l10n.requestSubmitted,
        "description": l10n.requestSubmittedDesc,
        "time": timestamps["submitted"],
      },
      {
        "key": "accepted",
        "title": l10n.adminProcessing,
        "description": l10n.adminProcessingDesc,
        "time": timestamps["accepted"],
      },
      {
        "key": "technicianAssigned",
        "title": l10n.technicianAssigned,
        "description": l10n.technicianAssignedDesc,
        "time": timestamps["technicianAssigned"],
        "acceptedTechnicians": acceptedTechnicians,
      },
      {
        "key": "inProgress",
        "title": l10n.serviceInProgress,
        "description": l10n.serviceInProgressDesc,
        "time": timestamps["inProgress"],
      },
      {
        "key": "paymentInProgress",
        "title": l10n.paymentInProgress,
        "description": l10n.paymentInProgressDesc,
        "time": timestamps["paymentInProgress"],
        "payment": serviceData["payment"],
      },
      {
        "key": "completed",
        "title": l10n.serviceCompleted,
        "description": l10n.serviceCompletedDesc,
        "time": timestamps["completed"],
      },
    ].map((e) => {...e, "currentStatus": serviceStatus}).toList();

    /// ---------- UI ----------
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER IMAGE (MULTI IMAGE)
            Stack(
              alignment: isRTL ? Alignment.topRight : Alignment.topLeft,

              children: [
                ServiceImagePager(images: images, height: 220),
                PositionedDirectional(
                  top: 50,
                  start: 20,
                  child: AppCircleIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                    // color: Colors.white,
                    // iconcolor: AppColors.button_secondary,
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.serviceRequestDetails,
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  /// PROGRESS
                  ServiceProgressTimeline(steps: steps),
                  const SizedBox(height: 20),

                  /// COMPLAINT DETAILS
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.complaintDetails,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          serviceData["feedback"] ?? "",
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        ServiceImagePager(images: images, height: 200),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// FEEDBACK
                  _FeedbackSection(serviceData: serviceData),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------- IMAGE HELPERS ----------
  List<String> getServiceImages(Map<String, dynamic> data) {
    final List media = data["media"] ?? [];
    final List<String> images = [];

    for (final file in media) {
      final name = file.toString().toLowerCase();
      if (name.endsWith(".png") ||
          name.endsWith(".jpg") ||
          name.endsWith(".jpeg") ||
          name.endsWith(".webp")) {
        images.add("${ImageBaseUrl.baseUrl}/$file");
      }
    }

    if (images.isEmpty && data["serviceId"]?["serviceImage"] != null) {
      images.add(
        "${ImageBaseUrl.baseUrl}/${data["serviceId"]["serviceImage"]}",
      );
    }

    return images;
  }

  Widget ServiceImagePager({
    required List<String> images,
    required double height,
  }) {
if (images.isEmpty) {
  images = [
    "https://srv1252888.hstgr.cloud/uploads/1768196138312-431646658-Benefits-of-Commercial-Electrical-Services-for-Businesses--scaled.webp"
  ];
}
    final PageController controller = PageController();
    final ValueNotifier<int> currentPage = ValueNotifier(0);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          /// IMAGES
          PageView.builder(
            controller: controller,
            itemCount: images.length,
            onPageChanged: (index) => currentPage.value = index,
            itemBuilder: (_, index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(color: Colors.grey),
                ),
                 errorWidget: (_, __, ___) => Image.network(
    "https://srv1252888.hstgr.cloud/uploads/1768196138312-431646658-Benefits-of-Commercial-Electrical-Services-for-Businesses--scaled.webp",
    fit: BoxFit.cover,
  ),
                // errorWidget: (_, __, ___) =>
                //     const Center(child: Icon(Icons.broken_image)),
              );
            },
          ),

          if (images.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<int>(
                valueListenable: currentPage,
                builder: (_, value, __) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: value == index ? 12 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: value == index
                              ? AppColors.btn_primery
                              : AppColors.button_secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class ServiceProgressTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> steps;
  const ServiceProgressTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(
          steps.length,
          (index) => _TimelineTile(
            data: steps[index],
            isLast: index == steps.length - 1,
          ),
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isLast;

  const _TimelineTile({required this.data, required this.isLast});

  static const List<String> statusOrder = [
    "submitted",
    "accepted",
    "technicianAssigned",
    "inProgress",
    "paymentInProgress",
    "completed",
  ];

  String get currentStatus => data["currentStatus"];

  bool get isRejectedFlow => currentStatus == "rejected";

  bool get isCurrent => data["key"] == currentStatus;

  bool get isCompleted {
    /// REJECTED FLOW
    if (isRejectedFlow) {
      if (data["key"] == "submitted") return true;
      return false;
    }

    final int stepIndex = statusOrder.indexOf(data["key"]);
    final int currentIndex = statusOrder.indexOf(currentStatus);

    return stepIndex < currentIndex;
  }

  bool get isRejectedStep {
    return isRejectedFlow && data["key"] == "accepted";
  }

  Color get dotColor {
    /// completed
    if (isCompleted) return Colors.green;

    /// rejected
    if (isRejectedStep) return Colors.red;

    /// current
    if (isCurrent) {
      switch (data["key"]) {
        case "technicianAssigned":
          return Colors.blue;

        case "inProgress":
          return Colors.orange;

        case "paymentInProgress":
          return Colors.green;

        case "completed":
          return Colors.green;

        case "accepted":
          return Colors.orange;

        default:
          return Colors.orange;
      }
    }

    return Colors.grey.shade400;
  }

  Color get chipBg {
    if (isCompleted) {
      return Colors.green.shade100;
    }

    if (isRejectedStep) {
      return Colors.red.shade100;
    }

    if (isCurrent) {
      switch (data["key"]) {
        case "technicianAssigned":
          return Colors.blue.shade100;

        case "inProgress":
          return Colors.orange.shade100;

        case "paymentInProgress":
          return Colors.green.shade100;

        case "completed":
          return Colors.green.shade100;

        case "accepted":
          return Colors.orange.shade100;

        default:
          return Colors.orange.shade100;
      }
    }

    return Colors.grey.shade300;
  }

  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    /// rejected admin step
    if (isRejectedStep) {
      return l10n.rejected;
    }

    /// completed
    if (isCompleted) {
      return l10n.completed;
    }

    /// current
    if (isCurrent) {
      switch (data["key"]) {
        case "submitted":
          return l10n.submitted;

        case "accepted":
          return l10n.accepted;

        case "technicianAssigned":
          return l10n.technicianAssigned;

        case "inProgress":
          return l10n.inProgress;

        case "paymentInProgress":
          return l10n.completed;

        case "completed":
          return l10n.completed;
      }
    }

    return l10n.pending;
  }

  @override
  Widget build(BuildContext context) {
    final bool showTechnicians =
        data["key"] == "technicianAssigned" &&
        data["acceptedTechnicians"] != null &&
        (data["acceptedTechnicians"] as List).isNotEmpty;

    final bool showPayment = data["payment"] != null;

    final double lineHeight = showTechnicians
        ? 120.0
        : showPayment
        ? 80
        : 70.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
              child: (isCompleted || isRejectedStep)
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),

            if (!isLast)
              Container(
                width: 2,
                height: lineHeight,
                color: Colors.grey.shade300,
              ),
          ],
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data["title"],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label(context),
                      style: TextStyle(
                        fontSize: 11,
                        color: dotColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                data["description"],
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              if (data["time"] != null) ...[
                const SizedBox(height: 6),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    formatIsoDateForUI(data["time"]),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ),
              ],

              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}

void _showTechnicianDetails(BuildContext context, TechnicianModel tech) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: tech.image.isNotEmpty
                  ? CachedNetworkImageProvider(
                      "${ImageBaseUrl.baseUrl}/${tech.image}",
                    )
                  : null,
              child: tech.image.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              "${tech.firstName} ${tech.lastName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(tech.mobile, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(tech.email, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btn_primery,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.close,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _FeedbackSection extends StatefulWidget {
  final Map<String, dynamic> serviceData;

  const _FeedbackSection({required this.serviceData});

  @override
  State<_FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<_FeedbackSection> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  late bool _isSubmitted;

  @override
  void initState() {
    super.initState();
    _isSubmitted = widget.serviceData["isFeedbackSubmitted"] ?? false;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final res = await RequestSerivices().submitFeedback(
      serviceId: widget.serviceData["_id"],
      completionFeedback: text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res != null && res["success"] == true) {
          _isSubmitted = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.feedbackSubmittedSuccessfully)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res?["message"] ?? l10n.failedToSubmitFeedback),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.serviceData["serviceStatus"] != "completed") {
      return const SizedBox.shrink();
    }

    if (_isSubmitted) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.feedback,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          AppTextField(
            controller: _controller,
            maxLines: 4,
            label: AppLocalizations.of(context)!.writeYourFeedback,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btn_primery,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.submit,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:nadi_user_app/core/constants/app_consts.dart';
// import 'package:nadi_user_app/core/network/dio_client.dart';
// import 'package:nadi_user_app/core/utils/Time_Date.dart';
// import 'package:nadi_user_app/l10n/app_localizations.dart';
// import 'package:nadi_user_app/models/technician_model.dart';
// import 'package:nadi_user_app/services/request_service.dart';
// import 'package:nadi_user_app/widgets/app_back.dart';
// import 'package:nadi_user_app/widgets/inputs/app_text_field.dart';
// import 'package:shimmer/shimmer.dart';

// class ServiceRequestDetails extends StatefulWidget {
//   final Map<String, dynamic> serviceData;

//   const ServiceRequestDetails({
//     super.key,
//     required this.serviceData,
//   });

//   @override
//   State<ServiceRequestDetails> createState() =>
//       _ServiceRequestDetailsState();
// }

// class _ServiceRequestDetailsState extends State<ServiceRequestDetails> {
//   late Map<String, dynamic> serviceData;
//   bool isLoading = false;
// @override
// void initState() {
//   super.initState();
//   serviceData = widget.serviceData;

//   /// auto refresh when screen opens
//   _fetchServiceDetails();
// }

// Future<void> _fetchServiceDetails() async {
//   setState(() => isLoading = true);

//   try {
//      final res = await RequestSerivices()
//         .getServiceRequestDetails(serviceData["_id"])

//     if (res != null && res["success"] == true) {
//       setState(() {
//         serviceData = res["data"]; // ✅ IMPORTANT
//       });
//     }
//   } catch (e) {
//     debugPrint("Refresh error: $e");
//   }

//   setState(() => isLoading = false);
// }
//   @override
//   Widget build(BuildContext context) {
//     /// ---------- IMAGES ----------
//     final List<String> images = getServiceImages(serviceData);

//     /// ---------- TIMELINE ----------
//     final timestamps = (serviceData["statusTimestamps"] as Map<String, dynamic>?) ?? {};
//     final String serviceStatus = serviceData["serviceStatus"];
//     final List acceptedTechnicians = serviceData["acceptedTechnicians"] ?? [];

//     final l10n = AppLocalizations.of(context)!;
//     final steps = [
//       {
//         "key": "submitted",
//         "title": l10n.requestSubmitted,
//         "description": l10n.requestSubmittedDesc,
//         "time": timestamps["submitted"],
//       },
//       {
//         "key": "accepted",
//         "title": l10n.adminProcessing,
//         "description": l10n.adminProcessingDesc,
//         "time": timestamps["accepted"],
//       },
//       {
//         "key": "technicianAssigned",
//         "title": l10n.technicianAssigned,
//         "description": l10n.technicianAssignedDesc,
//         "time": timestamps["technicianAssigned"],
//         "acceptedTechnicians": acceptedTechnicians,
//       },
//       {
//         "key": "inProgress",
//         "title": l10n.serviceInProgress,
//         "description": l10n.serviceInProgressDesc,
//         "time": timestamps["inProgress"],
//       },
//       {
//         "key": "paymentInProgress",
//         "title": l10n.paymentInProgress,
//         "description": l10n.paymentInProgressDesc,
//         "time": timestamps["paymentInProgress"],
//         "payment": serviceData["payment"],
//       },
//       {
//         "key": "completed",
//         "title": l10n.serviceCompleted,
//         "description": l10n.serviceCompletedDesc,
//         "time": timestamps["completed"],
//       },
//     ].map((e) => {...e, "currentStatus": serviceStatus}).toList();

//     /// ---------- UI ----------
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//      body: RefreshIndicator(
//   onRefresh: _fetchServiceDetails,
//   child: isLoading
//       ? const Center(child: CircularProgressIndicator())
//       : SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: Column(
//           children: [
//             /// HEADER IMAGE (MULTI IMAGE)
//             Stack(
//               children: [
//                 ServiceImagePager(images: images, height: 220),
//                 Positioned(
//                   top: 50,
//                   left: 20,
//                   child: AppCircleIconButton(
//                     icon: Icons.arrow_back,
//                     onPressed: () => Navigator.pop(context),
//                     color: Colors.white,
//                     iconcolor: AppColors.button_secondary,
//                   ),
//                 ),
//               ],
//             ),

//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 children: [
//                   Text(
//                     AppLocalizations.of(context)!.serviceRequestDetails,
//                     style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 20),

//                   /// PROGRESS
//                   ServiceProgressTimeline(steps: steps),
//                   const SizedBox(height: 20),

//                   /// COMPLAINT DETAILS
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.surface,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           AppLocalizations.of(context)!.complaintDetails,
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           serviceData["feedback"] ?? "",
//                           style: const TextStyle(fontSize: 13),
//                         ),
//                         const SizedBox(height: 12),
//                         ServiceImagePager(images: images, height: 200),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   /// FEEDBACK
//                   _FeedbackSection(serviceData: serviceData,  onRefresh: _fetchServiceDetails),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//        ),

//     );
//   }

//   /// ---------- IMAGE HELPERS ----------
//   List<String> getServiceImages(Map<String, dynamic> data) {
//     final List media = data["media"] ?? [];
//     final List<String> images = [];

//     for (final file in media) {
//       final name = file.toString().toLowerCase();
//       if (name.endsWith(".png") ||
//           name.endsWith(".jpg") ||
//           name.endsWith(".jpeg") ||
//           name.endsWith(".webp")) {
//         images.add("${ImageBaseUrl.baseUrl}/$file");
//       }
//     }

//     if (images.isEmpty && data["serviceId"]?["serviceImage"] != null) {
//       images.add(
//         "${ImageBaseUrl.baseUrl}/${data["serviceId"]["serviceImage"]}",
//       );
//     }

//     return images;
//   }

//   Widget ServiceImagePager({
//     required List<String> images,
//     required double height,
//   }) {
//     if (images.isEmpty) return const SizedBox.shrink();

//     final PageController controller = PageController();
//     final ValueNotifier<int> currentPage = ValueNotifier(0);

//     return SizedBox(
//       height: height,
//       width: double.infinity,
//       child: Stack(
//         children: [
//           /// IMAGES
//           PageView.builder(
//             controller: controller,
//             itemCount: images.length,
//             onPageChanged: (index) => currentPage.value = index,
//             itemBuilder: (_, index) {
//               return CachedNetworkImage(
//                 imageUrl: images[index],
//                 fit: BoxFit.cover,
//                 placeholder: (_, __) => Shimmer.fromColors(
//                   baseColor: Colors.grey.shade300,
//                   highlightColor: Colors.grey.shade100,
//                   child: Container(color: Colors.grey),
//                 ),
//                 errorWidget: (_, __, ___) =>
//                     const Center(child: Icon(Icons.broken_image)),
//               );
//             },
//           ),

//           if (images.length > 1)
//             Positioned(
//               bottom: 10,
//               left: 0,
//               right: 0,
//               child: ValueListenableBuilder<int>(
//                 valueListenable: currentPage,
//                 builder: (_, value, __) {
//                   return Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(
//                       images.length,
//                       (index) => AnimatedContainer(
//                         duration: const Duration(milliseconds: 250),
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         width: value == index ? 12 : 7,
//                         height: 7,
//                         decoration: BoxDecoration(
//                           color: value == index
//                               ? AppColors.btn_primery
//                               : AppColors.button_secondary,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class ServiceProgressTimeline extends StatelessWidget {
//   final List<Map<String, dynamic>> steps;
//   const ServiceProgressTimeline({super.key, required this.steps});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: List.generate(
//           steps.length,
//           (index) => _TimelineTile(
//             data: steps[index],
//             isLast: index == steps.length - 1,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _TimelineTile extends StatelessWidget {
//   final Map<String, dynamic> data;
//   final bool isLast;

//   const _TimelineTile({required this.data, required this.isLast});

//   static const List<String> statusOrder = [
//     "submitted",
//     "accepted",
//     "technicianAssigned",
//     "inProgress",
//     "paymentInProgress",
//     "completed",
//   ];

//   bool get isCurrent => data["key"] == data["currentStatus"];

//   bool get isCompleted {
//     final int stepIndex = statusOrder.indexOf(data["key"]);
//     final int currentIndex = statusOrder.indexOf(data["currentStatus"]);
//     return stepIndex < currentIndex;
//   }

//   Color get dotColor {
//     if (isCompleted) return Colors.green;

//     if (isCurrent) {
//       switch (data["key"]) {
//         case "technicianAssigned":
//           return Colors.blue;
//         case "inProgress":
//           return Colors.orange;
//         case "paymentInProgress":
//           return Colors.green;
//         default:
//           return Colors.orange;
//       }
//     }

//     return Colors.grey.shade400;
//   }

//   Color get chipBg {
//     if (isCompleted) return Colors.green.shade100;

//     if (isCurrent) {
//       switch (data["key"]) {
//         case "technicianAssigned":
//           return Colors.blue.shade100;
//         case "inProgress":
//           return Colors.orange.shade100;
//         case "paymentInProgress":
//           return Colors.green.shade100;
//         default:
//           return Colors.orange.shade100;
//       }
//     }

//     return Colors.grey.shade300;
//   }

//   // String get label {
//   //   if (isCompleted) return "Completed";
//   //   if (isCurrent) {
//   //     switch (data["key"]) {
//   //       case "submitted"
//   //         return "Submitted";
//   //       case "accepted":
//   //         return "Accepted";
//   //       case "technicianAssigned":
//   //         return "Technician Assigned";
//   //       case "inProgress":
//   //         return "In Progress";
//   //       case "paymentInProgress":
//   //         return "Payment Pending";
//   //       case "completed":
//   //         return "Completed";
//   //     }
//   //   }
//   //   return "Pending";
//   // }

//   String label(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;

//     if (isCompleted) return l10n.completed;

//     if (isCurrent) {
//       switch (data["key"]) {
//         case "submitted":
//           return l10n.submitted;
//         case "accepted":
//           return l10n.accepted;
//         case "technicianAssigned":
//           return l10n.technicianAssigned;
//         case "inProgress":
//           return l10n.inProgress;
//         case "paymentInProgress":
//           return l10n.completed;
//         case "completed":
//           return l10n.completed;
//       }
//     }

//     return l10n.pending;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool showTechnicians =
//         data["key"] == "technicianAssigned" &&
//         data["acceptedTechnicians"] != null &&
//         (data["acceptedTechnicians"] as List).isNotEmpty;

//     final bool showPayment = data["payment"] != null;
//     final double lineHeight = showTechnicians
//         ? 120.0
//         : showPayment
//         ? 80
//         : 70.0;

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           children: [
//             Container(
//               width: 26,
//               height: 26,
//               decoration: BoxDecoration(
//                 color: dotColor,
//                 shape: BoxShape.circle,
//               ),
//               child: isCompleted
//                   ? const Icon(Icons.check, size: 14, color: Colors.white)
//                   : null,
//             ),
//             if (!isLast)
//               Container(
//                 width: 2,
//                 height: lineHeight,
//                 color: Colors.grey.shade300,
//               ),
//           ],
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       data["title"],
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: chipBg,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       label(context),
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: dotColor,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 data["description"],
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//               ),

//               ///  TECHNICIAN IMAGE + NAME + TAP
//               if (showTechnicians) ...[
//                 const SizedBox(height: 8),
//                 SizedBox(
//                   height: 36,
//                   child: Stack(
//                     children: List.generate(data["acceptedTechnicians"].length, (
//                       index,
//                     ) {
//                       final techJson =
//                           data["acceptedTechnicians"][index]["technicianId"];
//                       final techModel = TechnicianModel.fromJson(techJson);
//                       return Positioned(
//                         left: index * 22.0,
//                         child: InkWell(
//                           onTap: () {
//                             _showTechnicianDetails(context, techModel);
//                           },
//                           child: CircleAvatar(
//                             radius: 16,
//                             backgroundColor: Colors.grey.shade200,
//                             backgroundImage: techModel.image.isNotEmpty
//                                 ? CachedNetworkImageProvider(
//                                     "${ImageBaseUrl.baseUrl}/${techModel.image}",
//                                   )
//                                 : null,
//                             child: techModel.image.isEmpty
//                                 ? const Icon(Icons.person, size: 16)
//                                 : null,
//                           ),
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//               ],

//               if (data["time"] != null) ...[
//                 const SizedBox(height: 6),
//                 Text(
//                   formatIsoDateForUI(data["time"]),
//                   style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
//                 ),
//               ],
//               if (showPayment) ...[
//                 const SizedBox(height: 5),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 5),
//                   // decoration: BoxDecoration(
//                   //   color: Colors.green.shade50,
//                   //   borderRadius: BorderRadius.circular(10),
//                   //   border: Border.all(color: Colors.green.shade200),
//                   // ),
//                   // child: Row(
//                   //   children: [
//                   //     const Text(
//                   //       "BHD",
//                   //       style: TextStyle(
//                   //         fontSize: 14,
//                   //         fontWeight: FontWeight.bold,
//                   //         color: Colors.green,
//                   //       ),
//                   //     ),
//                   //     const SizedBox(width: 5),
//                   //     Text(
//                   //       "${AppLocalizations.of(context)!.toPay}:"
//                   //       "${(double.tryParse(data["payment"].toString()) ?? 0.0).toStringAsFixed(3)}",
//                   //       style: const TextStyle(
//                   //         fontSize: 14,
//                   //         fontWeight: FontWeight.w600,
//                   //         color: Colors.green,
//                   //       ),
//                   //     ),
//                   //   ],
//                   // ),
//                 ),
//               ],
//               const SizedBox(height: 10),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// void _showTechnicianDetails(BuildContext context, TechnicianModel tech) {
//   showModalBottomSheet(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (_) {
//       return Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircleAvatar(
//               radius: 40,
//               backgroundImage: tech.image.isNotEmpty
//                   ? CachedNetworkImageProvider(
//                       "${ImageBaseUrl.baseUrl}/${tech.image}",
//                     )
//                   : null,
//               child: tech.image.isEmpty
//                   ? const Icon(Icons.person, size: 40)
//                   : null,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "${tech.firstName} ${tech.lastName}",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.phone, size: 16, color: Colors.grey),
//                 const SizedBox(width: 6),
//                 Text(tech.mobile, style: const TextStyle(fontSize: 14)),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.email, size: 16, color: Colors.grey),
//                 const SizedBox(width: 6),
//                 Text(tech.email, style: const TextStyle(fontSize: 14)),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.btn_primery,
//                 minimumSize: const Size(double.infinity, 44),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 AppLocalizations.of(context)!.close,
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// class _FeedbackSection extends StatefulWidget {
//   final Map<String, dynamic> serviceData;
//   final VoidCallback onRefresh;

//   const _FeedbackSection({
//     required this.serviceData,
//     required this.onRefresh,
//   });
//   @override
//   State<_FeedbackSection> createState() => _FeedbackSectionState();
// }

// class _FeedbackSectionState extends State<_FeedbackSection> {
//   final TextEditingController _controller = TextEditingController();
//   bool _isLoading = false;
//   late bool _isSubmitted;

//  @override
// void initState() {
//   super.initState();
//   _isSubmitted =
//       widget.serviceData["isFeedbackSubmitted"] ?? false; // ✅ FIX
// }

//  Future<void> _submit() async {
//   final text = _controller.text.trim();
//   if (text.isEmpty) return;

//   setState(() {
//     _isLoading = true;
//   });

//   final res = await RequestSerivices().submitFeedback(
//     serviceId: widget.serviceData["_id"], // ✅ FIX
//     completionFeedback: text,
//   );

//   if (!mounted) return;

//   setState(() {
//     _isLoading = false;
//   });

//   if (res != null && res["success"] == true) {
//     setState(() {
//       _isSubmitted = true;
//     });

//     widget.onRefresh(); // ✅ refresh parent screen

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Feedback submitted successfully")),
//     );
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(res?["message"] ?? "Failed to submit feedback"),
//       ),
//     );
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     if (serviceData["serviceStatus"] != "completed") {
//       return const SizedBox.shrink();
//     }

//     if (_isSubmitted) {
//       return const SizedBox.shrink();
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             AppLocalizations.of(context)!.feedback,
//             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 10),
//           AppTextField(
//             controller: _controller,
//             maxLines: 4,
//             label: "Write your feedback...",
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             height: 55,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.btn_primery,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: _isLoading ? null : _submit,
//               child: _isLoading
//                   ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : const Text(
//                       "Submit",
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
