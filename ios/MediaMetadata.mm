#import "MediaMetadata.h"
#import <AVFoundation/AVFoundation.h>
#import <React/RCTLog.h>

@implementation MediaMetadata

// Expose the module to React Native
RCT_EXPORT_MODULE()

// Method to retrieve media metadata
RCT_EXPORT_METHOD(get:(NSString *)path
                  options:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    // Ensure the file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    
    // Check if the file exists and it's not a directory
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir] || isDir) {
        NSError *error = [NSError errorWithDomain:@"com.media.metadata" code:-15 userInfo:nil];
        reject(@"FILE_NOT_FOUND", @"The file does not exist or is a directory.", error);
        return;
    }
    
    // Set options for the AVURLAsset
    NSDictionary *assetOptions = @{AVURLAssetPreferPreciseDurationAndTimingKey: @YES};
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:assetOptions];
    NSArray *keys = @[@"commonMetadata"];
    
    // Asynchronously load the metadata
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSMutableDictionary *result = [NSMutableDictionary new];
        
        // Extract metadata from the asset
        NSArray *metadataKeys = @[
            @"albumName", @"artist", @"comment", @"copyrights", @"creationDate", 
            @"date", @"encodedby", @"genre", @"language", @"location", 
            @"lastModifiedDate", @"performer", @"publisher", @"title"
        ];
        
        for (NSString *key in metadataKeys) {
            NSArray *items = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                         withKey:key
                                                        keySpace:AVMetadataKeySpaceCommon];
            for (AVMetadataItem *item in items) {
                if (item.value) {
                    result[key] = item.value;
                }
            }
        }
        
        // Extract thumbnail if requested
        if (options[@"getThumb"]) {
            UIImage *thumbnail = [self getArtworkThumbnailFromAsset:asset];
            if (thumbnail) {
                [result setObject:@(thumbnail.size.width) forKey:@"width"];
                [result setObject:@(thumbnail.size.height) forKey:@"height"];
                NSString *data = [UIImagePNGRepresentation(thumbnail) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                [result setObject:data forKey:@"thumb"];
            }
            
            // Retrieve a video frame thumbnail
            UIImage *videoThumbnail = [self getVideoFrameThumbnailFromAsset:asset];
            if (videoThumbnail) {
                [result setObject:@(videoThumbnail.size.width) forKey:@"width"];
                [result setObject:@(videoThumbnail.size.height) forKey:@"height"];
                NSString *data = [UIImagePNGRepresentation(videoThumbnail) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                [result setObject:data forKey:@"thumb"];
                [result setObject:@(CMTimeGetSeconds(asset.duration) * 1000) forKey:@"duration"];
            }
        }
        
        resolve(result);
    }];
}

// Helper function to get artwork thumbnail from metadata
- (UIImage *)getArtworkThumbnailFromAsset:(AVURLAsset *)asset
{
    NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                      withKey:AVMetadataCommonKeyArtwork
                                                     keySpace:AVMetadataKeySpaceCommon];
    for (AVMetadataItem *item in artworks) {
        if (item.value) {
            NSData *imageData = (NSData *)item.value;
            return [UIImage imageWithData:imageData];
        }
    }
    return nil;
}

// Helper function to get a video frame thumbnail
- (UIImage *)getVideoFrameThumbnailFromAsset:(AVURLAsset *)asset
{
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    // Get the midpoint of the video
    CMTime duration = asset.duration;
    CMTime time = CMTimeMake(duration.value / 2, duration.timescale);
    
    NSError *error = nil;
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
    if (error) {
        RCTLogError(@"Error generating video frame thumbnail: %@", error.localizedDescription);
        return nil;
    }
    
    return [UIImage imageWithCGImage:cgImage];
}

// Optional TurboModule method to integrate with JSI (JavaScript Interface)
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeMediaMetadataSpecJSI>(params);
}

@end
