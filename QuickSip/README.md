# QuickSip iOS App

A native iOS app built with SwiftUI, designed to enable college students to order coffee or matcha drinks on demand and have them delivered to their location, such as dorms, libraries, or classrooms.

## Project Setup

### Prerequisites
- Xcode 16+
- Swift 5.9+
- iOS 15.0+ deployment target
- Firebase account

### Firebase Setup
1. **Create Firebase Project**:
   - Go to the [Firebase Console](https://console.firebase.google.com/)
   - Create a new project named "QuickSip"
   - Enable Google Analytics (recommended)

2. **Add iOS App to Firebase**:
   - On the project dashboard, add an iOS app
   - Use your Bundle ID (e.g., com.yourdomain.QuickSip)
   - Download the `GoogleService-Info.plist` file

3. **Add GoogleService-Info.plist to the Project**:
   - Drag the downloaded file into your Xcode project
   - Make sure to add it to all targets

### Dependencies
This project uses Swift Package Manager for dependencies:
- Firebase iOS SDK (Firestore, Authentication, Database, Messaging)
- Future dependency: Stripe iOS SDK

### File Structure
- **Views**: UI components and screens
- **Models**: Data models (User, Order)
- **ViewModels**: Business logic and data management
- **Services**: API interactions, Firebase services
- **Utilities**: Helper functions, extensions, color schemes

## Development
- Minimum iOS version: 15.0
- Primary color scheme: Green and white
- Design principles: Clean, minimalistic UI with accessibility support

## Tasks
This app is being developed according to a structured development plan, starting with the core functionality (order flow) and gradually adding features like real-time status updates, push notifications, and payment processing. 