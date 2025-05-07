import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  // Method to get media metadata from a file
  get(
    path: string,
    options: { getThumb?: boolean } // Option to fetch thumbnail
  ): Promise<{
    album?: string;
    artist?: string;
    comment?: string;
    copyright?: string;
    creation_time?: string;
    date?: string;
    encoded_by?: string;
    genre?: string;
    language?: string;
    location?: string;
    last_modified?: string;
    performer?: string;
    publisher?: string;
    title?: string;
    thumb?: string; // base64 encoded thumbnail
  }>;
}

export interface MediaMetadataOptions {
  getThumb?: boolean;
}

const MediaMetadata = TurboModuleRegistry.getEnforcing<Spec>('MediaMetadata');

export default MediaMetadata;
