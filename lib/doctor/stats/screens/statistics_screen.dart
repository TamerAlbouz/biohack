import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/common/widgets/dividers/card_divider.dart';
import 'package:medtalk/doctor/stats/bloc/statistics_bloc.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../../common/widgets/custom_tab.dart';
import '../models/statistics_models.dart';
import '../widgets/card_info.dart';
import '../widgets/chart_info.dart';
import '../widgets/charts.dart';

class DoctorStatsScreen extends StatelessWidget {
  const DoctorStatsScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const DoctorStatsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return const DoctorStatsView();
  }
}

class DoctorStatsView extends StatefulWidget {
  const DoctorStatsView({super.key});

  @override
  State<DoctorStatsView> createState() => _DoctorStatsViewState();
}

class _DoctorStatsViewState extends State<DoctorStatsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showTimePeriodPicker(BuildContext context) {
    const line = DottedLine(
      direction: Axis.horizontal,
      lineLength: double.infinity,
      lineThickness: 1,
      dashLength: 4.0,
      dashColor: MyColors.softStroke,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: MyColors.cardBackground,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: kPadd16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Time Period',
                style: TextStyle(
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap10,
              Expanded(
                child: ListView(
                  children: [
                    _buildTimePeriodOption(context, 'This Week'),
                    line,
                    _buildTimePeriodOption(context, 'This Month'),
                    line,
                    _buildTimePeriodOption(context, 'This Quarter'),
                    line,
                    _buildTimePeriodOption(context, 'This Year'),
                    line,
                    _buildTimePeriodOption(context, 'All Time'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimePeriodOption(BuildContext context, String label) {
    bool isSelected = _selectedPeriod == label;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? MyColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Font.medium,
                color: isSelected ? MyColors.primary : MyColors.textBlack,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: MyColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: MyColors.background,
        foregroundColor: MyColors.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: const BoxDecoration(
              color: MyColors.background,
              border: Border(
                bottom: BorderSide(
                  color: MyColors.softStroke,
                  width: 1.0,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: MyColors.primary,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: const [
                CustomTab(text: 'Overview', icon: Icons.dashboard),
                CustomTab(text: 'Appointments', icon: Icons.calendar_today),
                CustomTab(text: 'Patients', icon: Icons.people),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Period selector
          Padding(
            padding: kPaddH20V10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.clock,
                      size: 18,
                      color: Colors.black,
                    ),
                    kGap6,
                    Text('Time Period', style: kSectionTitle),
                  ],
                ),
                InkWell(
                  onTap: () => _showTimePeriodPicker(context),
                  child: Container(
                    padding: kPaddH10V4,
                    decoration: BoxDecoration(
                      border: Border.all(color: MyColors.grey),
                      borderRadius: kRadius6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedPeriod,
                            style: const TextStyle(fontSize: Font.small)),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const CardDivider(
            padding: 20,
            height: 10,
            thickness: 1,
            color: MyColors.softStroke,
          ),

          // Main content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<DoctorStatsBloc>().add(
                      LoadDoctorStats(period: _getPeriodEnum(_selectedPeriod)),
                    );
              },
              child: BlocConsumer<DoctorStatsBloc, StatisticsState>(
                listener: (context, state) {
                  if (state is StatisticsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is StatisticsInitial) {
                    context.read<DoctorStatsBloc>().add(
                          LoadDoctorStats(
                              period: _getPeriodEnum(_selectedPeriod)),
                        );
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is StatisticsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is StatisticsLoaded) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _OverviewTab(stats: state),
                        _AppointmentsTab(stats: state),
                        _PatientsTab(stats: state),
                      ],
                    );
                  }

                  // Error state
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.circleExclamation,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        kGap20,
                        const Text(
                          'Error loading statistics',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: Font.medium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        kGap20,
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<DoctorStatsBloc>().add(
                                  LoadDoctorStats(
                                      period: _getPeriodEnum(_selectedPeriod)),
                                );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  StatsPeriod _getPeriodEnum(String period) {
    switch (period) {
      case 'This Week':
        return StatsPeriod.week;
      case 'This Month':
        return StatsPeriod.month;
      case 'This Quarter':
        return StatsPeriod.quarter;
      case 'This Year':
        return StatsPeriod.year;
      case 'All Time':
        return StatsPeriod.allTime;
      default:
        return StatsPeriod.month;
    }
  }
}

class _PatientsTab extends StatelessWidget {
  final StatisticsLoaded stats;

  const _PatientsTab({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: kPaddH20V14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patients overview
            _buildPatientsOverview(stats),
            kGap20,

            // New vs. returning patients
            ChartCard(
              title: 'New vs. Returning Patients',
              chart: _buildNewVsReturningChart(stats),
            ),
            kGap20,

            // Revenue per patient
            _buildRevenuePerPatient(stats),
            kGap20,

            // Referral sources
            _buildReferralSources(stats),
            kGap20,

            // Patient loyalty tiers
            _buildPatientLoyaltyTiers(stats),
            kGap20,
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsOverview(StatisticsLoaded stats) {
    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return CustomBase(
      shadow: false,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patients',
                    style: TextStyle(
                      fontSize: Font.medium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Patient statistics',
                    style: TextStyle(
                      fontSize: Font.small,
                      color: MyColors.subtitleDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: kPadd10,
                decoration: BoxDecoration(
                  color: MyColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.userGroup,
                  color: MyColors.primary,
                ),
              ),
            ],
          ),
          kGap14,
          const Divider(height: 1),
          kGap14,
          _buildPatientMetricRow(
            'Total Patients:',
            stats.totalPatients.toString(),
          ),
          _buildPatientMetricRow(
            'New Patients:',
            stats.newPatients.toString(),
          ),
          _buildPatientMetricRow(
            'Returning Patients:',
            (stats.totalPatients - stats.newPatients).toString(),
          ),
          _buildPatientMetricRow(
            'Patient Retention Rate:',
            '${stats.patientRetentionRate.toStringAsFixed(1)}%',
          ),
          _buildPatientMetricRow(
            'Average Visits per Patient:',
            stats.averageVisitsPerPatient.toStringAsFixed(1),
          ),
          _buildPatientMetricRow(
            'Average Revenue per Patient:',
            currencyFormat.format(stats.revenue /
                (stats.totalPatients > 0 ? stats.totalPatients : 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: Font.small,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: Font.small,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewVsReturningChart(StatisticsLoaded stats) {
    final newPatientsPercentage =
        (stats.newPatients / stats.totalPatients) * 100;
    final returningPatientsPercentage = 100 - newPatientsPercentage;

    return Row(
      children: [
        // Chart placeholder (replace with actual chart)
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: MyColors.primary,
              width: 10,
            ),
          ),
          child: Center(
            child: Text(
              '${newPatientsPercentage.toStringAsFixed(0)}%\nNew',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        kGap20,

        // Stats
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPatientTypeItem(
                'New Patients',
                stats.newPatients,
                newPatientsPercentage,
                Colors.green,
              ),
              kGap20,
              _buildPatientTypeItem(
                'Returning Patients',
                stats.totalPatients - stats.newPatients,
                returningPatientsPercentage,
                MyColors.primary,
              ),
              kGap10,
              Text(
                'Period: ${_getPeriodText(stats.period)}',
                style: const TextStyle(
                  fontSize: Font.extraSmall,
                  color: MyColors.subtitleDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientTypeItem(
      String label, int count, double percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        kGap6,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: Font.small,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap2,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: Font.small,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: Font.small,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRevenuePerPatient(StatisticsLoaded stats) {
    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Calculate averages
    final avgRevenue =
        stats.totalPatients > 0 ? stats.revenue / stats.totalPatients : 0.0;

    final avgRevenueNew = stats.newPatients > 0
        ? stats.revenue * 0.2 / stats.newPatients // Just for demonstration
        : 0.0;

    final avgRevenueReturning = (stats.totalPatients - stats.newPatients) > 0
        ? stats.revenue *
            0.8 /
            (stats.totalPatients - stats.newPatients) // Just for demonstration
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Revenue per Patient', style: kSectionTitle),
        kGap10,
        CustomBase(
          shadow: false,
          child: Column(
            children: [
              _buildValueBar(
                'Overall Average',
                avgRevenue,
                stats.totalPatients,
                currencyFormat.format(avgRevenue),
                Colors.blue,
              ),
              kGap14,
              _buildValueBar(
                'New Patients',
                avgRevenueNew,
                stats.newPatients,
                currencyFormat.format(avgRevenueNew),
                Colors.green,
              ),
              kGap14,
              _buildValueBar(
                'Returning Patients',
                avgRevenueReturning,
                stats.totalPatients - stats.newPatients,
                currencyFormat.format(avgRevenueReturning),
                MyColors.primary,
              ),
              kGap14,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueBar(
    String label,
    double value,
    int count,
    String formattedValue,
    Color color,
  ) {
    // Calculate width factor based on highest value
    const maxValue =
        2000.0; // This should be calculated dynamically in real app
    final widthFactor = (value / maxValue).clamp(0.05, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count patients',
              style: const TextStyle(
                fontSize: Font.extraSmall,
                color: MyColors.subtitleDark,
              ),
            ),
          ],
        ),
        kGap6,
        Stack(
          children: [
            Container(
              height: 24,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: widthFactor,
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    formattedValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Font.small,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReferralSources(StatisticsLoaded stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Referral Sources', style: kSectionTitle),
        kGap10,
        CustomBase(
          shadow: false,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: stats.referralSources.length,
            separatorBuilder: (context, index) => const DottedLine(
              dashLength: 4,
              lineThickness: 1,
              dashColor: MyColors.softStroke,
            ),
            itemBuilder: (context, index) {
              final source = stats.referralSources[index];
              return ListTile(
                contentPadding: kPadd0,
                dense: true,
                title: Text(
                  source.source,
                  style: const TextStyle(
                    fontSize: Font.small,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${source.count}',
                      style: const TextStyle(
                        fontSize: Font.small,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    kGap6,
                    Text(
                      '(${source.percentage.toStringAsFixed(1)}%)',
                      style: const TextStyle(
                        fontSize: Font.extraSmall,
                        color: MyColors.subtitleDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPatientLoyaltyTiers(StatisticsLoaded stats) {
    // This is a placeholder implementation with mock data
    // In a real app, you would calculate these tiers based on visit frequency and revenue

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Patient Loyalty Tiers', style: kSectionTitle),
        kGap10,
        CustomBase(
          shadow: false,
          child: Column(
            children: [
              _buildLoyaltyTier(
                'Platinum',
                'Over 10 visits, high value',
                stats.totalPatients > 10
                    ? (stats.totalPatients * 0.15).round()
                    : 0,
                Colors.purple,
              ),
              const DottedLine(
                dashLength: 4,
                lineThickness: 1,
                dashColor: MyColors.softStroke,
              ),
              _buildLoyaltyTier(
                'Gold',
                '6-10 visits, medium value',
                stats.totalPatients > 10
                    ? (stats.totalPatients * 0.25).round()
                    : 0,
                Colors.amber,
              ),
              const DottedLine(
                dashLength: 4,
                lineThickness: 1,
                dashColor: MyColors.softStroke,
              ),
              _buildLoyaltyTier(
                'Silver',
                '3-5 visits, standard value',
                stats.totalPatients > 10
                    ? (stats.totalPatients * 0.35).round()
                    : 0,
                Colors.grey,
              ),
              const DottedLine(
                dashLength: 4,
                lineThickness: 1,
                dashColor: MyColors.softStroke,
              ),
              _buildLoyaltyTier(
                'Bronze',
                '1-2 visits, new patients',
                stats.totalPatients > 10
                    ? (stats.totalPatients * 0.25).round()
                    : 0,
                Colors.brown,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoyaltyTier(
      String tier, String description, int count, Color color) {
    return ListTile(
      contentPadding: kPadd0,
      dense: true,
      leading: CircleAvatar(
        backgroundColor: color,
        radius: 20,
        child: Text(
          tier[0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        tier,
        style: const TextStyle(
          fontSize: Font.small,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(
          fontSize: Font.extraSmall,
          color: MyColors.subtitleDark,
        ),
      ),
      trailing: Text(
        count.toString(),
        style: const TextStyle(
          fontSize: Font.small,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPeriodText(StatsPeriod period) {
    switch (period) {
      case StatsPeriod.week:
        return 'This Week';
      case StatsPeriod.month:
        return 'This Month';
      case StatsPeriod.quarter:
        return 'This Quarter';
      case StatsPeriod.year:
        return 'This Year';
      case StatsPeriod.allTime:
        return 'All Time';
    }
  }
}

// Appointments Tab with Revenue Charts
class _AppointmentsTab extends StatelessWidget {
  final StatisticsLoaded stats;

  const _AppointmentsTab({required this.stats});

  @override
  Widget build(BuildContext context) {
    // Format currency

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: kPaddH20V14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointments overview
            _buildAppointmentsOverview(stats),
            kGap20,

            // Revenue by appointment type
            ChartCard(
              title: 'Revenue by Appointment Type',
              chart: AppointmentTypeRevenueChart(stats: stats),
            ),
            kGap20,

            // Revenue by day of week
            ChartCard(
              title: 'Revenue by Day of Week',
              chart: RevenueDayChart(stats: stats),
            ),
            kGap20,

            // Service revenue breakdown
            _buildServiceRevenueBreakdown(stats),
            kGap20,

            // Lost revenue analysis
            _buildLostRevenueAnalysis(stats),
            kGap20,
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsOverview(StatisticsLoaded stats) {
    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Calculate average revenue per appointment
    final avgRevenue = stats.totalAppointments > 0
        ? stats.revenue / stats.totalAppointments
        : 0.0;

    return CustomBase(
      shadow: false,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointments',
                    style: TextStyle(
                      fontSize: Font.medium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Revenue breakdown',
                    style: TextStyle(
                      fontSize: Font.small,
                      color: MyColors.subtitleDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: kPadd10,
                decoration: BoxDecoration(
                  color: MyColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.calendarWeek,
                  color: MyColors.primary,
                ),
              ),
            ],
          ),
          kGap14,
          const Divider(height: 1),
          kGap14,
          _buildAppointmentsMetricRow(
            'Total Revenue:',
            currencyFormat.format(stats.revenue),
          ),
          _buildAppointmentsMetricRow(
            'Avg. Revenue per Appointment:',
            currencyFormat.format(avgRevenue),
          ),
          _buildAppointmentsMetricRow(
            'Completed Appointments Revenue:',
            currencyFormat
                .format(stats.revenue * 0.95), // Simplified for example
          ),
          _buildAppointmentsMetricRow(
            'No-Show Appointments Lost Revenue:',
            currencyFormat
                .format(stats.revenue * 0.05), // Simplified for example
          ),
          _buildAppointmentsMetricRow(
            'Most Profitable Service:',
            stats.topServices.isNotEmpty ? stats.topServices[0].name : 'N/A',
          ),
          _buildAppointmentsMetricRow(
            'Most Profitable Day:',
            stats.busiestDays.isNotEmpty ? stats.busiestDays[0].day : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: Font.small,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: Font.small,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRevenueBreakdown(StatisticsLoaded stats) {
    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Revenue by Service', style: kSectionTitle),
        kGap10,
        CustomBase(
          shadow: false,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: stats.topServices.length.clamp(0, 5),
            separatorBuilder: (context, index) => const DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1,
              dashLength: 4.0,
              dashColor: MyColors.softStroke,
            ),
            itemBuilder: (context, index) {
              final service = stats.topServices[index];
              final percentage = (service.revenue / stats.revenue) * 100;

              return ListTile(
                contentPadding: kPadd0,
                dense: true,
                title: Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: Font.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  color: Colors.blue,
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currencyFormat.format(service.revenue),
                      style: const TextStyle(
                        fontSize: Font.small,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: Font.extraSmall,
                        color: MyColors.subtitleDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLostRevenueAnalysis(StatisticsLoaded stats) {
    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // This is placeholder data - in a real app you would calculate lost revenue from cancellations and no-shows
    final lostRevenue = stats.revenue * 0.15; // Example: 15% of revenue lost
    final noShowLoss = lostRevenue * 0.6;
    final cancellationLoss = lostRevenue * 0.4;
    final potentialRevenue = stats.revenue + lostRevenue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lost Revenue Analysis', style: kSectionTitle),
        kGap10,
        CustomBase(
          shadow: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Potential Revenue:',
                    style: TextStyle(
                      fontSize: Font.small,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currencyFormat.format(potentialRevenue),
                    style: const TextStyle(
                      fontSize: Font.small,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              kGap10,
              Stack(
                children: [
                  Container(
                    height: 24,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: MyColors.blueGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: stats.revenue / potentialRevenue,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          'Actual: ${currencyFormat.format(stats.revenue)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Font.small,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              kGap14,
              const Divider(height: 1),
              kGap14,
              _buildAppointmentsMetricRow(
                'Total Lost Revenue:',
                currencyFormat.format(lostRevenue),
              ),
              _buildAppointmentsMetricRow(
                'No-Show Losses:',
                currencyFormat.format(noShowLoss),
              ),
              _buildAppointmentsMetricRow(
                'Cancellation Losses:',
                currencyFormat.format(cancellationLoss),
              ),
              _buildAppointmentsMetricRow(
                'Lost Revenue Percentage:',
                '${((lostRevenue / potentialRevenue) * 100).toStringAsFixed(1)}%',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Overview Tab Implementation with Charts
class _OverviewTab extends StatelessWidget {
  final StatisticsLoaded stats;

  const _OverviewTab({required this.stats});

  @override
  Widget build(BuildContext context) {
    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: kPaddH20V14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Summary',
              style: kSectionTitle,
            ),
            kGap14,

            // Key metrics in a grid
            Row(
              children: [
                Expanded(
                  child: StatInfoCard(
                    title: 'Total Revenue',
                    value: currencyFormat.format(stats.revenue),
                    icon: FontAwesomeIcons.dollarSign,
                    iconColor: Colors.green,
                    change: stats.revenueChange,
                    isIncreasePositive: true,
                  ),
                ),
                kGap10,
                Expanded(
                  child: StatInfoCard(
                    title: 'Avg. Per App.',
                    value: currencyFormat.format(
                      stats.totalAppointments > 0
                          ? stats.revenue / stats.totalAppointments
                          : 0,
                    ),
                    icon: FontAwesomeIcons.chartLine,
                    iconColor: Colors.blue,
                    change: 2.5,
                    // Placeholder
                    isIncreasePositive: true,
                  ),
                ),
              ],
            ),
            kGap10,
            Row(
              children: [
                Expanded(
                  child: StatInfoCard(
                    title: 'Comp. Revenue',
                    value: currencyFormat.format(stats.revenue * 0.95),
                    // Simplified
                    icon: FontAwesomeIcons.check,
                    iconColor: Colors.purple,
                    change: 3.2,
                    // Placeholder
                    isIncreasePositive: true,
                  ),
                ),
                kGap10,
                Expanded(
                  child: StatInfoCard(
                    title: 'Lost Revenue',
                    value: currencyFormat.format(stats.revenue * 0.05),
                    // Simplified
                    icon: FontAwesomeIcons.ban,
                    iconColor: Colors.red,
                    change: -1.8,
                    // Placeholder
                    isIncreasePositive: false,
                  ),
                ),
              ],
            ),
            kGap30,

            // Monthly revenue chart
            ChartCard(
              title: 'Monthly Revenue Trend',
              chart: MonthlyRevenueChart(stats: stats),
            ),
            kGap30,

            // Revenue by service type
            ChartCard(
              title: 'Revenue by Service Type',
              chart: ServiceRevenueChart(stats: stats),
            ),
            kGap30,

            // Top revenue sources
            _buildTopRevenueServices(stats),
            kGap30,

            // Revenue forecast
            _buildRevenueForecast(stats),
            kGap20,
          ],
        ),
      ),
    );
  }

  Widget _buildTopRevenueServices(StatisticsLoaded stats) {
    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top Revenue Services', style: kSectionTitle),
        kGap10,
        CustomBase(
          shadow: false,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: stats.topServices.length.clamp(0, 5),
            separatorBuilder: (context, index) => const DottedLine(
              dashLength: 4,
              lineThickness: 1,
              dashColor: MyColors.softStroke,
            ),
            itemBuilder: (context, index) {
              final service = stats.topServices[index];
              final percentage = (service.revenue / stats.revenue) * 100;

              return ListTile(
                contentPadding: kPadd0,
                dense: true,
                title: Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: Font.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${service.count} appointments',
                  style: const TextStyle(
                    fontSize: Font.extraSmall,
                  ),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currencyFormat.format(service.revenue),
                      style: const TextStyle(
                        fontSize: Font.small,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: Font.extraSmall,
                        color: MyColors.subtitleDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueForecast(StatisticsLoaded stats) {
    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Simple forecast based on current revenue and growth rate
    final forecast = stats.revenue * (1 + (stats.revenueChange / 100));
    final optimisticForecast = forecast * 1.1;
    final pessimisticForecast = forecast * 0.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Revenue Forecast', style: kSectionTitle),
        kGap10,
        CustomBase(
          shadow: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Period:',
                    style: TextStyle(
                      fontSize: Font.small,
                    ),
                  ),
                  Text(
                    currencyFormat.format(stats.revenue),
                    style: const TextStyle(
                      fontSize: Font.small,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              kGap10,
              const Divider(height: 1),
              kGap10,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Next Period Forecast:',
                    style: TextStyle(
                      fontSize: Font.small,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currencyFormat.format(forecast),
                    style: const TextStyle(
                      fontSize: Font.small,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              kGap6,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Optimistic Scenario:',
                    style: TextStyle(
                      fontSize: Font.small,
                    ),
                  ),
                  Text(
                    currencyFormat.format(optimisticForecast),
                    style: const TextStyle(
                      fontSize: Font.small,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              kGap6,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pessimistic Scenario:',
                    style: TextStyle(
                      fontSize: Font.small,
                    ),
                  ),
                  Text(
                    currencyFormat.format(pessimisticForecast),
                    style: const TextStyle(
                      fontSize: Font.small,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              kGap14,
              const Text(
                'Based on your current growth rate and seasonality patterns',
                style: TextStyle(
                  fontSize: Font.extraSmall,
                  color: MyColors.subtitleDark,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
