## Student Information

| Information | Details |
|---|---|
| Student Name | Ni Putu Sapna Maharani |
| Student ID (NIM) | 2415051024 |
| Class | PTI 5 B |
| Project Name | Nusa Penida Travel Buddy |


# Nusa Penida Travel Buddy

**Explore Nusa Penida, Plan Your Journey!**

## 1. Project Overview

Nusa Penida Travel Buddy is a mobile application developed using Flutter to help users explore tourist destinations in Nusa Penida, Bali, and manage their travel itineraries in one application.

The application provides destination information, destination search, favorite destinations, and travel itinerary management. Users can create, view, update, and delete their travel plans through an integrated Supabase database.

This project was developed individually as part of the Midterm Examination (UTS) for the Mobile Programming course. It demonstrates the implementation of Flutter UI, Dart fundamentals, responsive layouts, navigation, state management, layered architecture, REST API integration, and database CRUD operations.

## 2. Student Information

| Information | Details |
|---|---|
| Project Name | Nusa Penida Travel Buddy |
| Student Name | Ni Putu Sapna Maharani |
| Student ID (NIM) | 2415051024 |
| Class | [Fill in your class] |
| Course | Mobile Programming |
| Project Type | Individual Midterm Examination |
| Main Branch | main |
| GitHub Repository | [Nusa Penida Travel Buddy](https://github.com/SapnaMaharani/UTS_2415051024_NiPutuSapnaMaharani) |

## 3. Project Objectives

The objectives of this project are:

1. Develop a functional mobile application using Flutter and Dart.
2. Implement responsive user interfaces for different screen sizes.
3. Apply multi-screen navigation and data passing between screens.
4. Implement state management using Provider and ChangeNotifier.
5. Integrate a REST API and perform JSON parsing using Dart models.
6. Implement database operations using Supabase.
7. Apply a layered application architecture using Models, Services, Repositories, Providers, Screens, and Widgets.
8. Demonstrate Git and GitHub usage through meaningful development commits.

## 4. Application Features

The application consists of eight functional screens.

### 4.1 Home Screen
- Displays the main application dashboard.
- Shows popular tourist destinations.
- Provides travel itinerary summaries.
- Displays travel statistics.
- Provides navigation to other application features.

### 4.2 Explore Destinations Screen
- Displays tourist destinations retrieved from MockAPI.
- Provides destination search functionality.
- Supports Grid and List display modes.
- Uses responsive layouts based on screen width.
- Allows users to mark destinations as favorites.

### 4.3 Destination Detail Screen
- Displays detailed destination information.
- Shows destination images, locations, and descriptions.
- Passes destination data from the list screen.
- Provides an option to add a destination to the itinerary.

### 4.4 Add Itinerary Screen
- Provides a form to create a new travel plan.
- Allows users to select a destination and visit date.
- Provides budget input and optional travel notes.
- Validates user input before saving.
- Stores itinerary data in Supabase.

### 4.5 Edit Itinerary Screen
- Allows users to modify existing travel plans.
- Supports changes to destination name, visit date, budget, status, and notes.
- Validates updated information.
- Saves changes to Supabase.

### 4.6 My Itinerary Screen
- Displays saved travel itineraries.
- Supports Create, Read, Update, and Delete operations.
- Provides search functionality.
- Supports filtering by itinerary status:
  - Planned
  - Ongoing
  - Completed
- Provides confirmation dialogs before deleting itinerary data.

### 4.7 Favorite Screen
- Displays destinations marked as favorites.
- Allows users to manage favorite destinations.
- Uses shared application state managed by Provider.

### 4.8 Profile Screen
- Displays developer profile information.
- Provides an overview of the application.

## 5. Technologies Used

| Technology | Implementation |
|---|---|
| Flutter | Mobile application development |
| Dart | Main programming language |
| Provider | State management |
| ChangeNotifier | State notification |
| HTTP | REST API communication |
| MockAPI | Destination data source |
| Supabase | Backend database |
| PostgreSQL | Database technology used by Supabase |
| Material 3 | User interface components |
| Git | Version control |
| GitHub | Source code repository |

## 6. Application Architecture

The application implements a simple layered architecture to separate user interface components, application state, business logic, and data access.

### 6.1 Project Structure

```text
lib/
├── config/
│   └── supabase_config.dart
│
├── models/
│   ├── destination_model.dart
│   └── itinerary_model.dart
│
├── providers/
│   └── travel_provider.dart
│
├── repositories/
│   └── travel_repository.dart
│
├── screens/
│   ├── add_itinerary_screen.dart
│   ├── destination_detail_screen.dart
│   ├── destination_list_screen.dart
│   ├── edit_itinerary_screen.dart
│   ├── favorite_screen.dart
│   ├── home_screen.dart
│   ├── main_navigation_screen.dart
│   ├── my_itinerary_screen.dart
│   └── profile_screen.dart
│
├── services/
│   ├── api_service.dart
│   └── supabase_service.dart
│
├── widgets/
│   ├── custom_section_title.dart
│   ├── destination_card.dart
│   └── stat_card.dart
│
└── main.dart
```

### 6.2 Architecture Responsibilities

**Models**

Define the application data structures and handle JSON serialization and deserialization.

- Destination Model
- Itinerary Model

**Services**

Handle communication with external data sources.

- ApiService: Retrieves destination data from MockAPI.
- SupabaseService: Handles itinerary database operations.

**Repositories**

Provide an abstraction between application state management and data services.

- TravelRepository: Connects TravelProvider with API and Supabase services.

**Providers**

Manage shared application state using ChangeNotifier.

- TravelProvider: Manages destinations, itineraries, favorites, loading states, and error states.

**Screens**

Provide the application's user interface and handle user interactions.

**Widgets**

Contain reusable UI components used throughout the application.

### 6.3 Data Flow

```text
User Interaction
       |
       v
     Screens
       |
       v
    Provider
       |
       v
   Repository
       |
       v
     Services
       |
       +------------------+
       |                  |
       v                  v
    MockAPI            Supabase
 Destinations          Itinerary
```

The architecture separates UI components from database and API operations. Screens communicate with the Provider, while the Repository and Services handle data access.

## 7. REST API Integration

### 7.1 MockAPI

The application uses MockAPI as the REST API data source for tourist destinations.

**API Endpoint:**

```text
https://6aed61a0fc3b911e6fd6220d.mockapi.io/destinations
```

**Implemented operations:**

| Method | Endpoint | Purpose |
|---|---|---|
| GET | /destinations | Retrieve all destinations |
| GET | /destinations/{id} | Retrieve destination details by ID |

The API response is converted into Dart objects using the Destination Model.

The retrieved data is displayed in the Explore Destinations and Destination Detail screens.

The application also provides loading, error, and empty states when retrieving destination data.

## 8. Backend and Database Integration

### 8.1 Supabase

Supabase is used as the backend database for storing and managing travel itinerary information.

**Database Table:** `my_itinerary`

### 8.2 Database Structure

| Column | Data Type | Description |
|---|---|---|
| id | UUID | Primary key |
| spot_name | TEXT | Destination name |
| visit_date | DATE | Planned visit date |
| budget | NUMERIC(12,2) | Travel budget |
| status | TEXT | Itinerary status |
| notes | TEXT | Additional travel notes |
| created_at | TIMESTAMPTZ | Record creation timestamp |

The database schema must match the actual Supabase table configuration.

### 8.3 CRUD Operations

The application implements four database operations:

| Operation | Description | Implementation |
|---|---|---|
| Create | Add a new itinerary | Add Itinerary Screen |
| Read | Retrieve saved itineraries | My Itinerary Screen |
| Update | Modify existing itinerary data | Edit Itinerary Screen |
| Delete | Remove an itinerary | My Itinerary Screen |

Delete operations include a confirmation dialog before removing data.

## 9. State Management

The application uses the Provider package with ChangeNotifier to manage shared application state.

TravelProvider is responsible for:

- Managing destination data.
- Managing itinerary data.
- Managing favorite destinations.
- Handling loading states.
- Handling application errors.
- Performing itinerary CRUD operations.
- Notifying UI components when application state changes.

This implementation separates application logic from the presentation layer and supports consistent state updates across screens.

## 10. Responsive UI Design

The application uses responsive layout techniques to adapt the interface to different screen sizes.

Responsive implementation includes:

- LayoutBuilder for determining available screen width.
- Compact and wide layout conditions.
- Dynamic GridView column counts.
- Flexible widgets for adaptive content sizing.
- Responsive destination cards.
- Constrained content widths on larger screens.

The application uses a tropical-inspired visual theme with teal accents, clean layouts, and consistent UI components.

## 11. Reusable Widgets

The application implements three reusable custom widgets.

| Widget | Purpose |
|---|---|
| StatCard | Displays travel statistics |
| CustomSectionTitle | Displays reusable section headings |
| DestinationCard | Displays destination information in card format |

These components help maintain UI consistency and reduce repeated code.

## 12. Navigation and User Interaction

The application uses BottomNavigationBar as its primary navigation component.

The main navigation contains five sections:

1. Home
2. Explore
3. Favorite
4. My Trip
5. Profile

Additional interactions include:

- Navigation from destination list to destination detail.
- Passing destination data between screens.
- Adding and editing itinerary data.
- Searching destinations and itineraries.
- Filtering itinerary status.
- Managing favorite destinations.
- Selecting visit dates.
- Validating forms.
- Confirming delete operations.
- Displaying SnackBar feedback.

## 13. Installation and Configuration

### 13.1 Prerequisites

The development environment requires:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android Emulator or a physical Android device
- Internet connection

### 13.2 Clone Repository

```bash
git clone https://github.com/SapnaMaharani/UTS_2415051024_NiPutuSapnaMaharani.git
```

Navigate to the project directory:

```bash
cd UTS_2415051024_NiPutuSapnaMaharani
```

### 13.3 Install Dependencies

```bash
flutter pub get
```

### 13.4 Configure Supabase

Open the following configuration file:

```text
lib/config/supabase_config.dart
```

Configure your Supabase project URL and Publishable Key:

```dart
class SupabaseConfig {
  static const String supabaseUrl =
      'https://YOUR_PROJECT_ID.supabase.co';

  static const String publishableKey =
      'YOUR_SUPABASE_PUBLISHABLE_KEY';
}
```

Replace the placeholder values with your own Supabase project credentials.

**Security considerations:**

- Use only the Publishable Key in the Flutter client application.
- Never expose the Secret Key or Service Role Key.
- Configure appropriate Row Level Security (RLS) policies.
- Do not commit private credentials, tokens, or keystore files to GitHub.

Ensure that the `my_itinerary` table has been created and configured in Supabase.

### 13.5 Run Application

Connect an Android emulator or physical device, then execute:

```bash
flutter run
```

## 14. Testing and Code Analysis

The following commands can be used to check the project.

**Code analysis:**

```bash
flutter analyze
```

**Run Flutter tests:**

```bash
flutter test
```

Application testing should cover:

- Screen navigation.
- REST API data retrieval.
- Loading, error, and empty states.
- Form validation.
- Itinerary Create, Read, Update, and Delete operations.
- Favorite functionality.
- Search and status filtering.
- Responsive layout behavior.

## 15. Application Screenshots

Application screenshots are provided to demonstrate the implemented user interface and application functionality.

The following screenshots should be included:

| No. | Screenshot | Description |
|---|---|---|
| 1 | Home Screen | Main dashboard |
| 2 | Explore Screen | Destination list and search |
| 3 | Destination Detail | Destination information |
| 4 | Add Itinerary | Create itinerary form |
| 5 | Edit Itinerary | Update itinerary form |
| 6 | My Itinerary | Saved itinerary data |
| 7 | Favorite Screen | Favorite destinations |
| 8 | Profile Screen | Developer profile |
| 9 | Responsive Layout | Compact and wide layouts |
| 10 | API Data | Destination data retrieved from MockAPI |
| 11 | Database Data | Itinerary records stored in Supabase |

Place the screenshots in the repository under a folder named `screenshots/` and update the references below.

```text
screenshots/
├── home.png
├── explore.png
├── destination_detail.png
├── add_itinerary.png
├── edit_itinerary.png
├── my_itinerary.png
├── favorite.png
├── profile.png
├── responsive_layout.png
├── api_data.png
└── database_data.png
```

## 16. Git and GitHub Development

Git is used for version control throughout the development process.

The project follows milestone-based commits to document meaningful development progress.

The main development branch is:

```text
main
```

Repository:

https://github.com/SapnaMaharani/UTS_2415051024_NiPutuSapnaMaharani

The project follows the UTS requirement of at least 16 meaningful commits, with changes pushed to GitHub at development milestones.

The final repository should contain the source code, README documentation, and required project evidence.

## 17. APK Build

To generate a release APK, execute:

```bash
flutter build apk --release
```

The generated APK is located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

The APK should be prepared for submission using the required filename format:

```text
UTS_2415051024_NiPutuSapnaMaharani.apk
```

## 18. Project Deliverables

The project submission includes:

1. GitHub repository URL.
2. Flutter application source code.
3. Release APK.
4. PDF project documentation.
5. Application screenshots.
6. Git commit history.
7. Complete README documentation.
8. Application demonstration and architecture explanation.

## 19. Conclusion

Nusa Penida Travel Buddy demonstrates the development of a Flutter-based mobile application that integrates responsive UI design, multi-screen navigation, state management, REST API communication, and backend database operations.

Through this project, the implementation of Dart models, Provider and ChangeNotifier, layered architecture, reusable widgets, and Supabase CRUD operations provides practical experience in mobile application development.

---

## Developer

**Ni Putu Sapna Maharani**  
Student ID: 2415051024  
Course: Mobile Programming  
Project: Individual Midterm Examination (UTS)

**GitHub Repository:**  
https://github.com/SapnaMaharani/UTS_2415051024_NiPutuSapnaMaharani

---

## Application Screenshots

### 1. Home
![Home Screen](screenshots/home.png)

### 2. Explore - Destination List
![Explore Screen](screenshots/explore.png)

### 3. Destination Detail
![Destination Detail](screenshots/destination_detail.png)

### 4. Add Itinerary
![Add Itinerary](screenshots/add_itinerary.png)

### 5. Edit Itinerary
![Edit Itinerary](screenshots/edit_itinerary.png)

### 6. My Itinerary
![My Itinerary](screenshots/my_trip.png)

### 7. Favorite
![Favorite Screen](screenshots/Favorite.png)

### 8. Profile
![Profile Screen](screenshots/profile.png)

### 9. Responsive Layout
![Responsive Layout](screenshots/responsive.png)

---

**Nusa Penida Travel Buddy**  
*Explore Nusa Penida, Plan Your Journey!*