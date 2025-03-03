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

-(void)doAThing {
	NSLog(@"We called a native function!!");
	[_module doAThing];
}

-(void)login:(NSString*)accessToken resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
	[_module loginWithAccessToken:accessToken completionHandler:^(NSError* error) {
		if(error != nil) {
			reject([NSString stringWithFormat:@"SpotifyError:%i", error.code], error.description, error);
		} else {
			resolve(nil);
		}
	}];
}

-(void)player_init {
	[_module player_init];
}

-(void)player_deinit {
	[_module player_deinit];
}

-(void)player_load:(NSString*)trackID startPlaying:(BOOL)startPlaying position:(double)position {
	[_module player_loadTrackID:trackID startPlaying:startPlaying position:(NSUInteger)position];
}

-(void)player_preload:(NSString*)trackID {
	[_module player_preloadTrackID:trackID];
}

-(void)player_pause {
	[_module player_pause];
}

-(void)player_play {
	[_module player_play];
}

-(void)player_stop {
	[_module player_stop];
}

-(void)player_seek:(double)positionMs {
	[_module player_seekTo:(NSUInteger)positionMs];
}

-(NSDictionary*)constantsToExport {
	return [_module constantsToExport];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
	(const facebook::react::ObjCTurboModule::InitParams &)params
{
	return std::make_shared<facebook::react::NativeLibrespotSpecJSI>(params);
}

@end
