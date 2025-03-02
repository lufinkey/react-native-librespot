#import "Librespot.h"
#import <Foundation/Foundation.h>

@implementation Librespot
RCT_EXPORT_MODULE()

- (void)doAThing {
	NSLog(@"We called a native function!!");
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
	(const facebook::react::ObjCTurboModule::InitParams &)params
{
	return std::make_shared<facebook::react::NativeLibrespotSpecJSI>(params);
}

@end
