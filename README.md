# LumaSpace

> *"Your photos. Your memories. Your space."*

**GDG Tech Wildcard Entry — Mobile App Development**  
A production-quality Smart Gallery and Media Organizer built with Flutter & Dart.

---

## 🌟 Overview & Problem Statement

Modern mobile cameras and messaging apps produce gigabytes of photos and videos, quickly filling up device storage. Existing gallery apps make cleaning up tedious and risky:
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
    ├── settings/              # Theme selector, storage overview & reset
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

## 🧪 Testing & Verification

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

### Running Analyzer
```bash
flutter analyze
```

---

## 🚀 Building & Running

### Prerequisites
- Flutter SDK 3.47+ (Dart 3.13+)
- Android SDK 37 (or device with Android 9.0+)

### Run on Connected Device or Emulator
```bash
flutter run
```

### Build Android APK
```bash
flutter build apk --debug
# Or for release:
flutter build apk --release
```

---

## 📋 Demonstration Checklist

| Step | Feature Tested | Expected Result |
|:---:|:---|:---|
| 1 | **Launch Application** | App opens with Google Light / System mode, loads device media smoothly. |
| 2 | **Gallery Browsing** | Photos and videos render in responsive grid with video duration pills. |
| 3 | **Full-Screen Viewer** | Tap a photo to pinch/double-tap zoom; tap a video to play/pause and seek. |
| 4 | **Sorting & Filtering** | Change sort to "Largest First" and filter by "Videos" — grid updates instantly. |
| 5 | **Swipe Review: Keep** | Swipe card right — green "KEEP" badge shows, item moves to Kept list. |
| 6 | **Swipe Review: Delete** | Swipe card left — red "DELETE" badge shows, item moves to Pending Deletion. |
| 7 | **Undo Action** | Tap the Undo button — most recent reviewed item returns to the queue. |
| 8 | **Pending Deletion Screen** | Badge shows pending count; screen displays thumbnails and total reclaimable size. |
| 9 | **Deselection Safety** | Uncheck an item — reclaimable size decreases, item remains on device. |
| 10 | **Deletion Confirmation** | Tap "Delete Selected" — modal dialog shows count, size, and system safety warning. |
| 11 | **Platform Deletion** | Confirm deletion — Android MediaStore dialog prompts user. On cancel, file is preserved; on approval, file is deleted and state updates. |
| 12 | **Theme Switching** | Open Settings -> Theme -> Switch to *Sage*, *Ocean*, or *Graphite* — whole UI adapts immediately. |
| 13 | **System Mode** | Select System mode — app follows OS light/dark appearance. |
| 14 | **Review Session Reset** | Tap "Reset Review Progress" in Settings — clears markings safely without deleting files. |
