import 'package:flutter/material.dart';
import 'package:service_hub/new/auth_Service.dart';
import 'package:service_hub/new/new_role_Selection.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/provider_list_screen.dart';
import 'package:service_hub/new/user_booking.dart';
import 'package:service_hub/services/old_auth.dart';
import '../theme/app_theme.dart';

class SelectServiceScreen extends StatefulWidget {
  const SelectServiceScreen({
    super.key,
  });

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _loggingOut = false;

  // List<ServiceCategory> get _filteredCategories {
  //   final query = _searchQuery.trim().toLowerCase();

  //   if (query.isEmpty) {
  //     return kServiceCategories;
  //   }

  //   return kServiceCategories.where(
  //     (category) {
  //       return category.name.toLowerCase().contains(query) ||
  //           category.description.toLowerCase().contains(query);
  //     },
  //   ).toList();
  // }

  void _openProviderList(
    ServiceCategory category,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderListScreen(
          category: category.name,
        ),
      ),
    );
  }

  void _openBookings() {
    final userId = AuthService.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your session has expired. Please login again.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserBookingsScreen(
          userId: userId,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    if (_loggingOut) return;

    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Logout?',
      message: 'Are you sure you want to logout from KaamSetu?',
      confirmLabel: 'Logout',
      destructive: true,
    );

    if (!confirmed) return;

    setState(() {
      _loggingOut = true;
    });

    try {
      await AuthService.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const RoleSelectScreen(),
        ),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not logout. Please try again.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loggingOut = false;
        });
      }
    }
  }

  void _showMoreServices() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              4,
              18,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'All Services',
                  style: TextStyle(
                    color: AppColors.darkBg,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 14),
                // Flexible(
                //   child: ListView.separated(
                //     shrinkWrap: true,
                //     itemCount: kServiceCategories.length,
                //     separatorBuilder: (_, __) => const Divider(height: 1),
                //     itemBuilder: (context, index) {
                //       final category = kServiceCategories[index];

                //       return ListTile(
                //         leading: Container(
                //           width: 42,
                //           height: 42,
                //           decoration: BoxDecoration(
                //             color: AppColors.primaryYellow,
                //             borderRadius: BorderRadius.circular(
                //               11,
                //             ),
                //           ),
                //           child: Icon(
                //             category.icon,
                //             color: AppColors.darkBg,
                //           ),
                //         ),
                //         title: Text(
                //           category.name,
                //           style: const TextStyle(
                //             fontWeight: FontWeight.w600,
                //           ),
                //         ),
                //       //   subtitle: Text(
                //       //   //   // category.description,
                //       //   //   maxLines: 1,
                //       //   //   overflow: TextOverflow.ellipsis,
                //       //   // ),
                //       //   trailing: const Icon(
                //       //     Icons.chevron_right,
                //       //   ),
                //       //   onTap: () {
                //       //     Navigator.of(sheetContext).pop();

                //       //     _openProviderList(
                //       //       category,
                //       //     );
                //       //   },
                //       // );
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final categories = _filteredCategories;

    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Select Service'),
        actions: [
          IconButton(
            tooltip: 'My Bookings',
            onPressed: _openBookings,
            icon: const Icon(
              Icons.calendar_month_outlined,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'bookings') {
                _openBookings();
              }

              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'bookings',
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                    ),
                    SizedBox(width: 10),
                    Text('My Bookings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: AppColors.danger,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Text('Select Service Screen'),
        // child: RefreshIndicator(
        //   onRefresh: () async {
        //     setState(() {});
        //   },
        //   child: CustomScrollView(
        //     physics: const AlwaysScrollableScrollPhysics(),
        //     slivers: [
        //       SliverToBoxAdapter(
        //         child: Padding(
        //           padding: const EdgeInsets.fromLTRB(
        //             18,
        //             18,
        //             18,
        //             0,
        //           ),
        //           child: _WelcomeBanner(
        //             onBookings: _openBookings,
        //           ),
        //         ),
        //       ),
        //       SliverToBoxAdapter(
        //         child: Padding(
        //           padding: const EdgeInsets.fromLTRB(
        //             18,
        //             18,
        //             18,
        //             0,
        //           ),
        //           child: TextField(
        //             controller: _searchController,
        //             textInputAction: TextInputAction.search,
        //             decoration: InputDecoration(
        //               hintText: 'Search for a service...',
        //               prefixIcon: const Icon(
        //                 Icons.search,
        //               ),
        //               suffixIcon: _searchQuery.isEmpty
        //                   ? null
        //                   : IconButton(
        //                       onPressed: () {
        //                         _searchController.clear();

        //                         setState(() {
        //                           _searchQuery = '';
        //                         });
        //                       },
        //                       icon: const Icon(
        //                         Icons.close,
        //                       ),
        //                     ),
        //             ),
        //             onChanged: (value) {
        //               setState(() {
        //                 _searchQuery = value;
        //               });
        //             },
        //           ),
        //         ),
        //       ),
        //       SliverToBoxAdapter(
        //         child: Padding(
        //           padding: const EdgeInsets.fromLTRB(
        //             18,
        //             20,
        //             18,
        //             12,
        //           ),
        //           child: SectionHeader(
        //             title: _searchQuery.isEmpty
        //                 ? 'Choose a Service'
        //                 : 'Search Results',
        //             actionLabel: _searchQuery.isEmpty ? 'View All' : null,
        //             onAction: _searchQuery.isEmpty ? _showMoreServices : null,
        //           ),
        //         ),
        //       ),
        //       if (categories.isEmpty)
        //         const SliverFillRemaining(
        //           hasScrollBody: false,
        //           child: EmptyStateWidget(
        //             icon: Icons.search_off,
        //             title: 'No Service Found',
        //             message: 'Try searching with another service name.',
        //           ),
        //         )
        //       else
        //         SliverPadding(
        //           padding: const EdgeInsets.fromLTRB(
        //             18,
        //             0,
        //             18,
        //             30,
        //           ),
        //           sliver: SliverGrid(
        //             delegate: SliverChildBuilderDelegate(
        //               (context, index) {
        //                 final category = categories[index];

        //                 return ServiceCategoryCard(
        //                   category: category,
        //                   onTap: () {
        //                     _openProviderList(
        //                       category,
        //                     );
        //                   },
        //                 );
        //               },
        //               childCount: categories.length,
        //             ),
        //             gridDelegate:
        //                 const SliverGridDelegateWithFixedCrossAxisCount(
        //               crossAxisCount: 2,
        //               mainAxisSpacing: 13,
        //               crossAxisSpacing: 13,
        //               childAspectRatio: 1.02,
        //             ),
        //           ),
        //         ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final VoidCallback onBookings;

  const _WelcomeBanner({
    required this.onBookings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What service do you need?',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Find trusted local providers and contact them directly.',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: onBookings,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    'View My Bookings',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.handyman_outlined,
              color: AppColors.darkBg,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCategoryCard extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback onTap;

  const ServiceCategoryCard({
    super.key,
    required this.category,
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
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.cardDark,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 57,
                height: 57,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
                child: Icon(
                  category.icon,
                  color: AppColors.darkBg,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.darkBg,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              // Text(
              //   category.description,
              //   maxLines: 2,
              //   overflow: TextOverflow.ellipsis,
              //   textAlign: TextAlign.center,
              //   style: const TextStyle(
              //     color: AppColors.textGrey,
              //     fontSize: 10,
              //     height: 1.3,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
