import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'package:intl/intl.dart';

enum DateRange { day, week, month }

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final DateRange selectedRange;
  final Function(DateTime, DateRange) onDateRangeChanged;

  const DateSelector({
    Key? key,
    required this.selectedDate,
    required this.selectedRange,
    required this.onDateRangeChanged,
  }) : super(key: key);

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime _selectedDate;
  late DateRange _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedRange = widget.selectedRange;
  }

  void _previousDate() {
    DateTime newDate;
    switch (_selectedRange) {
      case DateRange.day:
        newDate = _selectedDate.subtract(const Duration(days: 1));
        break;
      case DateRange.week:
        newDate = _selectedDate.subtract(const Duration(days: 7));
        break;
      case DateRange.month:
        // Go back one month, keeping the same day if possible
        final int year = _selectedDate.month == 1 ? _selectedDate.year - 1 : _selectedDate.year;
        final int month = _selectedDate.month == 1 ? 12 : _selectedDate.month - 1;
        final int daysInMonth = DateUtils.getDaysInMonth(year, month);
        final int day = _selectedDate.day > daysInMonth ? daysInMonth : _selectedDate.day;
        newDate = DateTime(year, month, day);
        break;
    }
    
    setState(() {
      _selectedDate = newDate;
    });
    widget.onDateRangeChanged(newDate, _selectedRange);
  }

  void _nextDate() {
    DateTime newDate;
    switch (_selectedRange) {
      case DateRange.day:
        newDate = _selectedDate.add(const Duration(days: 1));
        break;
      case DateRange.week:
        newDate = _selectedDate.add(const Duration(days: 7));
        break;
      case DateRange.month:
        // Go forward one month, keeping the same day if possible
        final int year = _selectedDate.month == 12 ? _selectedDate.year + 1 : _selectedDate.year;
        final int month = _selectedDate.month == 12 ? 1 : _selectedDate.month + 1;
        final int daysInMonth = DateUtils.getDaysInMonth(year, month);
        final int day = _selectedDate.day > daysInMonth ? daysInMonth : _selectedDate.day;
        newDate = DateTime(year, month, day);
        break;
    }
    
    // Don't allow selection of future dates beyond today
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    
    if (_selectedRange == DateRange.day && newDate.isAfter(today)) {
      newDate = today;
    } else if (_selectedRange == DateRange.week && 
        newDate.isAfter(today.subtract(const Duration(days: today.weekday - 1)))) {
      // Set to the start of current week
      newDate = today.subtract(Duration(days: today.weekday - 1));
    } else if (_selectedRange == DateRange.month && 
        newDate.isAfter(DateTime(today.year, today.month, 1))) {
      // Set to the first day of current month
      newDate = DateTime(today.year, today.month, 1);
    }
    
    setState(() {
      _selectedDate = newDate;
    });
    widget.onDateRangeChanged(newDate, _selectedRange);
  }

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      widget.onDateRangeChanged(pickedDate, _selectedRange);
    }
  }

  void _changeRange(DateRange range) {
    setState(() {
      _selectedRange = range;
    });
    widget.onDateRangeChanged(_selectedDate, range);
  }

  String _getFormattedDateRange() {
    final DateFormat dayFormat = DateFormat('MMM d, yyyy');
    final DateFormat monthFormat = DateFormat('MMMM yyyy');
    
    switch (_selectedRange) {
      case DateRange.day:
        return dayFormat.format(_selectedDate);
      case DateRange.week:
        // Calculate the start and end dates of the week
        final DateTime startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${dayFormat.format(startOfWeek)} - ${dayFormat.format(endOfWeek)}';
      case DateRange.month:
        // For month, show the month and year
        return monthFormat.format(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date range selector tabs
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorderRadius.md,
            boxShadow: [AppShadows.small],
          ),
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: _buildRangeButton(DateRange.day, 'Day'),
              ),
              Expanded(
                child: _buildRangeButton(DateRange.week, 'Week'),
              ),
              Expanded(
                child: _buildRangeButton(DateRange.month, 'Month'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Date navigator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousDate,
            ),
            GestureDetector(
              onTap: _selectDate,
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _getFormattedDateRange(),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _isAtCurrentDate() ? null : _nextDate,
              color: _isAtCurrentDate() ? Colors.grey : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRangeButton(DateRange range, String label) {
    final bool isSelected = _selectedRange == range;
    
    return GestureDetector(
      onTap: () => _changeRange(range),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppBorderRadius.sm,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textDark,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  bool _isAtCurrentDate() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    
    switch (_selectedRange) {
      case DateRange.day:
        // Check if selected date is today
        return _selectedDate.year == today.year &&
               _selectedDate.month == today.month &&
               _selectedDate.day == today.day;
      case DateRange.week:
        // Check if selected week is current week
        final DateTime startOfSelectedWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final DateTime startOfCurrentWeek = today.subtract(Duration(days: today.weekday - 1));
        return startOfSelectedWeek.year == startOfCurrentWeek.year &&
               startOfSelectedWeek.month == startOfCurrentWeek.month &&
               startOfSelectedWeek.day == startOfCurrentWeek.day;
      case DateRange.month:
        // Check if selected month is current month
        return _selectedDate.year == today.year &&
               _selectedDate.month == today.month;
    }
  }
} 