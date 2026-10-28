import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

/// Events & Village Calendar screen for Dhawalpuri (ढवळपुरी) - Blueprint 8.
/// Supports search, 10 categories, chronological upcoming events,
/// featured event card, lightweight monthly calendar view, and event suggestions.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

enum EventsViewMode { list, calendar }

class _EventsScreenState extends State<EventsScreen> {
  final EventRepository _repository = MockEventRepository();
  final TextEditingController _searchController = TextEditingController();

  EventsViewMode _viewMode = EventsViewMode.list;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  // Calendar State
  late DateTime _calendarMonth;
  late DateTime _selectedDate;

  List<VillageEvent> _allEvents = [];
  List<VillageEvent> _upcomingEvents = [];
  VillageEvent? _featuredEvent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final all = await _repository.getAllEvents();
    final upcoming = await _repository.getUpcomingEvents();
    final featured = await _repository.getFeaturedEvent();

    if (mounted) {
      setState(() {
        _allEvents = all;
        _upcomingEvents = upcoming;
        _featuredEvent = featured;
        _isLoading = false;
      });
    }
  }

  // Filtered upcoming events for List View
  List<VillageEvent> get _filteredUpcomingEvents {
    return _upcomingEvents.where((e) {
      // Category filter
      if (_selectedCategory != 'all' && e.category != _selectedCategory) {
        return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final title = context.translate(e.titleKey).toLowerCase();
        final desc = context.translate(e.descriptionKey).toLowerCase();
        final venue = context.translate(e.venueKey).toLowerCase();
        final org = e.organizerKey != null ? context.translate(e.organizerKey!).toLowerCase() : '';

        return title.contains(q) || desc.contains(q) || venue.contains(q) || org.contains(q);
      }
      return true;
    }).toList();
  }

  // Events occurring on the selected date for Calendar View
  List<VillageEvent> get _eventsForSelectedDate {
    return _allEvents.where((e) {
      final s = e.startDateTime;
      final startDay = DateTime(s.year, s.month, s.day);

      if (e.endDateTime != null) {
        final endDay = DateTime(
          e.endDateTime!.year,
          e.endDateTime!.month,
          e.endDateTime!.day,
        );
        final checkDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        return (checkDay.isAtSameMomentAs(startDay) || checkDay.isAfter(startDay)) &&
            (checkDay.isAtSameMomentAs(endDay) || checkDay.isBefore(endDay));
      }

      return s.year == _selectedDate.year &&
          s.month == _selectedDate.month &&
          s.day == _selectedDate.day;
    }).toList();
  }

  bool _dateHasEvents(DateTime date) {
    return _allEvents.any((e) {
      final s = e.startDateTime;
      final startDay = DateTime(s.year, s.month, s.day);

      if (e.endDateTime != null) {
        final endDay = DateTime(
          e.endDateTime!.year,
          e.endDateTime!.month,
          e.endDateTime!.day,
        );
        final checkDay = DateTime(date.year, date.month, date.day);
        return (checkDay.isAtSameMomentAs(startDay) || checkDay.isAfter(startDay)) &&
            (checkDay.isAtSameMomentAs(endDay) || checkDay.isBefore(endDay));
      }

      return s.year == date.year && s.month == date.month && s.day == date.day;
    });
  }

  void _previousMonth() {
    setState(() {
      if (_calendarMonth.month == 1) {
        _calendarMonth = DateTime(_calendarMonth.year - 1, 12, 1);
      } else {
        _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1, 1);
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_calendarMonth.month == 12) {
        _calendarMonth = DateTime(_calendarMonth.year + 1, 1, 1);
      } else {
        _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('events_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              context.translate('events_subtitle'),
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                    : theme.colorScheme.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
        foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: context.translate('event_suggest'),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.eventSuggest);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.eventSuggest);
        },
        icon: const Icon(Icons.edit_calendar_rounded),
        label: Text(context.translate('event_suggest')),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. Top Controls: Search Bar & View Mode Toggle ---
            Padding(
              padding: const EdgeInsets.only(
                left: AppSizes.space16,
                right: AppSizes.space16,
                top: AppSizes.space12,
                bottom: AppSizes.space8,
              ),
              child: Column(
                children: [
                  SearchField(
                    controller: _searchController,
                    hintText: context.translate('search_events_hint'),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  // Segmented toggle between List and Calendar views
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<EventsViewMode>(
                      segments: [
                        ButtonSegment<EventsViewMode>(
                          value: EventsViewMode.list,
                          icon: const Icon(Icons.view_agenda_rounded, size: 18),
                          label: Text(context.translate('events_view_list')),
                        ),
                        ButtonSegment<EventsViewMode>(
                          value: EventsViewMode.calendar,
                          icon: const Icon(Icons.calendar_month_rounded, size: 18),
                          label: Text(context.translate('events_view_calendar')),
                        ),
                      ],
                      selected: {_viewMode},
                      onSelectionChanged: (Set<EventsViewMode> newSelection) {
                        setState(() {
                          _viewMode = newSelection.first;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. Main Body: List View OR Calendar View ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _viewMode == EventsViewMode.list
                      ? _buildListView(context)
                      : _buildCalendarView(context),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LIST VIEW: Featured Card, 10 Categories, Upcoming
  // ==========================================
  Widget _buildListView(BuildContext context) {
    final theme = Theme.of(context);
    final events = _filteredUpcomingEvents;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.only(
          left: AppSizes.space16,
          right: AppSizes.space16,
          bottom: 80, // Space for FAB
        ),
        children: [
          // 1. Featured Event Card (when available and not filtered out by search)
          if (_featuredEvent != null && _searchQuery.isEmpty && _selectedCategory == 'all') ...[
            _buildFeaturedCard(context, _featuredEvent!),
            const SizedBox(height: AppSizes.space16),
          ],

          // 2. Category Filter Chips (10 Blueprint 8 categories)
          Text(
            context.translate('event_categories'),
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.space8),
          _buildCategoryFilterRow(context),
          const SizedBox(height: AppSizes.space16),

          // 3. Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.translate('upcoming_events'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${events.length} ${context.translate('events_title').toLowerCase()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space12),

          // 4. Upcoming Events List or Empty State
          if (events.isEmpty)
            _buildEmptyState(context)
          else
            ...events.map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.space12),
                  child: _buildEventCard(context, event),
                )),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, VillageEvent event) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        side: BorderSide(
          color: event.color.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.eventDetail,
            arguments: {'event': event},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Gradient Header with Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    event.color,
                    event.color.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: AppSizes.space8),
                  Text(
                    context.translate('featured_event').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                    child: Text(
                      context.translate('cat_ev_${event.category}'),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate(event.titleKey),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    context.translate(event.descriptionKey),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.space12),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 14, color: event.color),
                      const SizedBox(width: 4),
                      Text(
                        event.dateKey,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Icon(Icons.access_time_rounded, size: 14, color: event.color),
                      const SizedBox(width: 4),
                      Text(
                        event.timeKey,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: theme.colorScheme.error),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          context.translate(event.venueKey),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(context.translate('view_details')),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.eventDetail,
                          arguments: {'event': event},
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: event.color,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterRow(BuildContext context) {
    final theme = Theme.of(context);

    // List of categories: 'all' + 10 official categories
    final categories = [
      'all',
      ...EventCategoryInfo.allCategories.map((c) => c.id),
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final catId = categories[index];
          final isSelected = _selectedCategory == catId;

          final label = catId == 'all'
              ? context.translate('all')
              : context.translate('cat_ev_$catId');

          final color = catId == 'all'
              ? theme.colorScheme.primary
              : EventCategoryInfo.getColorForCategory(catId);

          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.space8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = catId;
                });
              },
              selectedColor: color.withValues(alpha: 0.2),
              checkmarkColor: color,
              side: BorderSide(
                color: isSelected ? color : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, VillageEvent event) {
    final theme = Theme.of(context);
    final status = event.computedStatus;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.eventDetail,
            arguments: {'event': event},
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular category icon
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space8),
                    decoration: BoxDecoration(
                      color: event.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      event.icon,
                      size: AppSizes.iconMD,
                      color: event.color,
                    ),
                  ),
                  const SizedBox(width: AppSizes.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: event.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                              ),
                              child: Text(
                                context.translate('cat_ev_${event.category}').toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: event.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9.0,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (status != EventStatus.upcoming)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: status.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                                ),
                                child: Text(
                                  context.translate(status.translationKey).toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: status.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.space4),
                        Text(
                          context.translate(event.titleKey),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                context.translate(event.descriptionKey),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13.0,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.space12),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.space8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        event.dateKey,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: theme.colorScheme.error),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          context.translate(event.venueKey),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.space24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 56,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSizes.space16),
          Text(
            context.translate('no_upcoming_events'),
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.space8),
          Text(
            context.translate('empty_events_desc'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.space16),
          if (_selectedCategory != 'all' || _searchQuery.isNotEmpty)
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'all';
                  _searchController.clear();
                });
              },
              child: Text(context.translate('clear_filters')),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // CALENDAR VIEW: Monthly Grid & Selected Date Events
  // ==========================================
  Widget _buildCalendarView(BuildContext context) {
    final theme = Theme.of(context);
    final eventsOnDate = _eventsForSelectedDate;

    return ListView(
      padding: const EdgeInsets.only(
        left: AppSizes.space16,
        right: AppSizes.space16,
        bottom: 80,
      ),
      children: [
        // 1. Calendar Card with Navigation & Grid
        Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.space12),
            child: Column(
              children: [
                // Month Header & Navigation controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      tooltip: 'Previous month',
                      onPressed: _previousMonth,
                    ),
                    Text(
                      '${context.translate('cal_month_${_calendarMonth.month}')} ${_calendarMonth.year}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      tooltip: 'Next month',
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.space8),

                // Weekday Header Row (Sun - Sat)
                _buildWeekdayHeader(context),
                const SizedBox(height: AppSizes.space8),

                // Monthly Days Grid
                _buildDaysGrid(context),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.space20),

        // 2. Selected Date Events Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedDate.day} ${context.translate('cal_month_${_selectedDate.month}')} ${_selectedDate.year}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Text(
                '${eventsOnDate.length} ${context.translate('events_title').toLowerCase()}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space12),

        // Events list for selected date
        if (eventsOnDate.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSizes.space24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Text(
              context.translate('no_events_on_date'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...eventsOnDate.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.space12),
                child: _buildEventCard(context, event),
              )),
      ],
    );
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    final theme = Theme.of(context);
    final days = [
      'cal_day_sun',
      'cal_day_mon',
      'cal_day_tue',
      'cal_day_wed',
      'cal_day_thu',
      'cal_day_fri',
      'cal_day_sat',
    ];

    return Row(
      children: days.map((dayKey) {
        return Expanded(
          child: Center(
            child: Text(
              context.translate(dayKey),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaysGrid(BuildContext context) {
    final theme = Theme.of(context);
    final year = _calendarMonth.year;
    final month = _calendarMonth.month;

    // Number of days in the month (handles leap years cleanly)
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // First day weekday (Sunday = 0, Monday = 1, ... Saturday = 6)
    final firstWeekday = DateTime(year, month, 1).weekday;
    final leadingOffset = firstWeekday % 7; // Sunday=7 -> 0

    final totalCells = ((leadingOffset + daysInMonth + 6) ~/ 7) * 7;
    final now = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        if (index < leadingOffset || index >= leadingOffset + daysInMonth) {
          return const SizedBox.shrink();
        }

        final dayNumber = index - leadingOffset + 1;
        final cellDate = DateTime(year, month, dayNumber);

        final isSelected = _selectedDate.year == cellDate.year &&
            _selectedDate.month == cellDate.month &&
            _selectedDate.day == cellDate.day;

        final isToday = now.year == cellDate.year &&
            now.month == cellDate.month &&
            now.day == cellDate.day;

        final hasEvents = _dateHasEvents(cellDate);

        return InkWell(
          onTap: () {
            setState(() {
              _selectedDate = cellDate;
            });
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isToday
                      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              border: isToday && !isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                if (hasEvents)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
