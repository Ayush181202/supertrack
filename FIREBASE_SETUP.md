# Firebase Setup for Supertrack

This document outlines the steps to set up Firebase for your Supertrack nutrition and fitness tracking app.

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click on "Add project"
3. Enter a project name (e.g., "Supertrack")
4. Choose whether to enable Google Analytics (recommended)
5. Accept the terms and click "Create Project"

## Step 2: Register Your Flutter App

### For Android:

1. In the Firebase console, click on the Android icon to add an Android app
2. Enter your Android package name (e.g., `com.yourname.supertrack`)
3. Enter a nickname for your app (optional)
4. Enter your SHA-1 signing certificate (for Google Sign-In, optional)
5. Click "Register app"
6. Download the `google-services.json` file
7. Place the `google-services.json` file in the `android/app` directory of your Flutter project

### For iOS:

1. In the Firebase console, click on the iOS icon to add an iOS app
2. Enter your iOS bundle ID (e.g., `com.yourname.supertrack`)
3. Enter a nickname for your app (optional)
4. Enter your App Store ID (optional)
5. Click "Register app"
6. Download the `GoogleService-Info.plist` file
7. Place the `GoogleService-Info.plist` file in the `ios/Runner` directory of your Flutter project

## Step 3: Configure Firebase in Your Flutter App

### Add Firebase SDK to Android

1. Open your `android/build.gradle` file and add:
```gradle
buildscript {
    dependencies {
        // ... other dependencies
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

2. Open your `android/app/build.gradle` file and add:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Add Firebase SDK to iOS

1. Open your `ios/Podfile` and add:
```ruby
# Add this at the top of your Podfile
platform :ios, '12.0'
```

## Step 4: Set Up Firestore Database

1. In the Firebase console, go to "Firestore Database"
2. Click "Create database"
3. Start in production mode or test mode (you can change this later)
4. Choose a database location close to your target users
5. Wait for the database to be provisioned

## Step 5: Set Up Firestore Security Rules

1. In the Firebase console, go to "Firestore Database" > "Rules"
2. Update the rules to secure your data. Here's a basic example:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Users can only access their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow access to subcollections
      match /{collection}/{docId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Step 6: Set Up Authentication

1. In the Firebase console, go to "Authentication"
2. Click "Get started"
3. Enable "Email/Password" authentication (and any other methods you wish to support)
4. Configure the providers according to your needs

## Step 7: Initialize Firebase in Your App

Ensure your main.dart initializes Firebase before running the app:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

## Step 8: Test Your Firebase Connection

1. Run your app
2. Try creating a user account
3. Check that data is being saved to Firestore correctly

## Data Structure

The app uses the following Firestore data structure:

```
/users/{userId} - User document containing profile information and goals
  - name: string
  - email: string
  - calorieGoal: number
  - proteinGoal: number
  - carbsGoal: number
  - fatGoal: number
  - waterGoal: number
  - stepGoal: number
  - createdAt: timestamp

/users/{userId}/meals/{mealId} - Meal documents
  - name: string
  - calories: number
  - protein: number
  - carbs: number
  - fat: number
  - timestamp: timestamp

/users/{userId}/waterIntake/{waterIntakeId} - Water intake records
  - amount: number
  - timestamp: timestamp
``` 