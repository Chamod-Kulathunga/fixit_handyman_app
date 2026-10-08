# FixIt Handyman App

A modern Flutter-based handyman service booking application developed as a practical assignment.

The application allows users to discover handyman service providers, search and filter providers, view detailed provider information, create service bookings, manage existing bookings, and track booking status through a clean and responsive user interface.

---

## Overview

**FixIt Handyman App** is designed to simplify the process of finding and booking reliable handyman services.

Users can:

* Browse available handyman service providers
* Search providers
* Filter providers by category
* Filter only available providers
* Sort providers by rating, price, experience, or reviews
* Load providers using pagination
* View detailed provider profiles
* Create a service booking
* Select a preferred booking date and time slot
* Enter job details and customer information
* See the estimated booking cost in real time
* Apply Saturday surcharge automatically
* Prevent duplicate active bookings
* Store bookings locally
* View upcoming and historical bookings
* Cancel eligible bookings
* Track booking status
* Switch between light and dark themes
* Handle loading, error, and empty states gracefully

---

## Features

### Provider Discovery

The home screen provides a convenient way to discover handyman service providers.

Features include:

* Provider listing
* Provider cards
* Provider category
* Rating and review count
* Hourly rate
* Experience
* Availability status
* Search
* Category filtering
* Availability filtering
* Sorting
* Pagination / load more
* Loading states
* Error states
* Empty states

### Search

Provider search includes a debounced search experience to avoid unnecessary filtering operations while the user is typing.

* Debounced search
* Case-insensitive provider search
* Search result empty state
* Search combined with filtering and sorting

### Category Filter

Users can filter providers based on their service category using category chips.

This makes it easier to find the appropriate handyman for a particular job.

### Availability Filter

Users can enable the availability filter to display only providers who are currently available for bookings.

### Sorting

Providers can be sorted using different criteria:

* Rating
* Price
* Experience
* Number of reviews

Both ascending and descending sorting options are supported.

### Pagination

Provider data is loaded page-by-page rather than loading the entire dataset at once.

The repository layer simulates paginated data and supports:

* Page-based loading
* Load more
* Loading indicators
* End-of-list handling

---

# Provider Details

Selecting a provider opens a detailed provider profile.

The provider details screen displays:

* Provider name
* Profile information
* Service category
* Rating
* Review count
* Experience
* Completed jobs
* Hourly rate
* Location
* Availability
* Description
* Skills
* Provider statistics

The screen also provides access to the booking flow through the **Book Now** action when the provider is available.

---

# Booking Flow

The booking flow follows:


Home
  ↓
Provider Details
  ↓
Book Now
  ↓
Booking Form
  ↓
Booking Confirmation
  ↓
My Bookings


---

## Booking Form

The booking form collects the required information from the customer.

### Customer Information

* Full name
* Phone number
* Address

### Booking Information

* Booking date
* Time slot
* Estimated working hours
* Job description

### Available Time Slots

The application provides predefined booking time slots:

* `09:00 – 11:00`
* `11:00 – 13:00`
* `14:00 – 16:00`
* `16:00 – 18:00`

### Estimated Hours

Users can select estimated working hours from:


1 – 8 hours


### Job Description

The job description field supports:

* Minimum validation
* Maximum 300 characters
* Live character counter

---

# Form Validation

The booking form includes client-side validation.

### Full Name


Minimum: 2 characters
Maximum: 60 characters


### Phone Number


9 – 15 digits


### Address


Minimum: 10 characters
Maximum: 300 characters


### Job Description


Minimum: 10 characters
Maximum: 300 characters


Validation prevents incomplete or invalid booking information from being submitted.

---

# Booking Cost Calculation

The booking cost is calculated dynamically based on the selected provider and booking details.

### Base Calculation


Labour Cost = Hourly Rate × Estimated Hours


A fixed visiting charge is also included:


Visiting Charge = LKR 500


### Saturday Surcharge

Bookings made on Saturday receive a:


15% surcharge


The booking form updates the estimated cost dynamically whenever relevant booking values change.

### Example


Hourly Rate × Estimated Hours
              +
        LKR 500 Visiting Charge
              +
     15% Saturday Surcharge


The user can therefore see the estimated booking cost before submitting the booking.

---

# Booking ID

Each booking receives a unique booking identifier using the following format:


