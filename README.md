# AED Map

A Flutter application designed to visualize and navigate to Automated External Defibrillators (AEDs) across Poland.

## Goal

The primary objective of this application is to provide an interactive, reliable, and high-performance map showing AED locations. It helps users find the nearest life-saving equipment quickly, supporting both online and offline use-cases.

## Architecture

The project follows the **MVVM (Model-View-ViewModel)** architectural pattern to ensure separation of concerns, testability, and maintainability.

- **`lib/ui`**: Contains the View (UI) and ViewModel layers. It handles user interaction and business logic related to the presentation.
- **`lib/data`**: The Model layer, responsible for data retrieval, local database management (Sqflite), and parsing GeoJSON data.
- **`lib/core`**: Contains foundational elements like base classes, constants, and global utilities used across the application.

## Main Libraries

- **[Mapbox Maps Flutter](https://pub.dev/packages/mapbox_maps_flutter)**: Provides the core mapping functionality, marker clustering, and interactive styling.
- **[Sqflite](https://pub.dev/packages/sqflite)**: Used for local persistence of AED data to support offline functionality.
- **[Location](https://pub.dev/packages/location)**: Handles real-time device location tracking to find the nearest AED.
- **[Flutter Dotenv](https://pub.dev/packages/flutter_dotenv)**: Manages environment variables like Mapbox access tokens securely.

## Getting Started

### Prerequisites

1.  **Mapbox Access Token**: Obtain a public token (`pk.`) and place it in a `.env` file at the project root:
    ```env
    MAPBOX_ACCESS_TOKEN=pk.your_token_here
    ```
2.  **SDK Registry Token**: A secret token (`sk.`) with `DOWNLOADS:READ` scope is required for Android builds. Place it in your global `~/.gradle/gradle.properties`:
    ```properties
    SDK_REGISTRY_TOKEN=sk.your_secret_token_here
    ```

### Installation

1.  Clone the repository.
2.  Run `flutter pub get`.
3.  Ensure your Android/iOS environment is configured with the Mapbox SDK requirements.
4.  Run the app using `flutter run`.
