import { useState } from 'react';
import { View, Text, Button } from 'react-native';
import type { Spec } from './index';
import MediaMetadata from './index';

export default function App() {
  const [metadata, setMetadata] = useState<
    Awaited<
      ReturnType<Spec['get']>
    > | null
  >(null);
  const [error, setError] = useState<string | null>(null);

  // Function to fetch media metadata
  const fetchMediaMetadata = async () => {
    try {
      const result = await MediaMetadata.get('/path/to/media/file', {
        getThumb: true,
      });
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
