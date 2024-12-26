
# ConVenuence

ConVenuence is a SwiftUI-based iOS application designed for effortless venue discovery and management, leveraging the Foursquare API. The app is built with a focus on modularity, clean architecture, and testability to ensure high-quality, reusable code.

## Project Overview

The app's core functionality includes:
- Searching for venues near the user's location.
- Viewing detailed venue information.
- Saving favorite venues locally for future access.
- Offline support with cached search results.

To achieve this functionality, the project is structured into multiple layers, adhering to clean architecture principles.

---

## Technical Decisions

### 1. **Swift Package for Core Logic**
A Swift Package, `ConvenienceCore`, encapsulates all non-UI logic, making it reusable and UI-agnostic. This ensures that the app's business logic, networking, and persistence can be maintained independently of the UI.

- **Advantages**:
  - Separation of concerns.
  - Reusability across projects.
  - Clear boundaries between UI and logic.
  - It's just nicer to work outside of Xcode from time to time.

---

### 2. **Layered Architecture**
The project is divided into the following layers, each with a defined responsibility and a sensible API:

#### **Networking Layer**
- Handles API requests and responses.
- Uses `URLSession` for async networking.
- Contains DTOs for mapping API data and serialization/deserialization logic.
- Abstracted into a protocol (`VenueAPIClient`) for easy mocking and testing.

#### **Persistence Layer**
- Manages local storage using Core Data.
- Provides functionality for saving, retrieving, and deleting data.
- Encapsulated in a `PersistenceController` to abstract Core Data complexities.
- Thread-safe for concurrent operations.

#### **Service Layer**
- Acts as a repository for venues, combining networking and persistence layers.
- Provides APIs to:
  - Search venues.
  - Fetch saved favorites.
  - Handle offline caching.
- Abstracted via a `VenueRepository` protocol to allow flexible implementation.

#### **UI Layer**
- Built with SwiftUI and follows the MVVM (Model-View-ViewModel) pattern.
- ViewModels interact with the Service Layer, providing data for SwiftUI views.
- Includes the following screens:
  - **Search Screen**: Search venues and view results.
  - **Venue Details Screen**: Display detailed information and save favorites.
  - **Favorites Screen**: List and manage saved venues.

---

### 3. **Key Principles**
- **Modularity**: Each layer can function independently and be replaced or reused without impacting the others.
- **Testability**: Comprehensive unit tests for Networking, Persistence, and Service layers.
- **Dependency Injection**: Ensures layers are decoupled and mockable.
- **Clean Code**: Adheres to SOLID principles for maintainability and scalability.
- **Offline Support**: Cached results are displayed when no internet connection is available.

---

## Project Structure

```plaintext
ConVenuence/
│
├── ConvenienceCore/            # Swift Package for non-UI logic
│   ├── Networking/
│   │   ├── VenueAPIClient.swift
│   │   └── Models/
│   │       ├── VenueDTO.swift
│   │       └── SearchResponseDTO.swift
│   ├── Persistence/
│   │   ├── PersistenceController.swift
│   │   └── VenueEntity.swift
│   ├── Services/
│   │   ├── VenueRepository.swift
│   │   └── VenueService.swift
│   └── Tests/                  # Unit tests for all layers
│
├── ConVenuenceApp/             # Main app
│   ├── Views/
│   │   ├── SearchView.swift
│   │   ├── VenueDetailView.swift
│   │   └── FavoritesView.swift
│   ├── ViewModels/
│   │   ├── SearchViewModel.swift
│   │   ├── VenueDetailViewModel.swift
│   │   └── FavoritesViewModel.swift
│   └── App.swift               # App entry point
│
└── README.md                   # Project documentation
```

---

## Future Enhancements
- Add pagination for venue search results.
- Extend persistence to support user-defined categories or tags for favorites.
- Implement more robust error handling for edge cases (e.g., rate-limiting, partial API outages).

---