FX-YYYYMMDD-XXXX


Example:


FX-20261008-4821


This provides each booking with an easily identifiable reference.

---

# Duplicate Booking Prevention

The application prevents duplicate active bookings for the same provider and booking schedule.

Before creating a new booking, the local repository checks whether an active booking already exists for the same:

* Provider
* Date
* Time slot

Duplicate checking applies to active booking statuses such as:

* Pending
* Confirmed
* In Progress

This helps prevent accidental duplicate reservations.

---

#  Local Booking Persistence

Bookings are persisted locally using `SharedPreferences`.

The application includes a repository abstraction for booking data.

### Booking Repository Responsibilities

* Get bookings
* Create booking
* Update booking
* Persist booking data locally
* Retrieve saved bookings
* Check duplicate active bookings

Bookings therefore remain available after restarting the application.

---

#  My Bookings

The **My Bookings** screen allows users to manage their existing bookings.

The screen is divided into:

### Upcoming

Displays active/upcoming bookings.

### History

Displays completed, cancelled, and rejected bookings.

Each booking card provides relevant information such as:

* Booking ID
* Provider
* Booking date
* Time
* Status
* Estimated hours
* Booking cost
* Service details

---

#  Booking Status Management

The application supports the following booking statuses:


Pending
Confirmed
In Progress
Completed
Cancelled
Rejected


Booking status transitions are handled through dedicated business logic instead of placing status rules directly inside UI widgets.

This keeps the application easier to maintain and test.

---

#  Booking Cancellation

Users can cancel eligible bookings from the My Bookings screen.

The cancellation flow includes:

* Confirmation dialog
* Cancellation processing state
* Prevention of accidental double taps
* Provider state update
* UI refresh after cancellation

The application also performs mounted checks before updating UI state after asynchronous operations.

---

#  Refresh

The My Bookings screen supports refreshing booking information.

The screen correctly handles:

* Loading
* Refreshing
* Successful data loading
* Empty results
* Errors

---

#  Dark Mode

The application includes a dark theme in addition to the light theme.

The UI has been updated across the application to maintain consistent styling in both modes.

Dark mode applies to:

* Home screen
* Provider cards
* Provider details
* Booking form
* Booking confirmation
* My Bookings
* Booking cards
* Dialogs
* Buttons
* Input fields
* App bars
* General application surfaces

The theme is implemented centrally to avoid maintaining independent styling throughout individual widgets.

---

#  Architecture

The project follows a layered architecture to separate UI, state management, data access, models, and business rules.

A simplified structure is:


lib/
│
├── core/
│   ├── constants/
│   ├── enums/
│   ├── theme/
│   └── utils/
│
├── data/
│   ├── models/
│   └── repositories/
│
├── domain/
│   └── business_logic/
│
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
│
└── main.dart


---

#  State Management

The application uses **Provider** for state management.

Providers are responsible for managing application state and notifying the UI when data changes.

Examples include:

* Provider listing state
* Search/filter state
* Booking state
* Booking loading state
* Booking error state
* Booking updates

This keeps business/state logic separate from UI widgets.

---

#  Repository Pattern

Repository abstractions are used to separate data access from the presentation layer.

For example:


Repository Interface
        ↓
Concrete Repository
        ↓
Data Source


For bookings:


BookingRepository
        ↓
LocalBookingRepository
        ↓
SharedPreferences


This approach makes it easier to replace the local implementation with a remote API or another data source in the future.

---

#  Business Logic

Booking status rules are separated into dedicated business logic.

The application uses:


BookingStatusLogic


to handle status-related operations and transitions.

This avoids placing complex business rules directly inside screens.

---

#  Data Models

The application uses dedicated model classes to represent application data.

Examples include:


Provider Model
Booking Model
Booking Status


This provides a structured representation of data throughout the application.

---

#  Error & State Handling

The application provides user-friendly UI states for different application conditions.

### Loading State

Displayed while data is being loaded.

### Error State

Displayed when a data operation fails and provides an appropriate recovery path.

### Empty State

Displayed when there are no matching providers or bookings.

### Form Error State

Validation messages are displayed when booking information is incomplete or invalid.

### Async Safety

Asynchronous UI operations include mounted checks to prevent updating disposed widgets.

---

#  Mock Data / Repository

The provider browsing functionality uses repository-based mock data for the practical assignment.

