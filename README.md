# FindEase - Intelligent Property Booking Platform



## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Technical Architecture](#technical-architecture)
  - [MVVM Architecture](#mvvm-architecture)
  - [Project Structure](#project-structure)
  - [Data Models](#data-models)
  - [Services](#services)
  - [ViewModels](#viewmodels)
  - [Views](#views)
  - [Widgets](#widgets)
- [Recommendation System](#recommendation-system)
  - [Interaction Tracking](#interaction-tracking)
  - [Analytics Processing](#analytics-processing)
  - [User Segmentation](#user-segmentation)
  - [Recommendation Algorithms](#recommendation-algorithms)
  - [Scoring System](#scoring-system)
- [Firebase Implementation](#firebase-implementation)
  - [Authentication](#authentication)
  - [Firestore Collections](#firestore-collections)
  - [Security Rules](#security-rules)
  - [Cloud Functions](#cloud-functions)
- [World Cup 2030 Module (MatchApp)](#world-cup-2030-module-matchapp)
  - [Features](#matchapp-features)
  - [Implementation](#matchapp-implementation)
- [Setup & Installation](#setup--installation)
  - [Prerequisites](#prerequisites)
  - [Environment Setup](#environment-setup)
  - [Firebase Configuration](#firebase-configuration)
  - [Running the Application](#running-the-application)
- [Development Guidelines](#development-guidelines)
  - [Code Conventions](#code-conventions)
  - [Testing](#testing)
  - [Performance Optimization](#performance-optimization)
- [API Documentation](#api-documentation)
- [Deployment](#deployment)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Contact & Support](#contact--support)

## Project Overview

FindEase is a cutting-edge mobile application developed with Flutter and Firebase, designed to revolutionize the property booking experience through intelligent recommendations. The platform analyzes user behavior patterns to suggest properties that align with user preferences, creating a personalized booking experience.

The application features a dedicated MatchApp module specifically tailored for the FIFA World Cup 2030, which will be hosted across Morocco, Spain, and Portugal. This module offers specialized accommodations near stadiums and event venues, optimized for tournament attendees.

### Target Audience

- Travelers seeking accommodations with personalized recommendations
- Property owners looking to list their rentals
- World Cup 2030 attendees requiring strategic accommodation options
- Users with specific property requirements that benefit from intelligent matching

## Features

### Core Features

- **Intelligent Recommendation Engine**: Analyzes user interactions to suggest relevant properties
- **Advanced Search & Filtering**: Multi-criteria property search with intuitive filters
- **User Segmentation**: Categorizes users to provide tailored experiences
- **Interaction Tracking**: Logs views, clicks, favorites, and bookings to improve recommendations
- **Property Correlation Analysis**: Identifies relationships between frequently co-viewed properties
- **Personalized Dashboard**: User-specific home screen with relevant recommendations

### Property Management

- **Detailed Property Listings**: Comprehensive property information with multiple images
- **Amenity Highlighting**: Clear display of available features and amenities
- **Location Integration**: Maps and proximity information for points of interest
- **Availability Calendar**: Real-time booking availability
- **Rating & Review System**: User feedback visualization for properties

### User Experience

- **Seamless Authentication**: Easy sign-up and login process
- **User Profiles**: Customizable profiles with preference settings
- **Favorites Collection**: Saved properties for future reference
- **Booking Management**: Complete booking lifecycle handling
- **Notification System**: Alerts for relevant properties and booking updates

### World Cup 2030 Specific

- **Stadium Proximity Filter**: Find accommodations near specific World Cup venues
- **Host Country Selection**: Filter by Morocco, Spain, or Portugal
- **Match Schedule Integration**: Align bookings with game dates
- **Fan Zone Information**: Details about nearby fan gathering areas
- **Special World Cup Offers**: Highlighted deals for tournament attendees

## Technical Architecture

### MVVM Architecture

FindEase implements the Model-View-ViewModel (MVVM) architectural pattern to ensure separation of concerns and maintainability:

- **Model**: Represents the data structure and business logic
- **View**: User interface components
- **ViewModel**: Intermediary between Model and View, handling UI logic

This architecture facilitates:
- Clear separation of business logic from UI
- Enhanced testability
- Code reusability
- Maintainable codebase

### Project Structure

```
findease/
├── android/                # Android-specific code
├── ios/                    # iOS-specific code
├── lib/
│   ├── main.dart           # Application entry point
│   ├── model/              # Data models
│   │   ├── property.dart
│   │   ├── property_correlation.dart
│   │   ├── user_interaction.dart
│   │   ├── user_preferences.dart
│   │   └── user_segment.dart
│   ├── services/           # Business logic and API services
│   │   ├── analytics_service.dart
│   │   ├── auth_service.dart
│   │   ├── recommendation_config.dart
│   │   ├── recommendation_service.dart
│   │   └── user_interaction_service.dart
│   ├── view/               # UI screens
│   │   ├── auth_screen.dart
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── property_details_screen.dart
│   │   ├── recommendations_screen.dart
│   │   ├── search_screen.dart
│   │   └── ...
│   ├── viewmodel/          # ViewModels connecting views to models
│   │   ├── auth_viewmodel.dart
│   │   ├── property_viewmodel.dart
│   │   └── recommendation_viewmodel.dart
│   └── widgets/            # Reusable UI components
│       ├── filter_dialog.dart
│       ├── property_card.dart
│       ├── recommendations_section.dart
│       ├── world_cup_recommendations.dart
│       └── ...
├── assets/                 # Images, fonts, and other static resources
│   ├── fonts/
│   ├── images/
│   └── world_cup_data/
├── test/                   # Unit and widget tests
└── pubspec.yaml            # Project dependencies and configuration
```

### Data Models

#### Property

```dart
class Property {
  final String id;
  final String title;
  final String type;
  final double price;
  final Map<String, dynamic> location;
  final String description;
  final List<String> images;
  final List<String> amenities;
  final int bedrooms;
  final int bathrooms;
  final int capacity;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic>? worldCupInfo;

  // Constructor, toMap, fromMap methods...
}
```

#### UserInteraction

```dart
class UserInteraction {
  final String id;
  final String userId;
  final String propertyId;
  final String interactionType; // 'view', 'click', 'favorite', 'booking'
  final DateTime timestamp;
  final int duration;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> contextInfo;

  // Constructor, toMap, fromMap methods...
}
```

#### UserPreferences

```dart
class UserPreferences {
  final String userId;
  final List<String> preferredPropertyTypes;
  final List<String> preferredLocations;
  final Map<String, double> budgetRange;
  final List<String> requiredAmenities;
  final String travelPurpose;
  final int typicalGroupSize;
  final Map<String, int> stayDuration;
  final bool interestedInWorldCup;

  // Constructor, toMap, fromMap methods...
}
```

#### UserSegment

```dart
class UserSegment {
  final String id;
  final Map<String, List<String>> segments;
  final DateTime createdAt;
  final int totalUsers;

  // Constructor, toMap, fromMap methods...
}
```

### Services

#### AnalyticsService

The core engine that processes user interactions and generates insights:

- `analyzeUserInteractions()`: Processes recent user interactions
- `calculatePropertyStats()`: Computes statistics for each property
- `updatePropertyPopularityScores()`: Updates popularity metrics
- `findPropertyCorrelations()`: Identifies relationships between properties
- `segmentUsers()`: Categorizes users based on behavior patterns
- `runAllAnalytics()`: Executes the complete analytics pipeline

#### UserInteractionService

Captures and stores all user interactions:

- `trackInteraction()`: Records user actions (view, click, favorite, booking)
- `updateViewDuration()`: Tracks time spent viewing a property
- `getUserInteractionHistory()`: Retrieves a user's past interactions
- `addToFavorites()` / `removeFromFavorites()`: Manages favorites collection
- `isFavorite()`: Checks if a property is in user's favorites

#### RecommendationService

Generates property recommendations based on analytics:

- `getRecommendationsForUser()`: Creates personalized recommendations
- `getSimilarProperties()`: Finds properties related to a given property
- `getPopularProperties()`: Returns trending properties
- `getWorldCupRecommendations()`: Generates World Cup specific suggestions

### ViewModels

#### RecommendationViewModel

Manages the recommendation state and UI logic:

- `loadPersonalizedRecommendations()`: Fetches tailored recommendations
- `loadSimilarProperties()`: Gets properties similar to current selection
- `loadWorldCupRecommendations()`: Retrieves World Cup related properties
- `loadPopularProperties()`: Gets trending properties
- `trackPropertyClick()` / `trackPropertyView()`: Records user interactions
- `applyFilters()`: Updates recommendations based on selected filters

#### PropertyViewModel

Handles property-related operations:

- `loadPropertyDetails()`: Fetches complete property information
- `getPropertiesByType()`: Filters properties by category
- `searchProperties()`: Searches based on multiple criteria
- `checkAvailability()`: Verifies booking availability
- `bookProperty()`: Processes reservation requests

#### AuthViewModel

Manages authentication state:

- `signUp()`: Registers new users
- `signIn()`: Authenticates existing users
- `signOut()`: Handles user logout
- `resetPassword()`: Processes password recovery

### Views

Key screens in the application:

- **HomeScreen**: Entry point with personalized recommendations
- **PropertyDetailsScreen**: Comprehensive property information
- **RecommendationsScreen**: Dedicated recommendations view
- **SearchScreen**: Advanced property search interface
- **ProfileScreen**: User profile and preferences management
- **AuthScreen**: Authentication entry point

### Widgets

Reusable UI components:

- **PropertyCard**: Displays property preview information
- **RecommendationsSection**: Shows a category of recommendations
- **WorldCupRecommendations**: Specialized World Cup property display
- **FilterDialog**: Advanced search filters interface

## Recommendation System

The recommendation system is the core intelligence of FindEase, providing personalized property suggestions through several sophisticated mechanisms.

### Interaction Tracking

Every user action is captured with contextual information:

- **View**: Records when a user views a property detail page
- **Click**: Logs user clicks on property cards or links
- **Favorite**: Tracks properties added to favorites
- **Booking**: Records completed booking transactions

Each interaction includes:
- Timestamp
- Duration (for views)
- Device information
- Contextual data (source, search terms, applied filters)

### Analytics Processing

The system periodically processes accumulated data:

1. **Data Collection**: Gathers interactions from the past 30 days
2. **Statistical Analysis**: Calculates metrics for each property
3. **Popularity Scoring**: Computes weighted engagement scores
4. **Correlation Discovery**: Identifies properties frequently viewed together
5. **User Behavior Analysis**: Determines patterns for segmentation

### User Segmentation

Users are categorized into behavioral segments:

- **highlyActive**: Users with more than 20 interactions
- **browsers**: Users with many views but few/no bookings
- **collectors**: Users who frequently add to favorites
- **quickBookers**: Users with high view-to-booking conversion rate
- **inactive**: Users with no recent activity
- **niche**: Users who focus on few properties
- **explorers**: Users who browse many different properties
- **worldCupFans**: Users interested in World Cup accommodations

### Recommendation Algorithms

Multiple algorithms work in concert to generate different types of recommendations:

#### 1. Personalized Recommendations

Combines user history, preferences, and segment information to suggest properties with maximum relevance.

```dart
Future<List<Property>> getPersonalizedRecommendations(String userId, {int limit = 10}) async {
  // Get user's interaction history
  final interactions = await getUserInteractions(userId);
  
  // Get user's explicit preferences
  final preferences = await getUserPreferences(userId);
  
  // Get user's segment
  final segment = await getUserSegment(userId);
  
  // Get potential properties
  final properties = await getFilteredProperties(preferences);
  
  // Calculate personalized scores
  final scoredProperties = calculatePersonalizedScores(
    properties, 
    interactions, 
    preferences, 
    segment
  );
  
  // Sort by score and return top results
  scoredProperties.sort((a, b) => b.score.compareTo(a.score));
  return scoredProperties.take(limit).map((sp) => sp.property).toList();
}
```

#### 2. Similar Properties

Provides recommendations based on property attributes and usage correlations.

```dart
Future<List<Property>> getSimilarProperties(String propertyId, {int limit = 5}) async {
  // Get property correlations
  final correlatedIds = await getCorrelatedPropertyIds(propertyId);
  
  // Get property details
  final property = await getPropertyDetails(propertyId);
  
  // Find properties with similar attributes
  final similarByAttributes = await getSimilarByAttributes(property);
  
  // Combine and rank results
  final combinedResults = mergeAndRankSimilarProperties(
    correlatedIds, 
    similarByAttributes
  );
  
  return combinedResults.take(limit).toList();
}
```

#### 3. World Cup Recommendations

Specializes in finding accommodations suitable for World Cup attendees.

```dart
Future<List<Property>> getWorldCupRecommendations(
  String userId, 
  {String? hostCountry, String? stadiumNearby, DateTime? matchDate}
) async {
  // Get properties with World Cup information
  Query query = FirebaseFirestore.instance.collection('Properties')
    .where('worldCupInfo.worldCupSpecial', isEqualTo: true);
  
  // Apply additional filters
  if (hostCountry != null) {
    query = query.where('location.country', isEqualTo: hostCountry);
  }
  
  if (stadiumNearby != null) {
    query = query.where('worldCupInfo.nearbyStadium', isEqualTo: stadiumNearby);
  }
  
  // Process results with scoring based on stadium proximity and availability
  final properties = await query.get().then((snapshot) => 
    snapshot.docs.map((doc) => Property.fromMap(doc.data(), doc.id)).toList()
  );
  
  // Apply additional scoring and ranking
  return rankWorldCupProperties(properties, userId, matchDate);
}
```

### Scoring System

The recommendation system uses a sophisticated weighted scoring mechanism:

#### Interaction Weights

```dart
const Map<String, double> INTERACTION_WEIGHTS = {
  'view': 1.0,
  'click': 2.0,
  'favorite': 5.0,
  'booking': 10.0
};
```

#### Score Calculation

Properties are scored using a weighted formula that considers:

1. **User Interaction History**: Weighted sum of past interactions
2. **Preference Match**: Degree of alignment with explicit preferences
3. **Segment Adjustment**: Modifier based on user segment
4. **Popularity Factor**: General popularity among similar users
5. **Attribute Relevance**: Matching of specific property attributes

The final score is normalized and properties are ranked accordingly.

## Firebase Implementation

FindEase leverages Firebase services for backend functionality, with a carefully designed database structure to support the recommendation system.

### Authentication

Firebase Authentication manages user accounts with multiple sign-in methods:

- Email/Password authentication
- Google Sign-In integration
- Phone number verification (optional)

### Firestore Collections

#### Users Collection

Stores user profiles and preferences:

```json
{
  "userId": "B5QCtJeongM0Z4AztN6hIB5zwk73",
  "firstName": "Amina",
  "lastName": "Megzari",
  "email": "aminamegzari11@gmail.com",
  "bio": "un appartemment",
  "city": "rabat",
  "country": "maroc",
  "createdAt": "2025-04-14T06:15:49Z",
  "favorites": ["property1Id", "property2Id"],
  "userSegment": "explorer"
}
```

#### Properties Collection

Contains detailed property information:

```json
{
  "propertyId": "MtJFtdfAL4gWuf0ZHAM1",
  "title": "Magnifique villa traditionnelle",
  "type": "Villa",
  "price": 164,
  "location": {
    "address": "Tanger",
    "city": "Tanger",
    "country": "Maroc",
    "coordinates": {
      "latitude": 35.7595,
      "longitude": -5.8340
    }
  },
  "description": "Magnifique villa traditionnelle tenue par un particulier exerçant l'activité d'hôte. Parfaite pour découvrir la culture locale.",
  "amenities": ["wifi", "cuisine", "parking"],
  "interest": "Culture",
  "endDate": "2025-05-07T12:00:00Z",
  "popularityScore": 8.7,
  "interactionStats": {
    "viewCount": 145,
    "clickCount": 67,
    "favoriteCount": 23,
    "bookingCount": 8
  },
  "worldCupInfo": {
    "worldCupSpecial": true,
    "nearbyStadium": "Stade Ibn Batouta",
    "stadiumDistanceKm": 3.2
  }
}
```

#### UserInteractions Collection

Records all user interactions:

```json
{
  "interactionId": "interaction123",
  "userId": "B5QCtJeongM0Z4AztN6hIB5zwk73",
  "propertyId": "MtJFtdfAL4gWuf0ZHAM1",
  "interactionType": "view",
  "timestamp": "2025-04-14T15:30:22Z",
  "duration": 78,
  "deviceInfo": {
    "type": "mobile",
    "os": "android",
    "model": "SM-G998B"
  },
  "contextInfo": {
    "source": "recommendations",
    "previousScreen": "home"
  }
}
```

#### UserPreferences Collection

Stores explicit user preferences:

```json
{
  "userId": "B5QCtJeongM0Z4AztN6hIB5zwk73",
  "preferredPropertyTypes": ["Villa", "Appartement"],
  "preferredLocations": ["rabat", "marrakech"],
  "budgetRange": {"min": 50, "max": 200},
  "requiredAmenities": ["wifi", "parking"],
  "travelPurpose": "Tourism",
  "typicalGroupSize": 2,
  "stayDuration": {"min": 3, "max": 7},
  "interestedInWorldCup": true
}
```

#### PropertyCorrelations Collection

Records relationships between properties:

```json
{
  "correlationId": "prop1-prop2",
  "propertyA": "MtJFtdfAL4gWuf0ZHAM1",
  "propertyB": "KLnr7HgTs9pQw3ZxYjM5",
  "cooccurrenceCount": 8,
  "lastUpdated": "2025-04-14T12:30:15Z"
}
```

#### UserSegments Collection

Stores segmentation results:

```json
{
  "segmentId": "segment123",
  "segments": {
    "highlyActive": ["user1Id", "user2Id"],
    "browsers": ["user3Id", "user4Id"],
    "collectors": ["user5Id"],
    "quickBookers": ["user6Id", "user7Id"],
    "inactive": ["user8Id"],
    "niche": ["user9Id"],
    "explorers": ["B5QCtJeongM0Z4AztN6hIB5zwk73", "user10Id"],
    "worldCupFans": ["B5QCtJeongM0Z4AztN6hIB5zwk73", "user11Id"]
  },
  "createdAt": "2025-04-14T03:15:00Z",
  "totalUsers": 11
}
```

#### AppConfig Collection

Contains system configuration:

```json
{
  "recommendationSystem": {
    "initialized": true,
    "lastUpdated": "2025-04-14T16:50:54Z",
    "version": "1.0.0"
  }
}
```

### Security Rules

Firestore security rules protect data while allowing the recommendation system to function:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /Users/{userId} {
      allow read: if true; // Public profiles
      allow write, update: if request.auth.uid == userId; // Self-modification only
    }
    
    // Properties collection
    match /Properties/{propertyId} {
      allow read: if true; // Public read
      allow write, update: if false; // Admin only
    }
    
    // UserInteractions collection
    match /UserInteractions/{interactionId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow create: if request.auth != null; // Any authenticated user
      allow update, delete: if false; // No modifications
    }
    
    // Other collections with appropriate rules...
  }
}
```

### Cloud Functions

Firebase Cloud Functions perform scheduled analytics tasks:

- Daily processing of user interactions
- User segmentation updates
- Property correlation calculation
- Popularity score updates

## World Cup 2030 Module (MatchApp)

### MatchApp Features

The World Cup 2030 extension provides specialized functionality:

- **Host Country Selection**: Filter accommodations by Morocco, Spain, or Portugal
- **Stadium Proximity Search**: Find properties near specific venues
- **Match Schedule Integration**: Align stay dates with specific matches
- **Fan Zone Information**: Details about nearby fan gathering spots
- **Special Offers**: Highlighted deals for tournament attendees
- **Transportation Options**: Information about stadium transport

### MatchApp Implementation

The module is integrated through:

- **WorldCupRecommendations Widget**: Specialized UI component
- **World Cup Data in RecommendationConfig**: Static data about venues
- **worldCupInfo Extension in Property Model**: Property-specific World Cup data
- **interestedInWorldCup Flag in UserPreferences**: User interest indicator

```dart
// World Cup configuration
static const Map<String, dynamic> WORLD_CUP_INFO = {
  'hostCountries': ['Maroc', 'Espagne', 'Portugal'],
  'mainStadiums': {
    'Maroc': ['Stade Mohammed V', 'Grand Stade de Casablanca', 'Stade de Rabat'],
    'Espagne': ['Santiago Bernabéu', 'Camp Nou', 'Metropolitano'],
    'Portugal': ['Estádio da Luz', 'Estádio do Dragão', 'Estádio José Alvalade']
  },
};
```

## Setup & Installation

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK 
- Firebase account
- Android Studio / Visual Studio Code
- Git

### Environment Setup

1. Clone the repository
   ```bash
   git clone https://github.com/your-username/findease.git
   cd findease
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

### Firebase Configuration

1. Create a Firebase project in the Firebase Console

2. Enable required services:
   - Authentication
   - Firestore Database
   - Storage
   - Cloud Functions (optional)

3. Add your app to Firebase:
   - Android: Generate and download `google-services.json`
   - iOS: Generate and download `GoogleService-Info.plist`

4. Place configuration files in the appropriate directories:
   - Android: `android/app/`
   - iOS: `ios/Runner/`

5. Initialize Firestore with the required collections:
   - Users
   - Properties
   - UserInteractions
   - UserPreferences
   - PropertyCorrelations
   - UserSegments
   - AppConfig

6. Configure Firestore security rules

### Running the Application

1. Ensure an emulator or device is connected
   ```bash
   flutter devices
   ```

2. Run the application
   ```bash
   flutter run
   ```

3. For production build
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

## Development Guidelines

### Code Conventions

- Follow the Dart style guide
- Use meaningful variable and method names
- Document classes and complex methods
- Keep files focused on a single responsibility
- Use Provider pattern for state management

### Testing

- Write unit tests for core business logic
- Create widget tests for UI components
- Implement integration tests for key user flows
- Use Firebase Emulator Suite for backend testing

### Performance Optimization

- Use pagination for large data sets
- Implement caching for frequently accessed data
- Optimize image loading and rendering
- Monitor Firebase usage to stay within limits
- Batch operations for multiple Firestore updates

## API Documentation

### Firebase Authentication API

```dart
// Sign up with email and password
Future<User?> signUpWithEmail(String email, String password, String firstName, String lastName);

// Sign in with email and password
Future<User?> signInWithEmail(String email, String password);

// Sign out
Future<void> signOut();
```

### Property API

```dart
// Get property details
Future<Property?> getPropertyDetails(String propertyId);

// Search properties
Future<List<Property>> searchProperties({
  String? query,
  String? location,
  String? type,
  double? minPrice,
  double? maxPrice,
  int? minBedrooms,
  List<String>? amenities,
});

// Check availability
Future<bool> checkAvailability(String propertyId, DateTime startDate, DateTime endDate);
```

### Recommendation API

```dart
// Get personalized recommendations
Future<List<Property>> getRecommendationsForUser(String userId, {int limit = 10});

// Get similar properties
Future<List<Property>> getSimilarProperties(String propertyId, {int limit = 5});

// Get World Cup recommendations
Future<List<Property>> getWorldCupRecommendations(
  String userId,
  {String? hostCountry, String? stadiumNearby, DateTime? matchDate}
);
```

## Deployment

### Android Deployment

1. Configure app signing
   ```
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```

2. Create `key.properties` file in android/ directory

3. Build the release APK
   ```bash
   flutter build apk --release
   ```

4. Upload to Google Play Console

### iOS Deployment

1. Set up App Store Connect

2. Configure signing certificates and provisioning profiles

3. Build the release IPA
   ```bash
   flutter build ios --release
   ```

4. Upload using Xcode or Transporter

## Roadmap

### Short-term (3 months)

- Enhanced property search filters
- User review system implementation
- Performance optimizations for large datasets
- Additional payment gateway integrations

### Medium-term (6 months)

- AI-powered image analysis for property categorization
- Virtual property tours integration
- Chat functionality for owner-renter communication
- Multi-language support expansion

### Long-term (1 year+)

- Blockchain integration for secure booking contracts
- AR visualization for property furnishing
- Expanded World Cup 2030 features
- Cross-platform desktop application










