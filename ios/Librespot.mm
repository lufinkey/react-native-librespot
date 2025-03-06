#import "Librespot.h"
#import <Foundation/Foundation.h>
#import "Librespot-Swift.h"

@interface Librespot(Librespot_LibrespotPlayerEventListener) <LibrespotPlayerEventListener>
@end

@implementation Librespot {
	LibrespotWrapper* _module;
}
RCT_EXPORT_MODULE()

-(id)init {
	NSLog(@"Librespot init");
	if(self = [super init]) {
		_module = [LibrespotWrapper new];
	}
	return self;
}

-(void)doAThing {
	NSLog(@"We called a native function!!");
	[_module doAThing];
}

-(void)login:(NSString*)accessToken storeCredentials:(BOOL)storeCredentials resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  [_module loginWithAccessToken:accessToken storeCredentials:storeCredentials completionHandler:^(NSError* error) {
		if(error != nil) {
			reject([NSString stringWithFormat:@"SpotifyError:%li", error.code], error.description, error);
		} else {
			resolve(nil);
		}
	}];
}

-(void)logout {
	[_module logout];
}

-(void)initPlayer {
	[_module player_init:self];
}

-(void)deinitPlayer {
	[_module player_deinit];
}

-(void)loadTrack:(NSString*)trackID startPlaying:(BOOL)startPlaying {
	[_module player_loadTrackID:trackID startPlaying:startPlaying position:0];
}

-(void)preloadTrack:(NSString*)trackID {
	[_module player_preloadTrackID:trackID];
}

-(void)pause {
	[_module player_pause];
}

-(void)play {
	[_module player_play];
}

-(void)seek:(double)positionMs {
	[_module player_seekTo:(NSUInteger)positionMs];
}

// TODO add context changed

- (void)onEventPlaying:(NSDictionary<NSString*,id>*)data {
	[self emitOnPlaying:data];
}

- (void)onEventPaused:(NSDictionary<NSString*,id>*)data {
	[self emitOnPaused:data];
}

- (void)onEventStopped:(NSDictionary<NSString*,id>*)data {
	[self emitOnStopped:data];
}

- (void)onEventSeeked:(NSDictionary<NSString*,id>*)data {
	[self emitOnSeeked:data];
}

- (void)onEventLoading:(NSDictionary<NSString*,id>*)data {
	[self emitOnLoading:data];
}

- (void)onEventPreloading:(NSDictionary<NSString*,id>*)data {
	// TODO implement cross platform
	//[self emitOnPreloading:data];
}

- (void)onEventTimeToPreloadNextTrack:(NSDictionary<NSString*,id>*)data {
	// TODO implement cross platform
	//[self emitOnTimeToPreloadNextTrack:data];
}

- (void)onEventEndOfTrack:(NSDictionary<NSString*,id>*)data {
	[self emitOnEndOfTrack:data];
}

- (void)onEventVolumeChanged:(NSDictionary<NSString*,id>*)data {
	// TODO implement cross platform
	//[self emitOnVolumeChanged:data];
}

- (void)onEventPositionCorrection:(NSDictionary<NSString*,id>*)data {
	// TODO implement cross platform
	//[self emitOnPositionCorrection:data];
}

- (void)onEventTrackChanged:(NSDictionary<NSString*,id>*)data {
	[self emitOnTrackChanged:data];
}

- (void)onEventShuffleChanged:(NSDictionary<NSString*,id>*)data {
	// TODO implement cross platform
	//[self emitOnShuffleChanged:data];
}

- (void)onEventRepeatChanged:(NSDictionary<NSString*,id>*)data {
	// TODO implement cross platform
	//[self emitOnRepeatChanged:data];
}

- (void)onEventAutoPlayChanged:(NSDictionary<NSString*,id>*)data {
	// TODO implement cross platform
	//[self emitOnAutoPlayChanged:data];
}

- (void)onEventFilterExplicitContentChanged:(NSDictionary<NSString*,id>*)data {
	// TODO implement cross platform
	//[self emitOnFilterExplicitContentChanged:data];
}

- (void)onEventPlayRequestIdChanged:(NSDictionary<NSString*,id>*)data {
	// TODO implement cross platform
	//[self emitOnPlayRequestIdChanged:data];
}

- (void)onEventSessionConnected:(NSDictionary<NSString*,id>*)data {
	// TODO implement cross platform
	//[self emitOnSessionConnected:data];
}

- (void)onEventSessionDisconnected:(NSDictionary<NSString*,id>*)data {
	// TODO implement cross platform
	//[self emitOnSessionDisconnected:data];
}

- (void)onEventSessionClientChanged:(NSDictionary<NSString*,id>*)data {
	// TODO implement cross platform
	//[self emitOnSessionClientChanged:data];
}

- (void)onEventPlaybackFailed:(NSDictionary<NSString*,id>*)data {
	[self emitOnPlaybackFailed:data];
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