The repository simulates realistic data access behavior including:

* Pagination
* Network-like delay
* Potential request failures

The provider dataset is loaded in pages, with approximately 10 providers per page.

This allows the application to demonstrate realistic loading, pagination, error handling, and retry behavior without requiring a live backend service.

---

#  Tech Stack

| Technology        | Usage                                  |
| ----------------- | -------------------------------------- |
| Flutter           | Cross-platform application development |
| Dart              | Programming language                   |
| Provider          | State management                       |
| SharedPreferences | Local booking persistence              |
| Material UI       | Application interface                  |
| Git               | Version control                        |
| GitHub            | Source code hosting                    |

---

#  Screens

The application includes the following major screens:

### 1. Home Screen

Provider discovery, search, filtering, sorting, and pagination.

### 2. Provider Details Screen

Detailed handyman information and booking entry point.

### 3. Booking Form Screen

Customer details, booking schedule, job details, validation, and live pricing.

### 4. Booking Confirmation Screen

Displays the successfully created booking information.

### 5. My Bookings Screen

Upcoming and historical booking management.

---

#  Data & Business Rules

The application follows several important business rules:

* Users cannot create invalid bookings.
* Required customer information must be provided.
* Booking dates must be selected.
* A valid time slot must be selected.
* Estimated hours must be between 1 and 8.
* Job descriptions must satisfy validation rules.
* Duplicate active bookings are prevented.
* Saturday bookings receive a 15% surcharge.
* A LKR 500 visiting charge is included.
* Booking statuses are managed through centralized business logic.
* Local bookings are persisted using SharedPreferences.

---

#  UI / UX

The application focuses on a clean and practical user experience.

UI considerations include:

* Clear information hierarchy
* Reusable components
* Responsive layouts
* Loading indicators
* Empty states
* Error states
* Form validation
* Confirmation dialogs
* Status indicators
* Light and dark themes
* Clear navigation between booking steps

---

#  Getting Started

## Prerequisites

Make sure Flutter is installed and configured.

Check your Flutter installation:


flutter doctor


---

## Clone the Repository


git clone <https://github.com/Chamod-Kulathunga/fixit_handyman_app>


Navigate into the project:


cd fixit_handyman_app


---

## Install Dependencies


flutter pub get


---

## Run the Application

For a connected Android device or emulator:


flutter run


---

## Run Static Analysis


flutter analyze


The project should pass Flutter static analysis without issues.

---

#  Build APK

To generate a release APK:


flutter build apk --release


The generated APK can be found under:


build/app/outputs/flutter-apk/


---

#  Project Quality

The project focuses on:

* Separation of concerns
* Reusable widgets
* Provider-based state management
* Repository abstraction
* Local persistence
* Centralized business logic
* Form validation
* Error handling
* Async state handling
* Maintainable folder structure
* Consistent UI/theming

---

#  Possible Future Improvements

Although the current application is implemented using local/mock data for the practical assignment, the architecture allows future expansion.

Potential improvements include:

* REST API integration
* User authentication
* Backend booking management
* Real-time booking status updates
* Push notifications
* Online payments
* Provider reviews and ratings
* Provider-side application
* Location/map integration
* Cloud database synchronization
* Automated unit and widget testing

---


#  Recommended Repository Structure


fixit_handyman_app/
│
├── android/
├── ios/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── enums/
│   │   ├── theme/
│   │   └── utils/
│   │
│   ├── data/
│   │   ├── models/
│   │   └── repositories/
│   │
│   ├── domain/
│   │   └── business_logic/
│   │
│   ├── presentation/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   └── main.dart
│
├── screenshots/
├── test/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

#  Git Workflow

The project is maintained using Git for version control.

Example feature commit messages:


git commit -m "feat: add local booking persistence and state management"



git commit -m "feat: add my bookings screen"

The repository is hosted on GitHub for source-code management and submission.

---

#  Developer

**FixIt Handyman App**

Developed using Flutter and Dart as part of a practical software engineering assignment.

---

##  Conclusion

FixIt Handyman App demonstrates a complete end-to-end handyman booking workflow, from discovering a service provider to creating, persisting, and managing a booking.

The application was structured with maintainability and scalability in mind, keeping UI, state management, data access, and business rules separated so the project can be extended with a real backend in the future.
