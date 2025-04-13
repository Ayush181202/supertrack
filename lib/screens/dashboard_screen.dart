import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/meal_model.dart';
import '../models/water_intake_model.dart';
import '../models/user_model.dart' as app_models;
import '../services/firebase_service.dart';
import '../widgets/date_selector.dart';
import '../widgets/progress_bar.dart';
import '../widgets/macronutrient_pie_chart.dart';
import '../widgets/calorie_trend_chart.dart';
import '../widgets/meal_list_item.dart';
import '../widgets/quick_add_meal_dialog.dart';
import '../widgets/water_intake_tracker.dart';
import '../widgets/step_counter_widget.dart';
import '../widgets/add_water_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late DateTime _selectedDate;
  late DateRange _selectedRange;
  List<Meal> _meals = [];
  double _waterIntake = 0.0;
  bool _isLoading = true;
  String _errorMessage = '';
  
  // User data
  late app_models.User _user;
  
  // Default values in case user data fails to load
  String _userName = "User";
  int _calorieGoal = 2000;
  int _proteinGoal = 120;
  int _carbsGoal = 200;
  int _fatGoal = 65;
  double _waterGoal = 2.5;
  int _stepGoal = 10000;
  
  // Chart data
  List<double> _calorieData = [];
  List<String> _dateLabels = [];
  
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedRange = DateRange.day;
    
    // Load data
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Get user data
      final app_models.User? userData = await _firebaseService.getUserData();
      if (userData != null) {
        _user = userData;
        _userName = userData.name;
        _calorieGoal = userData.calorieGoal;
        _proteinGoal = userData.proteinGoal;
        _carbsGoal = userData.carbsGoal;
        _fatGoal = userData.fatGoal;
        _waterGoal = userData.waterGoal;
        _stepGoal = userData.stepGoal;
      } else {
        // Use default values if user data is not available
        _errorMessage = 'Failed to load user data. Using default values.';
      }
      
      // Load meals for the selected date
      await _loadMeals();
      
      // Load water intake data
      await _loadWaterIntake();
      
      // Load weekly calorie data for charts
      await _loadWeeklyCalorieData();
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadMeals() async {
    try {
      final meals = await _firebaseService.getMeals(_selectedDate);
      setState(() {
        _meals = meals;
      });
    } catch (e) {
      print('Error loading meals: $e');
      setState(() {
        _errorMessage = 'Failed to load meals';
      });
    }
  }
  
  Future<void> _loadWaterIntake() async {
    try {
      final waterIntake = await _firebaseService.getTotalWaterIntake(_selectedDate);
      setState(() {
        _waterIntake = waterIntake;
      });
    } catch (e) {
      print('Error loading water intake: $e');
      setState(() {
        _errorMessage = 'Failed to load water intake';
      });
    }
  }
  
  Future<void> _loadWeeklyCalorieData() async {
    try {
      final result = await _firebaseService.getWeeklyCalorieData(_selectedDate);
      setState(() {
        _calorieData = List<double>.from(result['data']);
        _dateLabels = List<String>.from(result['labels']);
      });
    } catch (e) {
      print('Error loading weekly calorie data: $e');
      setState(() {
        // Use mock data if real data fails to load
        _calorieData = [1750, 1900, 2100, 1850, 1950, 2000, _totalCalories.toDouble()];
        _dateLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      });
    }
  }
  
  void _onDateRangeChanged(DateTime date, DateRange range) {
    setState(() {
      _selectedDate = date;
      _selectedRange = range;
    });
    
    // Reload data for the selected date
    _loadMeals();
    _loadWaterIntake();
    
    // Reload weekly data if the week changes
    if (range == DateRange.week) {
      _loadWeeklyCalorieData();
    }
  }
  
  Future<void> _addMeal(Meal meal) async {
    try {
      final success = await _firebaseService.addMeal(meal);
      if (success) {
        await _loadMeals();
        _showSuccessSnackBar('Meal added successfully!');
      } else {
        _showErrorSnackBar('Failed to add meal');
      }
    } catch (e) {
      _showErrorSnackBar('Error adding meal: ${e.toString()}');
    }
  }
  
  Future<void> _deleteMeal(String id) async {
    try {
      final success = await _firebaseService.deleteMeal(id);
      if (success) {
        await _loadMeals();
        _showSuccessSnackBar('Meal deleted');
      } else {
        _showErrorSnackBar('Failed to delete meal');
      }
    } catch (e) {
      _showErrorSnackBar('Error deleting meal: ${e.toString()}');
    }
  }
  
  Future<void> _addWater(WaterIntake waterIntake) async {
    try {
      final success = await _firebaseService.addWaterIntake(waterIntake);
      if (success) {
        await _loadWaterIntake();
        _showSuccessSnackBar('Water added successfully!');
      } else {
        _showErrorSnackBar('Failed to add water intake');
      }
    } catch (e) {
      _showErrorSnackBar('Error adding water intake: ${e.toString()}');
    }
  }
  
  void _showQuickAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) => QuickAddMealDialog(
        onAddMeal: _addMeal,
      ),
    );
  }
  
  void _showAddWaterDialog() {
    showDialog(
      context: context,
      builder: (context) => AddWaterDialog(
        onAddWater: _addWater,
      ),
    );
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Calculate nutrition totals
  int get _totalCalories => _meals.fold(0, (sum, meal) => sum + meal.calories);
  int get _totalProtein => _meals.fold(0, (sum, meal) => sum + meal.protein);
  int get _totalCarbs => _meals.fold(0, (sum, meal) => sum + meal.carbs);
  int get _totalFat => _meals.fold(0, (sum, meal) => sum + meal.fat);
  
  // Generate personalized recommendation
  String get _recommendation {
    if (_totalCalories < _calorieGoal * 0.5) {
      return "You're significantly under your calorie goal. Consider adding more nutrient-dense foods.";
    } else if (_totalProtein < _proteinGoal * 0.7) {
      return "Your protein intake is low. Consider adding more protein-rich foods to your meals.";
    } else if (_waterIntake < _waterGoal * 0.5) {
      return "Your water intake is low. Remember to stay hydrated throughout the day.";
    } else if (_totalCalories > _calorieGoal * 1.1) {
      return "You're over your calorie goal. Consider adjusting portion sizes or adding more physical activity.";
    } else {
      return "You're doing well with your nutrition goals today!";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error message if any
                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: AppBorderRadius.sm,
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(
                      _errorMessage,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $_userName!',
                          style: AppTextStyles.headerLarge,
                        ),
                        Text(
                          _getGreetingMessage(),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Quick Stats
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppBorderRadius.md,
                    boxShadow: [AppShadows.small],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickStat(
                            'Calories',
                            '$_totalCalories',
                            Icons.local_fire_department,
                            AppColors.primary,
                          ),
                          _buildQuickStat(
                            'Protein',
                            '${_totalProtein}g',
                            Icons.fitness_center,
                            AppColors.protein,
                          ),
                          _buildQuickStat(
                            'Water',
                            '${_waterIntake.toStringAsFixed(1)}L',
                            Icons.water_drop,
                            AppColors.water,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _recommendation,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textDark.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Date Selector
                DateSelector(
                  selectedDate: _selectedDate,
                  selectedRange: _selectedRange,
                  onDateRangeChanged: _onDateRangeChanged,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Progress Bars
                Text(
                  'Today\'s Progress',
                  style: AppTextStyles.headerMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppBorderRadius.md,
                    boxShadow: [AppShadows.small],
                  ),
                  child: Column(
                    children: [
                      NutritionProgressBar(
                        label: 'Calories',
                        current: _totalCalories.toDouble(),
                        goal: _calorieGoal.toDouble(),
                        color: AppColors.primary,
                        unit: ' kcal',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      NutritionProgressBar(
                        label: 'Protein',
                        current: _totalProtein.toDouble(),
                        goal: _proteinGoal.toDouble(),
                        color: AppColors.protein,
                        unit: 'g',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      NutritionProgressBar(
                        label: 'Carbs',
                        current: _totalCarbs.toDouble(),
                        goal: _carbsGoal.toDouble(),
                        color: AppColors.carbs,
                        unit: 'g',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      NutritionProgressBar(
                        label: 'Fat',
                        current: _totalFat.toDouble(),
                        goal: _fatGoal.toDouble(),
                        color: AppColors.fat,
                        unit: 'g',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Water Intake Tracker
                WaterIntakeTracker(
                  current: _waterIntake,
                  goal: _waterGoal,
                  onAddWater: _showAddWaterDialog,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Step Counter
                StepCounterWidget(
                  currentSteps: 7500, // Mock data
                  stepGoal: _stepGoal,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Macronutrient Pie Chart
                MacronutrientPieChart(
                  protein: _totalProtein,
                  carbs: _totalCarbs,
                  fat: _totalFat,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Calorie Trend Chart
                CalorieTrendChart(
                  calorieData: _calorieData.isEmpty 
                      ? [1750, 1900, 2100, 1850, 1950, 2000, _totalCalories.toDouble()] 
                      : _calorieData,
                  calorieGoal: _calorieGoal.toDouble(),
                  dateLabels: _dateLabels.isEmpty 
                      ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] 
                      : _dateLabels,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Meals Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Meals',
                      style: AppTextStyles.headerMedium,
                    ),
                    ElevatedButton.icon(
                      onPressed: _showQuickAddMealDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Meal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _meals.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppBorderRadius.md,
                          boxShadow: [AppShadows.small],
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'No meals logged yet',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ElevatedButton(
                                onPressed: _showQuickAddMealDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Add Your First Meal'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: _meals
                            .map(
                              (meal) => MealListItem(
                                meal: meal,
                                onDelete: () => _deleteMeal(meal.id),
                              ),
                            )
                            .toList(),
                      ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickAddMealDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppBorderRadius.sm,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning! Ready for a healthy day?';
    } else if (hour < 17) {
      return 'Good afternoon! How\'s your day going?';
    } else {
      return 'Good evening! Let\'s finish strong today.';
    }
  }
} 