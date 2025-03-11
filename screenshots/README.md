# Screenshot Guidelines

This directory should contain screenshots of your Heart Rate Monitor app. For a complete representation in the README, consider taking the following screenshots:

## Required Screenshots

1. **Normal Heart Rate** (`normal_heart_rate.png`)
   - Show the app displaying a heart rate in the normal range (60-100 BPM)
   - Heart rate should be visible with green color indicators
   - Device connection should show good signal strength

2. **Elevated Heart Rate** (`elevated_heart_rate.png`)
   - Show the app displaying a heart rate in the elevated range (100-120 BPM)
   - Heart rate should have yellow/orange color indicators
   - Include any warnings or notifications that appear

3. **Low Heart Rate** (`low_heart_rate.png`)
   - Show the app displaying a heart rate below normal (<60 BPM)
   - Heart rate should have blue color indicators
   - Include any warnings or notifications that appear

4. **Device Connection** (`device_connection.png`)
   - Show the device information panel
   - Include battery level, signal strength, and device name
   - Ideally show a recently connected or connecting state

## Recommended Additional Screenshots

5. **High/Critical Heart Rate** (`critical_heart_rate.png`)
   - Show the app displaying a heart rate in the critical range (>140 BPM)
   - Heart rate should have red color indicators
   - Include any warnings or emergency notifications

6. **Settings Screen** (`settings_screen.png`)
   - If your app has settings or preferences, capture this screen

7. **History View** (`history_view.png`)
   - If your app shows history or trends, capture this screen

## How to Take Good Screenshots

1. **Device**: Use a real device or emulator with a clean status bar (full battery, no notifications)
2. **Time**: Set the device time to a clean number like 9:00 AM
3. **Resolution**: Use high-resolution screenshots (minimum 1080×1920)
4. **Orientation**: Take screenshots in portrait mode
5. **Content**: Make sure to display realistic data that represents the feature
6. **Consistency**: Use the same device/emulator for all screenshots for a consistent look

## How to Take Screenshots

### On Android Emulator/Device:
- Press `Volume Down + Power` simultaneously
- Or run `adb shell screencap -p /sdcard/screenshot.png && adb pull /sdcard/screenshot.png`

### On iOS Simulator/Device:
- Press `Command + S` on Simulator
- Press `Home + Power` (or `Volume Up + Power` on newer devices)

### From Flutter:
```dart
// Add screenshot package to pubspec.yaml
// dependencies:
//   screenshot: ^latest_version

final screenshotController = ScreenshotController();
// In your widget:
Screenshot(
  controller: screenshotController,
  child: YourWidget(),
)

// Take screenshot programmatically:
screenshotController.capture().then((image) {
  // Save or share the image
});
``` 