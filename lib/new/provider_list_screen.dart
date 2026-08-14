import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/provider_profile_screen.dart';
import 'package:service_hub/new/user_model.dart' hide ProviderProfile;
import 'package:service_hub/widgets/intial_avater.dart' hide InitialsAvatar;

import '../model/model.dart';
import '../services/fire_Store_services.dart';
import '../theme/app_theme.dart' hide ServiceCategory;
import '../widgets/common_widgets.dart';

class ProviderListScreen extends StatefulWidget {
  final String category;

  const ProviderListScreen({
    super.key,
    required this.category,
  });

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  List<ProviderProfile> _filterProviders(
    List<ProviderProfile> providers,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return providers;
    }

    return providers.where((provider) {
      return provider.name.toLowerCase().contains(query) ||
          provider.address.toLowerCase().contains(query) ||
          provider.mainService.toLowerCase().contains(query);
    }).toList();
  }

  void _openProviderDetails(
    ProviderProfile provider,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderProfileScreen(
          providerId: provider.uid,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryInfo = serviceCategoryByName(
      widget.category,
    );

    return Scaffold(
      backgroundColor: AppColors.cardDark,
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ProviderProfile>>(
          stream: FirestoreService.instance.watchLiveProvidersForCategory(
            widget.category,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Could Not Load Providers',
                message: _readableError(
                  snapshot.error,
                ),
              );
            }

            final allProviders = snapshot.data ?? const <ProviderProfile>[];

            final providers = _filterProviders(allProviders);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      18,
                      18,
                      0,
                    ),
                    child: _CategoryBanner(
                      category: categoryInfo,
                      providerCount: allProviders.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      16,
                      18,
                      16,
                    ),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search provider or area...',
                        prefixIcon: const Icon(
                          Icons.search,
                        ),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();

                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                ),
                              ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                if (allProviders.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      icon: categoryInfo.icon,
                      title: 'No Live Providers',
                      message:
                          'There are currently no live ${widget.category} providers. Please try again later.',
                    ),
                  )
                else if (providers.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      icon: Icons.search_off,
                      title: 'No Provider Found',
                      message: 'Try another provider name or service area.',
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        0,
                        18,
                        12,
                      ),
                      child: Text(
                        '${providers.length} provider'
                        '${providers.length == 1 ? '' : 's'} available',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      0,
                      18,
                      28,
                    ),
                    sliver: SliverList.separated(
                      itemCount: providers.length,
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 13,
                      ),
                      itemBuilder: (context, index) {
                        final provider = providers[index];

                        return ProviderListCard(
                          provider: provider,
                          onTap: () {
                            _openProviderDetails(
                              provider,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _readableError(Object? error) {
    final text = error.toString();

    if (text.contains(
      'FAILED_PRECONDITION',
    )) {
      return 'Firestore requires an index for this query. Open the index link shown in the debug console and create the index.';
    }

    if (text.contains(
      'permission-denied',
    )) {
      return 'Firestore permission denied. Check your Firestore security rules.';
    }

    return text;
  }
}

class _CategoryBanner extends StatelessWidget {
  final ServiceCategory category;
  final int providerCount;

  const _CategoryBanner({
    required this.category,
    required this.providerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              category.icon,
              color: AppColors.darkBg,
              size: 35,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  category.description,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '$providerCount live provider'
                  '${providerCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProviderListCard extends StatelessWidget {
  final ProviderProfile provider;
  final VoidCallback onTap;

  const ProviderListCard({
    super.key,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.cardDark,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InitialsAvatar(
                    name: provider.name,
                    radius: 31,
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: provider.isLive
                            ? AppColors.success
                            : AppColors.textGrey,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.darkBg,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (provider.verified)
                          const Icon(
                            Icons.verified,
                            color: AppColors.success,
                            size: 19,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.mainService,
                      style: const TextStyle(
                        color: AppColors.primaryYellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.primaryYellow,
                          size: 18,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          provider.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.darkBg,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' (${provider.reviewCount})',
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.success,
                          size: 17,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            provider.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
