package com.mediametadata

import android.media.MediaMetadataRetriever
import android.util.Base64
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.turbomodule.core.TurboModule

@ReactModule(name = MediaMetadataModule.NAME)
class MediaMetadataModule(reactContext: ReactApplicationContext) : NativeMediaMetadataSpec(reactContext), TurboModule {

  override fun getName(): String {
    return NAME
  }

  // Method to get metadata from a media file
  @ReactMethod
  fun get(path: String, options: Map<String, Any>?, promise: Promise) {
    try {
      val retriever = MediaMetadataRetriever()
      retriever.setDataSource(path)

      // Extract basic metadata
      val metadata = mutableMapOf<String, Any>()

      val keys = listOf(
        "album", "artist", "comment", "copyright", "creation_time", "date",
        "encoded_by", "genre", "language", "location", "last_modified", "performer", "publisher", "title"
      )

      for (key in keys) {
        val value = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM)
        if (value != null) {
          metadata[key] = value
        }
      }

      // Handle thumbnail extraction if required
      if (options?.get("getThumb") == true) {
        val thumbnailData = retriever.embeddedPicture
        if (thumbnailData != null) {
          val base64Thumbnail = Base64.encodeToString(thumbnailData, Base64.NO_WRAP)
          metadata["thumb"] = base64Thumbnail
          // Optionally include width and height for the thumbnail
          // You can get dimensions using another method if required, like using BitmapFactory
        }
      }

      promise.resolve(metadata)
    } catch (e: Exception) {
      promise.reject("ERROR", "Failed to extract metadata", e)
    }
  }

  companion object {
    const val NAME = "MediaMetadata"
  }
}
