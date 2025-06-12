import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../components/headers/nav_header.dart';
import '../../../components/admin/forms/announcement_form.dart';
import '../../../components/admin/forms/components/sent_announcements_list.dart';

class AnnouncementsView extends StatefulWidget {
  const AnnouncementsView({super.key});

  @override
  State<AnnouncementsView> createState() => _AnnouncementsViewState();
}

class _AnnouncementsViewState extends State<AnnouncementsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.announcements),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: AppTheme.getMediumPadding(screenSize),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.getShadowColor(context),
                        blurRadius: screenSize.height * 0.01,
                        offset: Offset(0, screenSize.height * 0.003),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: AppTheme.accentPurple,
                        unselectedLabelColor:
                            AppTheme.getTextSecondaryColor(context),
                        indicatorColor: AppTheme.accentPurple,
                        indicatorWeight: 3,
                        labelStyle: AppTheme.getSubtitle1(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle:
                            AppTheme.getSubtitle1(screenSize).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: [
                          Tab(text: l10n.createAnnouncement),
                          Tab(text: l10n.recentActivity),
                        ],
                      ),
                      SizedBox(
                        height: screenSize.height * 0.7,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            AnnouncementForm(screenSize: screenSize),
                            SentAnnouncementsList(screenSize: screenSize),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppTheme.getLargePadding(screenSize)),
              ),
            ],
          ),
        );
      },
    );
  }
}
