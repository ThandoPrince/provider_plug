# Plug Service Provider Setup

## Prerequisites

Before running the Plug Service Provider application, make sure the following are configured:

* **Plug Backend** is running and accessible.
* A **Google Cloud project** is configured with the required Google Maps APIs.
* **Firebase** is configured for push notifications.

The Service Provider application communicates with the backend API for authentication, service management, bookings, service requests, notifications, location tracking, and other functionality.

### Google Maps Configuration

The Plug Service Provider application requires a Google Maps API key with the required Google Maps services enabled:

* **Maps SDK**
* **Places API**
* **Directions API**

Make sure the API key is configured correctly for the Android/iOS application and that the required APIs are enabled in the Google Cloud project.

Google Maps services are used for functionality such as:

* Displaying maps
* Selecting locations
* Address/place searches
* Service provider location
* Live location tracking
* Directions and route information
* Booking and service-request location functionality

### Firebase Configuration

The Plug Service Provider application uses **Firebase Cloud Messaging (FCM)** for push notifications.

Make sure the Firebase project is configured for the application and that the appropriate Firebase configuration files are included in the project.

Firebase is required for functionality such as:

* Push notifications
* New service requests
* Booking notifications
* Booking status updates
* Other real-time application notifications

### 1. Navigate to the Plug Service Provider

```powershell
cd D:\plug\flutter_application_2
```

If a Python virtual environment is active, you can deactivate it:

```powershell
deactivate
```

### 2. Install Flutter Dependencies

Run:

```powershell
flutter pub get
```

### 3. Generate App Icons

The project uses `flutter_launcher_icons` to generate the application icons.

Make sure the following configuration is present in `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/plug_icon.png"
  adaptive_icon_foreground: "assets/icons/plug_icon_foreground.png"
  adaptive_icon_background: "#0F172A"
  min_sdk_android: 21
```

Generate the launcher icons:

```powershell
dart run flutter_launcher_icons
```

### 4. Generate the Native Splash Screen

The project uses `flutter_native_splash` for the Android and iOS splash screens.

Make sure the following configuration is present in `pubspec.yaml`:

```yaml
flutter_native_splash:
  color: "#3EC5FF"
  image: assets/icons/plug_icon.png

  android_12:
    color: "#3EC5FF"
    image: assets/icons/plug_icon.png
```

Generate the splash screen:

```powershell
dart run flutter_native_splash:create
```

### 5. Run the Service Provider Application

Once the backend, Google Maps, and Firebase configuration are ready, start the Flutter application:

```powershell
flutter run
```

### Important

The **Plug Backend must be running before starting the Plug Service Provider application**.

Google Maps and Firebase must also be configured correctly. If any of these dependencies are unavailable or incorrectly configured, features such as:

* Login and registration
* Service provider profile management
* Service management
* Service requests
* Bookings
* Maps
* Places/address search
* Directions
* Live location tracking
* Notifications
* Other API-dependent functionality

may not work correctly.

### Complete Service Provider Setup

For a fresh setup:

```powershell
cd D:\plug\flutter_application_2

flutter pub get

dart run flutter_launcher_icons

dart run flutter_native_splash:create

flutter run

