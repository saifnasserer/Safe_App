# Android Manifest Configuration for Receipt Scanning

To enable receipt scanning functionality, you need to add the following configurations to your Android manifest file.

## File: android/app/src/main/AndroidManifest.xml

Add these permissions and intent filters:

```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Inside the <application> tag, add intent filters to the main activity -->
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">
    
    <!-- Existing intent filter -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    
    <!-- Add these intent filters for sharing -->
    <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="image/*" />
    </intent-filter>
    
    <intent-filter>
        <action android:name="android.intent.action.SEND_MULTIPLE" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="image/*" />
    </intent-filter>
</activity>
```

## iOS Configuration

For iOS, add these permissions to ios/Runner/Info.plist:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to scan receipts</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select receipt images</string>
```

## Usage Instructions

1. After adding these configurations, run `flutter clean` and `flutter pub get`
2. The app will now be able to receive shared images from other apps
3. Users can share receipt images directly to your Safe app
4. The app will automatically process the shared images using OCR
5. Users can also use the camera or gallery buttons in the manage screen to scan receipts

## Testing

1. Take a photo of a receipt with your phone's camera
2. Share the photo to your Safe app
3. The app should automatically open and process the receipt
4. You can also test by using the camera/gallery buttons in the manage screen



