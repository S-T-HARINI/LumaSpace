# LumaSpace

> *"Your photos. Your memories. Your space."*

**GDG Tech Wildcard Entry — Mobile App Development**  
A production-quality Smart Gallery and Media Organizer built with Flutter & Dart.

[![Flutter](https://img.shields.io/badge/Flutter-3.47.7-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.5-blue.svg)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green.svg)](https://github.com/S-T-HARINI/LumaSpace)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

---

## 🌟 Overview & Problem Statement

Modern mobile cameras and messaging apps produce gigabytes of photos and videos, quickly filling up device storage. Existing gallery apps make cleaning up tedious, stressful, and risky:
1. **Accidental Deletions:** Single-tap or immediate deletions cause permanent loss of cherished memories.
2. **Cluttered Browsing:** Users are overwhelmed by huge timelines with no intuitive way to review media one-by-one.
3. **Heavy Memory Consumption:** Loading full-resolution media rapidly causes out-of-memory crashes and scrolling lag.

### The LumaSpace Solution
**LumaSpace** transforms photo management into a serene, tactile, and completely safe experience:
- **Real Device Media Browsing:** High-performance, lazy-loaded photo and video gallery indexed directly from device storage.
- **Swipe-Based Review Engine:** Review photos and videos with intuitive gestures — swipe right to keep, swipe left to mark for deletion.
- **Multi-Level Undo & Session Persistence:** Every review decision is recorded and can be reversed one-by-one or in sequence. Review progress survives app restarts.
- **Safe, Reversible Deletion Workflow:** Swiping never deletes files. Items marked for deletion are staged in a dedicated Pending Deletion queue where users can deselect, restore, or confirm with the native operating system.
- **Platform-Native Deletion:** Fully compliant with Android Scoped Storage (`MediaStore.createDeleteRequest`) and iOS Photo Library deletion dialogs. Zero false success reporting if the user cancels.
- **Seven Curated Themes + System Mode:** Polished Material 3 design with 7 distinct palettes and automatic system dark/light adaptation.
- **Tactile Lift Effects:** Subtle pressed-state elevation and scaling across cards, thumbnails, buttons, and navigation without slowing down interactions.

---

## 📱 Key Features

### 1. Device Media Gallery
- **Real Photos & Videos:** Connects directly to device media via platform APIs.
- **Virtualization & Pagination:** Lazy loading (80 items/batch) with thumbnail decoding cache (up to 250 in-memory items) prevents isolate blocking.
- **Album Switching:** Browse All Media or filter by specific device folders (Camera, Screenshots, Downloads, WhatsApp, etc.).
- **Sorting Options:** Newest First, Oldest First, Largest First, and Smallest First.
- **Smart Filtering:** All Media, Photos Only, Videos Only, and Large Files (>10 MB).
- **Responsive Layout:** Automatically adapts between 3 columns in portrait and 5 columns in landscape.

### 2. Full-Screen Media Viewer
- **Interactive Image Zoom & Pan:** Smooth pinch-to-zoom (up to 4.5x) and animated double-tap zoom.
- **Integrated Video Player:** Hardware-accelerated video playback with play/pause controls, progress scrubber, and timestamp feedback.
- **Metadata Inspector:** Bottom sheet detailing filename, date, dimensions, file size, duration, and media type.
- **Unified Review Action Bar:** Mark as Kept or Pending Deletion directly while browsing full screen.

### 3. Swipe-Review Engine
- **Gesture Physics:** Smooth card rotation and translation responsive to touch drag.
- **Visual & Haptic Cues:** Dynamic "KEEP" (green) and "DELETE" (red) badges fade in with drag distance; tactile haptic pulse triggers when crossing the decision threshold.
- **Deck Preview:** Subtle card preview beneath the active item provides visual continuity.
- **Accessible Alternatives:** Dedicated on-screen buttons for Keep, Delete, Info, and Undo ensure complete accessibility.
- **Completion Summary:** Displays review session accomplishments with quick navigation to Pending Deletion.

### 4. Safe Pending Deletion & Platform Deletion
- **Reversible Staging:** Files remain safe on the device until explicit system confirmation.
- **Individual Deselection:** Deselect specific files to keep them without losing the rest of the pending queue.
- **Size Reclamation Calculation:** Accurately totals file sizes and estimates reclaimed storage.
- **Confirmation Dialog:** Warns user before invoking the operating system deletion prompt.
- **Platform Reconciliation:** Listens to the platform-reported result. If the user cancels the Android Scoped Storage prompt, files are preserved and never falsely marked deleted.

### 5. Seven Themes + System Mode
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

## 🏗 Architecture & Code Structure

LumaSpace follows a clean, decoupled architecture:

```
lib/
├── core/
│   ├── constants/             # Strings, dimensions, animation constants
│   ├── theme/
│   │   ├── app_theme.dart     # 7 theme definitions + AppThemeColors extension
│   │   └── theme_provider.dart# Dynamic theme switching & persistence
│   └── widgets/
│       ├── badge_chip.dart    # Filter pills & count chips
│       ├── empty_state_view.dart# Clean empty state presentations
│       ├── error_state_view.dart# Error display with retry handlers
│       ├── lift_container.dart# Signature tactile lift & scale widget
│       └── loading_view.dart  # Minimal progress indicators
├── data/
│   ├── models/
│   │   ├── media_item.dart    # Unified photo/video model with thumbnail caching
│   │   └── review_action.dart # Action record for multi-step undo
│   └── services/
│       ├── media_service.dart # Platform media queries & Scoped Storage deletion
│       ├── mock_media_helper.dart # UI demo & browser inspection mock generator
│       └── preferences_service.dart # SharedPreferences persistence layer
├── providers/
│   ├── deletion_provider.dart # Pending queue, deselection, size math & deletion
│   ├── gallery_provider.dart  # Media loading, pagination, sorting & filtering
│   └── review_provider.dart   # Keep/delete classifications, undo & history
└── screens/
    ├── gallery/               # Gallery grid, album selector & sort sheets
    ├── main_scaffold.dart     # IndexedStack bottom navigation (preserves state)
    ├── pending/               # Pending deletion queue & confirmation dialog
    ├── review/                # Swipe deck & review controls
    ├── settings/              # Theme selector, demo mode, storage overview & reset
    └── viewer/                # Full-screen image zoom & video playback
```

---

## ⚡ Performance Strategy for Large Media Libraries

1. **Lazy Grid Virtualization:** Uses `GridView.builder` and `ListView.builder` to instantiate only visible tiles.
2. **Incremental Device Queries:** Queries media in batches of 80 items instead of loading the entire device index into RAM.
3. **Bounded Thumbnail Cache:** Maintains an in-memory thumbnail cache capped at 250 items with automatic eviction, ensuring memory stability even with libraries of 10,000+ photos.
4. **Thumbnail Downscaling:** Thumbnails are decoded at $256 \times 256$ with 75% quality rather than loading raw 12–48 MP camera images into memory.
5. **On-Demand Controller Lifecycle:** Video controllers and high-resolution image viewers are initialized only upon opening full-screen view and properly disposed of upon exit.
6. **State Preservation via IndexedStack:** Switching tabs does not trigger re-queries or reset review card positions.

---

## 🔒 Permissions & Platform Security

### Android
- **Android 13+ (API 33+):** Requires `android.permission.READ_MEDIA_IMAGES` and `android.permission.READ_MEDIA_VIDEO`.
- **Android 10–12 (API 29–32):** Uses `READ_EXTERNAL_STORAGE` and `WRITE_EXTERNAL_STORAGE`.
- **Scoped Storage:** Deletions invoke `PhotoManager.editor.deleteWithIds()`, which natively triggers Android's `MediaStore.createDeleteRequest` system confirmation modal.

### iOS
- Configured in `Info.plist`:
  - `NSPhotoLibraryUsageDescription`: Explains media access purpose.
  - `NSPhotoLibraryAddUsageDescription`: Allows photo library management.

---

## 🧪 Testing & Automated Verification

LumaSpace includes comprehensive unit and widget tests covering all critical paths:

- **Review State Transitions:** Verifies `markKeep`, `markPendingDelete`, and transitioning between states.
- **Multi-Level Undo:** Tests single and consecutive undo operations across history.
- **Pending Deletion Logic:** Verifies deselection, calculation of total bytes, and format conversions.
- **Platform Deletion Outcomes:** Simulates successful platform deletion, partial deletion, and user cancellation.
- **Gallery Sorting & Filtering:** Validates Date (Asc/Desc), Size (Asc/Desc), and filters (Photos, Videos, Large Files).
- **Theme System:** Verifies all 7 theme presets, color extensions, and system brightness adaptation.
- **Widget Navigation:** Verifies `MainScaffold` tab switching and state preservation.
- **Deletion Confirmation:** Tests modal warning dialog and confirmed callback execution.

### Running Tests
```bash
flutter test
```
*Result: 28/28 tests passed.*

### Running Analyzer
```bash
flutter analyze
```
*Result: No issues found! (0 warnings, 0 errors).*

---

## 📦 Android APK Builds & Download Options

### Generated Build Artifacts

| Build Type | Artifact Location | Description |
|:---|:---|:---|
| **Release APK** | `build/app/outputs/flutter-apk/app-release.apk` | Optimized for production release & installation. |
| **Debug APK** | `build/app/outputs/flutter-apk/app-debug.apk` | Contains debugging symbols for fast development. |

### How to Install the APK on Your Phone

#### Method 1: Via USB using ADB (Recommended)
```bash
# Connect phone via USB with USB Debugging enabled
adb devices
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

#### Method 2: Direct File Transfer
1. Connect your phone to your computer via USB (select "File Transfer / MTP" mode).
2. Copy `build/app/outputs/flutter-apk/app-release.apk` to your phone's **Downloads** folder.
3. On your phone, open your File Manager, tap the APK, and select **Install**.
*(If prompted, allow "Install unknown apps" for your file manager).*

#### Method 3: GitHub Releases
Download the compiled APK directly from the GitHub repository release section:
- Repository: [https://github.com/S-T-HARINI/LumaSpace](https://github.com/S-T-HARINI/LumaSpace)
- Releases: [https://github.com/S-T-HARINI/LumaSpace/releases](https://github.com/S-T-HARINI/LumaSpace/releases)

---

## 📱 Physical Phone Testing & Verification Checklist

Follow this checklist to test LumaSpace on your physical Android phone:

### Step 1: Enable Developer Options & USB Debugging
1. On your phone, open **Settings** > **About Phone**.
2. Tap **Build Number** 7 times until you see *"You are now a developer!"*.
3. Go back to **Settings** > **System** (or **Additional Settings**) > **Developer Options**.
4. Enable **USB Debugging**.
5. Connect your phone to the computer via USB.
6. When prompted on your phone screen (*"Allow USB debugging?"*), check **Always allow from this computer** and tap **Allow**.

### Step 2: Confirm Device Detection
Run in your terminal (no Android Studio required):
```bash
flutter devices
# Or:
adb devices
```
*Your phone should appear in the device list as `device` (not `unauthorized` or `offline`).*

### Step 3: Install & Launch LumaSpace
```bash
# Option A: Run directly in interactive debug mode with hot reload
flutter run

# Option B: Install the optimized release APK directly
flutter run --release
# Or via adb:
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Step 4: Step-by-Step On-Device Verification

| # | Action | Verification |
|:---:|:---|:---|
| 1 | **Grant Media Permissions** | App requests photo/video access on first launch. Tap **Allow All**. Verify real device photos and videos load into the gallery. |
| 2 | **Test Gallery Grid** | Scroll through your photos and videos. Verify smooth scrolling and lazy-loaded thumbnails. |
| 3 | **Test Albums & Filters** | Tap the album selector in the app bar; choose *Camera* or *Screenshots*. Filter by *Videos* or *Large Files*. |
| 4 | **Test Full-Screen Viewer** | Tap a photo: pinch to zoom, double-tap zoom. Tap a video: verify hardware playback and scrubbing. |
| 5 | **Test Swipe Review** | Navigate to the **Review** tab: swipe a card right (Keep), swipe another card left (Mark for deletion). Notice the tactile lift and haptic feedback. |
| 6 | **Test Multi-Step Undo** | Tap the Undo button twice in the Review tab. Verify items return to the review deck in reverse order. |
| 7 | **Review Pending Deletions** | Switch to the **Pending** tab: verify pending count badge, item thumbnails, and total size calculation. |
| 8 | **Test Deselection Safety** | Uncheck one item. Notice the total reclaimable size dynamically updates while the file remains untouched. |
| 9 | **Test Native Deletion** | Tap **Delete Selected**. Verify the LumaSpace confirmation modal appears. Tap Proceed. Verify Android's native Scoped Storage dialog (`MediaStore.createDeleteRequest`) appears. |
| 10 | **Test Cancellation Safety** | In the Android system dialog, tap **Deny/Cancel**. Verify LumaSpace detects the cancellation and preserves your files. |
| 11 | **Test Complete Deletion** | Select an unwanted test photo, tap Delete, and tap **Allow** in Android's system dialog. Verify the file is safely deleted from your phone. |
| 12 | **Test Theme Adaptation** | Go to **Settings** > **Theme** > Switch between all 7 themes (Google Light, Google Dark, Graphite, Sage, Sand, Rose, Ocean) and System mode. |

---

## 🌐 Web Browser Inspection & Mock Demo Mode

LumaSpace also supports Flutter Web for rapid UI inspection and presentation:

### Run in Browser
```bash
flutter run -d chrome
```
*Or build the web distribution:*
```bash
flutter build web
```

### Mock Demo Mode
Because web browsers run in a strict security sandbox without access to native Android media APIs (`photo_manager`), LumaSpace includes a built-in **Mock Demo Mode**:
1. Open the app in a web browser.
2. An informative banner alerts the reviewer that the browser environment uses the Mock Demo engine.
3. Open **Settings** > tap **Mock Demo Data** to populate the app with 8 high-resolution simulated photos and videos (with memory-backed thumbnails).
4. Review, swipe, undo, filter, sort, and inspect themes directly in Chrome/Edge without needing a physical phone connected.

---

## ⚠️ Known Limitations & Platform Differences

1. **Web Platform Limitation:** Browsers do not possess native mobile file system access or Android `MediaStore`. Full real-device media access and hardware deletion require an Android or iOS device. Browser mode uses the built-in Mock Demo engine.
2. **Android Scoped Storage Deletion:** On Android 11+ (API 30+), deleting media items belonging to other applications triggers an OS-level confirmation modal required by Google security guidelines. This is intentional and guarantees user safety.
3. **NDK Stripping Warning:** Debug builds may show an NDK `llvm-strip` warning if NDK build tools are partially installed on Windows; this does not affect functionality or release APK builds.
