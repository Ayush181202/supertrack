import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal_model.dart';
import '../models/water_intake_model.dart';
import '../models/user_model.dart' as app_user;

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication methods
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password, String name) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document with default goals
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'calorieGoal': 2000,
          'proteinGoal': 120,
          'carbsGoal': 200,
          'fatGoal': 65,
          'waterGoal': 2.5,
          'stepGoal': 10000,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return userCredential.user;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User data methods
  Future<app_user.User?> getUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return app_user.User(
        id: currentUser.uid,
        name: data['name'] ?? '',
        calorieGoal: data['calorieGoal'] ?? 2000,
        proteinGoal: data['proteinGoal'] ?? 120,
        carbsGoal: data['carbsGoal'] ?? 200,
        fatGoal: data['fatGoal'] ?? 65,
        waterGoal: (data['waterGoal'] ?? 2.5).toDouble(),
        stepGoal: data['stepGoal'] ?? 10000,
      );
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<bool> updateUserGoals({
    int? calorieGoal, 
    int? proteinGoal, 
    int? carbsGoal, 
    int? fatGoal, 
    double? waterGoal, 
    int? stepGoal,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final Map<String, dynamic> updates = {};
      if (calorieGoal != null) updates['calorieGoal'] = calorieGoal;
      if (proteinGoal != null) updates['proteinGoal'] = proteinGoal;
      if (carbsGoal != null) updates['carbsGoal'] = carbsGoal;
      if (fatGoal != null) updates['fatGoal'] = fatGoal;
      if (waterGoal != null) updates['waterGoal'] = waterGoal;
      if (stepGoal != null) updates['stepGoal'] = stepGoal;

      await _firestore.collection('users').doc(currentUser.uid).update(updates);
      return true;
    } catch (e) {
      print('Error updating user goals: $e');
      return false;
    }
  }

  // Meal methods
  Future<List<Meal>> getMeals(DateTime date) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      // Start and end of the selected day
      final DateTime startOfDay = DateTime(date.year, date.month, date.day);
      final DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('meals')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Meal(
          id: doc.id,
          name: data['name'] ?? '',
          calories: data['calories'] ?? 0,
          protein: data['protein'] ?? 0,
          carbs: data['carbs'] ?? 0,
          fat: data['fat'] ?? 0,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      print('Error getting meals: $e');
      return [];
    }
  }

  Future<bool> addMeal(Meal meal) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await _firestore.collection('users').doc(currentUser.uid).collection('meals').add({
        'name': meal.name,
        'calories': meal.calories,
        'protein': meal.protein,
        'carbs': meal.carbs,
        'fat': meal.fat,
        'timestamp': meal.timestamp,
      });
      return true;
    } catch (e) {
      print('Error adding meal: $e');
      return false;
    }
  }

  Future<bool> deleteMeal(String mealId) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('meals')
          .doc(mealId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting meal: $e');
      return false;
    }
  }

  // Water intake methods
  Future<double> getTotalWaterIntake(DateTime date) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return 0.0;

      // Start and end of the selected day
      final DateTime startOfDay = DateTime(date.year, date.month, date.day);
      final DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('waterIntake')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] ?? 0.0).toDouble();
      }
      return total;
    } catch (e) {
      print('Error getting water intake: $e');
      return 0.0;
    }
  }

  Future<bool> addWaterIntake(WaterIntake waterIntake) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await _firestore.collection('users').doc(currentUser.uid).collection('waterIntake').add({
        'amount': waterIntake.amount,
        'timestamp': waterIntake.timestamp,
      });
      return true;
    } catch (e) {
      print('Error adding water intake: $e');
      return false;
    }
  }

  // Get weekly calorie data
  Future<Map<String, dynamic>> getWeeklyCalorieData(DateTime date) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return {'data': [], 'labels': []};

      // Calculate start of week (Monday)
      final int weekday = date.weekday;
      final DateTime startOfWeek = date.subtract(Duration(days: weekday - 1));
      
      List<double> calorieData = List.filled(7, 0);
      List<String> dateLabels = [];
      
      // Get data for each day of the week
      for (int i = 0; i < 7; i++) {
        final DateTime currentDay = startOfWeek.add(Duration(days: i));
        final DateTime startOfDay = DateTime(currentDay.year, currentDay.month, currentDay.day);
        final DateTime endOfDay = DateTime(currentDay.year, currentDay.month, currentDay.day, 23, 59, 59);
        
        // Format date label (e.g., "Mon")
        final String dayLabel = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i];
        dateLabels.add(dayLabel);
        
        final QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('meals')
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThanOrEqualTo: endOfDay)
            .get();
        
        double totalCalories = 0;
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalCalories += (data['calories'] ?? 0).toDouble();
        }
        calorieData[i] = totalCalories;
      }
      
      return {
        'data': calorieData,
        'labels': dateLabels,
      };
    } catch (e) {
      print('Error getting weekly calorie data: $e');
      return {'data': [], 'labels': []};
    }
  }
} 