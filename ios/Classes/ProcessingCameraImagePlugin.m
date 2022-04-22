#import "ProcessingCameraImagePlugin.h"
#if __has_include(<processing_camera_image/processing_camera_image-Swift.h>)
#import <processing_camera_image/processing_camera_image-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "processing_camera_image-Swift.h"
#endif

@implementation ProcessingCameraImagePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftProcessingCameraImagePlugin registerWithRegistrar:registrar];
}
@end
