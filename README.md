# LumaSpace

> *"Your photos. Your memories. Your space."*

**GDG Tech Wildcard Entry — Mobile App Development**  
A production-quality Smart Gallery and Media Organizer built with Flutter & Dart.

[![Flutter](https://img.shields.io/badge/Flutter-3.47.7-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.5-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green.svg)](https://github.com/S-T-HARINI/LumaSpace)
[![Tests](https://img.shields.io/badge/Automated%20Tests-39%2F39%20Passing-brightgreen.svg)](test/)
[![Analysis](https://img.shields.io/badge/flutter%20analyze-0%20issues-brightgreen.svg)](lib/)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

---

## 📥 Download Android APK

> [!IMPORTANT]
> ### Reviewer Quick Access & Direct Downloads
> - 🚀 **[Direct Download: app-arm64-v8a-release.apk (166 MB)](https://github.com/S-T-HARINI/LumaSpace/releases/download/v1.0.0/app-arm64-v8a-release.apk)**  
>   *(Optimized for modern 64-bit Android devices, including Samsung Galaxy M36 running Android 16)*
> - 📦 **[View GitHub Release v1.0.0 (All Assets & Release Notes)](https://github.com/S-T-HARINI/LumaSpace/releases/tag/v1.0.0)**
> - 📁 **Alternative Google Drive Demo Video / Backup:** *[Google Drive Demo Video / Mirror](https://github.com/S-T-HARINI/LumaSpace/releases)*
> 
> **Installation Instructions for Reviewers:**
> 1. Download the APK directly onto your Android device or sideload via ADB (`adb install -r app-arm64-v8a-release.apk`).
> 2. When prompted by Android, allow *"Install unknown apps"* for your browser or file manager.
> 3. Launch **LumaSpace** and tap **Allow** when prompted for media permissions to index your on-device gallery.
> 4. *(Local clone notice)* If you have cloned this repository locally, the compiled production release APKs are located in `build/app/outputs/flutter-apk/`.

---

## 🌟 Overview & Problem Statement

Modern mobile cameras and messaging apps produce gigabytes of photos and videos, quickly exhausting device storage. Existing gallery apps make cleaning up tedious, stressful, and risky:
1. **Accidental Deletions:** Single-tap or immediate deletions cause permanent loss of cherished memories.
2. **Cluttered Browsing:** Users are overwhelmed by massive timelines without an intuitive way to review media one by one.
3. **Heavy Memory Footprint:** Loading full-resolution media rapidly causes out-of-memory crashes and stuttering frame rates.
4. **Uncertain Reversible Deletion:** Generic cleanup utilities either delete files without native OS protection or falsely report space reclaimed when users cancel system confirmation prompts.

### The LumaSpace Solution
**LumaSpace** transforms photo management into a serene, tactile, and completely safe experience:
- **Real Device Media Browsing:** High-performance, lazy-loaded photo and video gallery indexed directly from device storage.
- **Date & Month Grouping Mode:** Optional chronological grouping by calendar month or specific date with sticky headers and item counts.
- **Swipe-Based Review Engine:** Review photos and videos with intuitive gestures — swipe right to keep, swipe left to mark for deletion.
- **Multi-Level Undo & Session History:** Every review decision is recorded and can be reversed one-by-one or in sequence. Review progress survives app restarts.
- **Safe, Reversible Deletion Workflow:** Swiping never deletes files. Items marked for deletion are staged in a dedicated Pending Deletion queue where users can deselect, restore, or confirm with the native operating system.
- **Dynamic Byte Reclamation Calculation:** Real-time calculation of reclaimable storage across B, KB, MB, and GB, updating immediately upon selection or deselection.
- **Android Scoped Storage Reconciliation:** Fully compliant with Android Scoped Storage (`MediaStore.createDeleteRequest`). If the user cancels the OS deletion prompt, files remain completely intact in storage and remain staged in Pending Deletion without false success reporting.
- **Duplicate Candidate Detection:** Smart discovery of duplicate photos and videos based on matching file sizes, dimensions, and media duration without reading heavy byte streams into memory.
- **Storage Overview Sheet:** Clear breakdown of indexed photos, videos, total storage size, and pending reclaimable space.
- **Seven Curated Themes + System Mode:** Polished Material 3 design with 7 distinct palettes and automatic system dark/light adaptation.
- **Tactile Lift Effects:** Subtle pressed-state elevation and scaling across cards, thumbnails, buttons, and navigation without slowing down interactions.

---

## 📱 Key Features & Capabilities

### 1. Device Media Gallery
- **Real Photos & Videos:** Connects directly to device media via platform APIs (`photo_manager`).
- **Virtualization & Pagination:** Lazy loading in batches of 80 items with an in-memory thumbnail decoding cache (up to 250 items) prevents isolate blocking.
- **Grouping Modes:** Toggle between **No Grouping**, **Group by Month** (e.g., *"October 2026"*), and **Group by Date** (e.g., *"19 October 2026"*). Invalid or missing dates are gracefully grouped under *"Unknown Date"*.
- **Album Switching:** Browse All Media or filter by specific device folders (Camera, Screenshots, Downloads, WhatsApp, etc.).
- **Sorting Options:** Newest First, Oldest First, Largest First, and Smallest First.
- **Smart Filtering:** All Media, Photos Only, Videos Only, and Large Files (>10 MB).
- **Responsive Layout:** Automatically adapts between 3 columns in portrait and 5 columns in landscape.

### 2. Full-Screen Media Viewer
- **Interactive Image Zoom & Pan:** Smooth pinch-to-zoom (up to 4.5x) and animated double-tap zoom.
- **Integrated Video Player:** Hardware-accelerated video playback with play/pause controls, progress scrubber, and timestamp feedback (`video_player`).
- **Metadata Inspector:** Bottom sheet detailing filename, date, dimensions, file size (B, KB, MB, GB), duration, and media type.
- **Unified Review Action Bar:** Mark as Kept or Pending Deletion directly while browsing full screen.

### 3. Swipe-Review Engine
- **Gesture Physics:** Smooth card rotation and translation responsive to touch drag.
- **Visual & Haptic Cues:** Dynamic "KEEP" (green) and "DELETE" (red) badges fade in with drag distance; tactile haptic pulse triggers when crossing the decision threshold.
- **Deck Preview:** Subtle card preview beneath the active item provides visual continuity.
- **Accessible Controls:** Dedicated on-screen buttons for Keep, Delete, Info, and Undo ensure complete accessibility.
- **Completion Summary:** Displays review session accomplishments with quick navigation to Pending Deletion.

### 4. Safe Pending Deletion & Scoped Storage
- **Reversible Staging:** Files remain safe on the device until explicit system confirmation.
- **Individual Deselection:** Deselect specific files to keep them without losing the rest of the pending queue.
- **Dynamic Size Reclamation:** Accurately totals file sizes in bytes and estimates reclaimed storage formatted across B, KB, MB, and GB.
- **Confirmation Dialog:** Warns user before invoking the operating system deletion prompt.
- **Platform Reconciliation:** Listens to the platform-reported result. If the user cancels the Android Scoped Storage prompt, files are preserved and never falsely marked deleted.

### 5. Duplicate Candidate Detection *(Bonus Feature)*
- **Smart Grouping:** Identifies duplicate photos and videos sharing identical byte sizes, image dimensions, and video durations.
- **Memory-Efficient:** Evaluates metadata without reading heavy file streams into RAM.
- **One-Tap Staging:** Preview duplicate groups and stage extra copies directly into the Pending Deletion queue for safe review.

### 6. Storage Overview Sheet *(Bonus Feature)*
- **Comprehensive Storage Stats:** Accessible from Settings, displaying total photos indexed, total videos indexed, combined storage usage, and pending reclaimable space.

### 7. Seven Themes + System Mode
- **Google Light:** Clean white surfaces with Google blue accent (`#1A73E8`).
- **Google Dark:** Deep neutral dark surfaces with soft blue accent (`#8AB4F8`).
- **Graphite:** Sophisticated monochrome charcoal and zinc gray palette.
- **Sage:** Muted natural green (`#3B6E4C`) with warm neutral surfaces.
- **Sand:** Warm beige and cream (`#8D6E53`) with earthy tones.
- **Rose:** Dusty rose (`#9E4B65`) with soft blush neutrals.
- **Ocean:** Deep teal-blue (`#1E6091`) with cool slate surfaces.
- **System Mode:** Dynamically mirrors system light/dark mode.
- *Selections persist across app launches using SharedPreferences.*

---

## 🛠 Framework & Technology Stack

| Component | Technology / Version | Role in LumaSpace |
|:---|:---|:---|
| **Framework** | **Flutter 3.47.7** (Channel stable) | Cross-platform UI toolkit and runtime |
| **Language** | **Dart 3.13.5** | Strongly typed, null-safe application logic |
| **State Management** | **Provider ^6.1.5+1** | Decoupled reactive state management (`GalleryProvider`, `ReviewProvider`, `DeletionProvider`, `ThemeProvider`) |
| **Media Discovery** | **photo_manager ^3.12.0** | Device media querying, paging, thumbnail decoding, Scoped Storage deletion |
| **Video Playback** | **video_player ^2.14.1** | Hardware-accelerated video decoding with seek scrubber |
| **Persistence** | **shared_preferences ^2.5.6** | Persisting theme choices and review classifications |
| **Android Integration**| **shared_preferences_android 2.4.17** | Native Android platform storage implementation |
| **Localization & Dates**| **intl ^0.20.3** | Date/month formatting for gallery grouping headers and metadata |
| **UI Icons** | **cupertino_icons ^1.0.8** & Material Icons | Platform-adaptive iconography |
| **Code Quality** | **flutter_lints ^6.0.0** | Strict static analysis adhering to Flutter best practices |

### Android Platform Requirements
- **Minimum SDK:** API 21 (Android 5.0 Lollipop)
- **Target & Compile SDK:** API 34 / 35 (Android 14 / 15)
- **Tested & Verified Device:** Samsung Galaxy M36 running Android 16
- **Supported Architectures (ABIs):**
  - `arm64-v8a` — Modern 64-bit mobile processors (recommended)
  - `armeabi-v7a` — 32-bit mobile devices
  - `x86_64` — 64-bit Android Studio emulators

---

## 🔒 Permissions & Security Architecture

LumaSpace respects user privacy and strictly limits permission requests to media indexing and storage management.

### Permission Breakdown

| Permission | Android Version | Purpose in LumaSpace |
|:---|:---|:---|
| `android.permission.READ_MEDIA_IMAGES` | Android 13+ (API 33+) | Queries photos on modern Android without broad storage permission. |
| `android.permission.READ_MEDIA_VIDEO` | Android 13+ (API 33+) | Queries videos on modern Android without broad storage permission. |
| `android.permission.READ_MEDIA_AUDIO` | Android 13+ (API 33+) | Complies with platform media engine audio requirements. |
| `android.permission.READ_EXTERNAL_STORAGE` | Android 5.0–12 (API 21–32) | Backwards-compatible photo and video access for legacy Android. |
| `android.permission.WRITE_EXTERNAL_STORAGE`| Android 5.0–9 (API 21–29) | Backwards-compatible file modification on legacy Android devices. |
| `android.permission.ACCESS_MEDIA_LOCATION` | Android 10+ (API 29+) | Reads EXIF geolocation metadata to display photo location details in the metadata inspector. |

### Graceful Permission Handling & Denied Recovery
LumaSpace never crashes or leaves the user on a blank screen if permissions are denied:
1. **Interactive Prompt:** On first launch, the app gracefully requests media access via `photo_manager`.
2. **Dedicated Recovery Screen:** If the user denies or restricts permissions, the gallery displays an informative fallback UI offering three clear options:
   - **Grant Media Permission:** Re-triggers the permission request flow.
   - **Open App Settings:** Directly launches Android's app settings page for LumaSpace so the user can enable permissions manually.
   - **Try Demo Mode (Mock Media):** Instantly populates the app with 8 high-resolution mock photos and videos, allowing full evaluation of all features without granting storage permissions.

---

## 🏗 Architecture & Code Structure

LumaSpace follows a clean, decoupled architecture separating presentation, business logic, and platform services:

```
lib/
├── core/
│   ├── constants/             # Strings, dimensions, animation constants
│   ├── theme/
│   │   ├── app_theme.dart     # 7 theme definitions + AppThemeColors extension
│   │   └── theme_provider.dart# Dynamic theme switching & SharedPreferences persistence
│   └── widgets/
│       ├── badge_chip.dart    # Filter pills & count chips
│       ├── empty_state_view.dart# Clean empty state presentations
│       ├── error_state_view.dart# Error display with retry handlers
│       ├── lift_container.dart# Signature tactile lift & scale widget
│       └── loading_view.dart  # Minimal progress indicators
├── data/
│   ├── models/
│   │   ├── media_item.dart    # Unified photo/video model with thumbnail caching & size formatting
│   │   └── review_action.dart # Action record for multi-step undo
│   └── services/
│       ├── duplicate_detection_service.dart # Duplicate discovery by size, dimension & duration
│       ├── media_service.dart # Platform media queries & Scoped Storage deletion
│       ├── mock_media_helper.dart # UI demo & browser inspection mock generator
│       └── preferences_service.dart # SharedPreferences persistence layer
├── providers/
│   ├── deletion_provider.dart # Pending queue, deselection, size math & deletion reconciliation
│   ├── gallery_provider.dart  # Media loading, pagination, sorting, filtering & grouping
│   └── review_provider.dart   # Keep/delete classifications, undo & history
└── screens/
    ├── duplicates/            # Duplicate candidate review & staging screen
    ├── gallery/               # Gallery grid, album selector, grouping & sort sheets
    ├── main_scaffold.dart     # IndexedStack bottom navigation (preserves tab state)
    ├── pending/               # Pending deletion queue, deselection & confirmation dialog
    ├── review/                # Swipe deck & review controls
    ├── settings/              # Theme selector, demo mode, storage overview & reset
    └── viewer/                # Full-screen image zoom & video playback
```

---

## ⚡ Performance Strategy for Large Media Libraries

LumaSpace is engineered to handle libraries containing tens of thousands of media files smoothly without frame drops or high memory usage:

1. **Lazy Grid Virtualization:** Uses `CustomScrollView` with `SliverGrid` and `SliverList` to render only items currently visible in the viewport.
2. **Incremental Batch Queries:** Media assets are queried from `MediaStore` in small batches of 80 items instead of loading the entire device index into RAM.
3. **Bounded Thumbnail Cache:** Maintains an in-memory thumbnail cache capped at 250 items with automatic FIFO eviction, preventing out-of-memory errors on memory-constrained devices.
4. **Thumbnail Downscaling:** Thumbnails are decoded natively at $256 \times 256$ pixels with 75% quality rather than decoding full 12–50 MP camera images into memory.
5. **On-Demand Controller Lifecycle:** `VideoPlayerController` instances are initialized strictly when opening the full-screen viewer and disposed immediately upon exit.
6. **State Preservation via IndexedStack:** Switching between Gallery, Review, Pending, and Settings retains scroll position and card state without re-querying the database.
7. **Efficient Duplicate Grouping:** Duplicate candidate discovery evaluates metadata fields (file size in bytes, width, height, duration) without reading byte content into memory.

---

## 🧪 Automated Verification & Test Results

The repository includes a comprehensive automated test suite verifying business logic, edge cases, state transitions, and UI widgets:

```bash
flutter analyze
```
> **Result:** `No issues found! (0 warnings, 0 errors)`

```bash
flutter test
```
> **Result:** `All 39 tests passed!`

### Test Breakdown by Domain

| Test Suite | File | Tests | Validated Behavior |
|:---|:---|:---:|:---|
| **Deletion Provider** | `test/unit/deletion_provider_test.dart` | 8 | Default selection, selective deselection, dynamic byte summation, byte-to-human formatting (B, KB, MB, GB), partial size estimation, select/deselect all, full deletion success, Scoped Storage cancellation reconciliation. |
| **Duplicate Detection**| `test/unit/duplicate_detection_test.dart` | 4 | Duplicate grouping by size/dimensions/duration, non-duplicate filtering, sorting groups by potential space savings descending. |
| **Gallery Provider** | `test/unit/gallery_provider_test.dart` | 12 | Initial sort order, date sort (Asc/Desc), size sort (Asc/Desc), photo/video/large file filtering, thumbnail size updates, `copyWith` immutability, month grouping, date grouping, unknown date fallback. |
| **Review Provider** | `test/unit/review_provider_test.dart` | 9 | Initial empty state, keep transitions, pending delete transitions, reversible state switching, single undo, multi-step consecutive undo, unreviewed item filtering, restoring from pending, full reset. |
| **Theme System** | `test/unit/theme_test.dart` | 3 | All 7 distinct theme definitions, system brightness adaptation, theme persistence via provider. |
| **Confirmation Dialog**| `test/widget/confirmation_dialog_test.dart` | 1 | Modal rendering of file count, total size calculation, and execution of confirmed callback. |
| **Navigation Scaffold**| `test/widget/navigation_test.dart` | 2 | Bottom navigation bar destinations, tab switching, and view hierarchy preservation. |

---

## 📋 Step-by-Step Manual Reviewer Test Checklist

Reviewers can verify all functionality on a physical Android device (e.g., Samsung Galaxy M36 running Android 16) by following this walkthrough:

| # | Step / Action | Verification Checklist | Expected Behavior |
|:---:|:---|:---|:---|
| **1** | **Launch & Grant Permissions** | Launch LumaSpace for the first time. | Permission dialog appears. Tap **Allow All**. Real device photos and videos populate the gallery grid smoothly. |
| **2** | **Gallery Browsing** | Fast scroll through the gallery grid. | Smooth 60/120 FPS scrolling with lazy-loaded thumbnails. Video items display duration overlay badges. |
| **3** | **Date / Month Grouping** | Tap the Grouping icon in the top app bar. Select **Group by Month**, then **Group by Date**. | Gallery smoothly reorganizes into chronological sections with sticky headers (e.g., *"October 2026"*) and item count badges. |
| **4** | **Albums & Filtering** | Tap the album selector dropdown; select an album (e.g. *Screenshots*). Tap the filter pills (*Videos*, *Large Files*). | Grid updates instantly to display only matching media from the selected album. |
| **5** | **Full-Screen Viewer** | Tap a photo to enter full screen. Pinch to zoom and double-tap zoom. Tap a video to test playback. Tap the **Info** button. | Pinch zoom zooms up to 4.5x. Video scrubber allows seeking with live timestamps. Metadata sheet displays filename, date, dimensions, file size, and duration. |
| **6** | **Swipe Review** | Navigate to the **Review** tab. Drag a card right (Keep). Drag another card left (Mark for deletion). | Green "KEEP" and red "DELETE" badges fade in with drag distance. A tactile haptic pulse triggers when crossing the threshold. Card smoothly dismisses. |
| **7** | **Multi-Step Undo** | Tap the **Undo** button in the review controls bar twice. | Previously reviewed cards reappear in the review deck in reverse order, restoring their unreviewed state. |
| **8** | **Storage Overview & Duplicates** | Navigate to **Settings** > tap **Storage Overview**. Then tap **Find Duplicates**. | Storage overview sheet displays accurate photo/video counts and total size. Duplicate detector lists duplicate candidate groups sorted by space savings. |
| **9** | **Pending Deletion Review** | Switch to the **Pending** tab. Observe the total reclaimable size banner. Tap an item's checkbox to deselect it. | Deselected item unchecks; total reclaimable size dynamically recalculates immediately across B, KB, MB, or GB. File is not deleted. |
| **10** | **Cancellation Safety (Crucial)** | Tap **Delete Selected** > Tap **Proceed** on the LumaSpace warning modal. In the Android OS system prompt (`MediaStore.createDeleteRequest`), tap **Deny** or **Cancel**. | **Safety verified:** LumaSpace detects cancellation. The item remains in Samsung Gallery / Google Photos and stays in the Pending Deletion queue. No false success message is shown. |
| **11** | **Safe Deletion Execution** | Tap **Delete Selected** > Tap **Proceed** > In the Android OS prompt, tap **Allow**. | The selected file is deleted from the device. Pending list clears and gallery updates immediately. |
| **12** | **Theme Adaptation** | Go to **Settings** > **Theme**. Select each of the 7 themes (Google Light, Google Dark, Graphite, Sage, Sand, Rose, Ocean) and **System mode**. Restart app. | Palette shifts smoothly across all surfaces and components. Selected theme persists across app restarts. |

---

## 💻 Developer Setup & Build Guide

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) `^3.13.5` (Tested on `3.47.7`)
- [Dart SDK](https://dart.dev/get-dart) `^3.13.5`
- [Android SDK Platform](https://developer.android.com/studio) (API 34 or 35 with build-tools)
- Physical Android phone with USB Debugging enabled, or an Android Studio emulator

### 1. Clone the Repository
```bash
git clone https://github.com/S-T-HARINI/LumaSpace.git
cd LumaSpace
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Static Analysis & Automated Tests
```bash
flutter analyze
flutter test
```

### 4. Run the Application
```bash
# Debug mode on connected Android device
flutter run

# Production release mode on connected Android device
flutter run --release
```

### 5. Build Release APKs
```bash
# Build split-per-ABI APKs (recommended for smaller file sizes)
flutter build apk --split-per-abi --release

# Or build a fat universal APK containing all architectures
flutter build apk --release
```

### Compiled APK Output Locations

| Artifact | Location | Target Architecture |
|:---|:---|:---|
| **ARM 64-bit APK** | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` | Modern Android phones (e.g. Samsung Galaxy M36) |
| **ARM 32-bit APK** | `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` | Older 32-bit Android phones |
| **x86_64 APK** | `build/app/outputs/flutter-apk/app-x86_64-release.apk` | Android emulators |
| **Universal APK** | `build/app/outputs/flutter-apk/app-release.apk` | Universal fat binary |

---

## 🌐 Web Browser Inspection & Mock Demo Mode

LumaSpace can also be inspected directly in a desktop browser using Flutter Web:

```bash
flutter run -d chrome
```

### Mock Demo Engine
Because web browsers operate in a sandbox without access to native Android storage APIs (`photo_manager`), LumaSpace includes a built-in **Mock Demo Mode**:
1. When launched in Chrome or Edge, an informative banner alerts the reviewer that the browser environment uses the Mock Demo engine.
2. In **Settings**, tap **Mock Demo Data** to populate the application with 8 simulated photos and videos (with memory-backed thumbnails).
3. Review, swipe, undo, filter, sort, group, and inspect themes directly in your browser without requiring a connected Android device.

---

## 📌 Release & Submission Verification

The production Android release has been built, tested, and published to GitHub:
- **Release Tag:** `v1.0.0`
- **Release Page:** [LumaSpace v1.0.0 – GDG Tech Wildcard Entry](https://github.com/S-T-HARINI/LumaSpace/releases/tag/v1.0.0)
- **Direct APK Download:** [app-arm64-v8a-release.apk](https://github.com/S-T-HARINI/LumaSpace/releases/download/v1.0.0/app-arm64-v8a-release.apk)
- **Asset Size:** 174,016,762 bytes (166.0 MB)
- **SHA-256 Digest:** `77d106d3ec2554178e5dc643966e1e78c15b723ac6bab5b4615c06c9cb110fe9`
- **Verified Target Device:** Samsung Galaxy M36 (Android 16)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
