import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/providers/serviceProvider.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


class Allservice extends ConsumerStatefulWidget {
  const Allservice({super.key});

  @override
  ConsumerState<Allservice> createState() => _AllserviceState();
}

class _AllserviceState extends ConsumerState<Allservice> {
  @override
  Widget build(BuildContext context) {
    final services = ref.watch(serviceListProvider);


    return 
     Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(

        child: 
          Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppCircleIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => context.pop(),
                  ),
                  const Text(
                    "Service",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600,color: AppColors.app_background_clr),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 5),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: AnimationLimiter(
                  child: GridView.builder(
                    itemCount: services.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                    itemBuilder: (context, index) {
                      final service = services[index];
                      final String name = service['name'] ?? '';
                      final String serviceId = service['_id'] ?? "";
                      final String? image = service['serviceImage'];
                      final int points =
                          int.tryParse(service['points'].toString()) ?? 0;
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        columnCount: 2,
                        duration: const Duration(
                          milliseconds: 900,
                        ), //  slow & smooth
                        child: SlideAnimation(
                          verticalOffset: 40, // bottom → top feel
                          curve: Curves.easeOutCubic,
                          child: FadeInAnimation(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                context.push(
                                  RouteNames.sendservicerequest,
                                  extra: {
                                    'title': name,
                                    'imagePath':
                                        "${ImageBaseUrl.baseUrl}/$image",
                                    'serviceId': serviceId,
                                    'heroTag': "serviceHero$index",
                                    "points": points,
                                  },
                                );
                              },
                              child: Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Hero(
                                        tag: "serviceHero$index",
                                        child: SizedBox.expand(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                "${ImageBaseUrl.baseUrl}/$image",
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  color: Colors.grey.shade200,
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      color:
                                                          Colors.grey.shade200,
                                                      child: const Icon(
                                                        Icons.image_not_supported,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 44,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Center(
                                          child: Text(
                                            name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
       
        ),
      ),
    );
  }
}
