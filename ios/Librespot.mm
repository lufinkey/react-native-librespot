#import "Librespot.h"
#import <Foundation/Foundation.h>
#import "Librespot-Swift.h"

@implementation Librespot {
	LibrespotModule* _module;
}
RCT_EXPORT_MODULE()

-(id)init {
  NSLog(@"Librespot init");
  if(self = [super init]) {
    _module = [LibrespotModule new];
  }
  return self;
}

- (void)doAThing {
	NSLog(@"We called a native function!!");
  [_module doAThing];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
	(const facebook::react::ObjCTurboModule::InitParams &)params
{
	return std::make_shared<facebook::react::NativeLibrespotSpecJSI>(params);
}

@end
