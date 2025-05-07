# react-native-media-metadata

`react-native-media-metadata` is a powerful React Native module for extracting metadata and thumbnails from audio and video files. It supports retrieving essential metadata such as album name, artist, genre, creation date, and more. Additionally, it allows you to fetch video frame and artwork thumbnails.

### Features:
- Extract metadata from audio and video files.
- Supports the following metadata fields:
  - Album Name
  - Artist
  - Genre
  - Title
  - Comment
  - Copyrights
  - And more...
- Extracts embedded artwork as base64 images.
- Extracts video frame thumbnails (optional).
- Built with React Native's TurboModules for better performance.
- Works on both iOS and Android.

## Installation

To install `react-native-media-metadata` in your React Native project:

```sh
npm install react-native-media-metadata
```

For iOS, run the following command to install CocoaPods dependencies:

```sh
cd ios && pod install
```

## Usage

Once installed, you can use the module to extract metadata and thumbnails from media files.

Example Usage in JavaScript (React Native):
```javascript
import React, { useState } from 'react';
import { View, Text, Button } from 'react-native';
import MediaMetadata from 'react-native-media-metadata';

export default function App() {
  const [metadata, setMetadata] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);

  // Function to fetch media metadata
  const fetchMediaMetadata = async () => {
    try {
      const result = await MediaMetadata.get('/path/to/media/file', { getThumb: true });
      setMetadata(result);
      console.log('Media Metadata:', result);
    } catch (err) {
      setError('Error fetching media metadata');
      console.error(err);
    }
  };

  return (
    <View>
      <Button title="Fetch Media Metadata" onPress={fetchMediaMetadata} />
      {error && <Text>{error}</Text>}
      {metadata && (
        <View>
          <Text>Title: {metadata.title}</Text>
          <Text>Artist: {metadata.artist}</Text>
          <Text>Album: {metadata.album}</Text>
          <Text>Genre: {metadata.genre}</Text>
          {metadata.thumb && <Text>Thumbnail: {metadata.thumb}</Text>}
        </View>
      )}
    </View>
  );
}
```

## Available Methods

### `get(path: string, options: { getThumb?: boolean }): Promise<Metadata>`

Fetches metadata from the media file located at the given path. Optionally, you can request to retrieve the embedded thumbnail using the getThumb option.

#### Arguments:

- `path` (string): The path to the media file (e.g., audio or video file).
- `options` (object): Options to control metadata retrieval:
  - `getThumb` (boolean): Set to true to retrieve the thumbnail (embedded artwork or video frame).

#### Returns:

A promise that resolves with a Metadata object, which may include:
- album (string)
- artist (string)
- comment (string)
- copyright (string)
- creation_time (string)
- date (string)
- encoded_by (string)
- genre (string)
- language (string)
- location (string)
- last_modified (string)
- performer (string)
- publisher (string)
- title (string)
- thumb (string): The thumbnail image encoded as a base64 string (optional, based on getThumb flag).
- duration (number): Duration of the video in milliseconds (if a video).

#### Example Response:
```json
{
  "title": "Song Title",
  "artist": "Artist Name",
  "album": "Album Name",
  "genre": "Rock",
  "thumb": "<base64_string>",
  "width": 120,
  "height": 80,
  "duration": 180000
}
```

## Setup for Native Platforms

### iOS Setup
1. Open the iOS project in Xcode (ios/YourAppName.xcworkspace).
2. In your terminal, run the following command to install CocoaPods dependencies:
   ```sh
   cd ios && pod install
   ```
3. If you haven't already, make sure your project supports Swift, as this module is built using Swift for performance.

### Android Setup
1. Open the `android/settings.gradle` file and include the native module:
   ```gradle
   include ':native-modules'
   project(':native-modules').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-media-metadata')
   ```
2. In the `android/app/src/main/java/com/yourapp/MainApplication.java`, register the package:
   ```java
   import com.mediametadata.MediaMetadataPackage; // Import the native module

   @Override
   protected List<ReactPackage> getPackages() {
     return Arrays.<ReactPackage>asList(
         new MainReactPackage(),
         new MediaMetadataPackage() // Add this line to register the native module
     );
   }
   ```
3. Rebuild your app for Android:
   ```sh
   npx react-native run-android
   ```

## Troubleshooting

### iOS Issues
- Ensure that your iOS project is set up to support Swift if you're using Swift for the iOS implementation.
- If you encounter issues with pod dependencies, run `pod install` in the ios directory again.

### Android Issues
- Ensure that the `settings.gradle` and `MainApplication.java` are correctly configured.
- If you experience build issues on Android, try cleaning the build and rebuilding:
  ```sh
  cd android && ./gradlew clean
  npx react-native run-android
  ```

## Contributing

See the contributing guide to learn how to contribute to the repository and the development workflow.

## License

MIT License. See LICENSE for more details.
