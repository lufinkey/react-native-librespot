#import "LibrespotModule.h"
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "Librespot-Swift.h"

@interface LibrespotModule(Librespot_LibrespotPlayerEventListener) <LibrespotPlayerEventListener>
@end

@implementation LibrespotModule {
	Librespot* _module;
	BOOL _storeCredentials;
}
RCT_EXPORT_MODULE()

-(id)init {
	NSLog(@"Librespot init");
	if(self = [super init]) {
		_storeCredentials = YES;
	}
	return self;
}

-(void)doAThing {
	NSLog(@"We called a native function!!");
}

-(void)initialize:(JS::NativeLibrespot::SpecInitializeOptions&)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
	if(_module != nil) {
		reject(@"Librespot.AlreadyInitialized", @"Module is already initialized", nil);
		return;
	}
	NSString* clientID = options.clientID();
	if(clientID == nil) {
		reject(@"Librespot.MissingOption", @"Missing clientID", nil);
		return;
	}
	facebook::react::LazyVector<NSString*> scopesArr = options.scopes();
	NSMutableArray* scopes = [NSMutableArray array];
	for(NSString* scope : scopesArr) {
		[scopes addObject:scope];
	}
	NSURL* redirectURL = [NSURL URLWithString:options.redirectURL()];
	if(redirectURL == nil) {
		reject(@"Librespot.MissingOption", @"Missing redirectURL", nil);
		return;
	}
	_module = [[Librespot alloc]
		initWithClientID: clientID
		scopes: scopes
		redirectURL: redirectURL
		tokenSwapURL: [NSURL URLWithString:options.tokenSwapURL()]
		tokenRefreshURL: [NSURL URLWithString:options.tokenRefreshURL()]
		tokenRefreshEarliness: options.tokenRefreshEarliness().value_or([LibrespotAuth DefaultTokenRefreshEarliness])
		loginUserAgent: options.loginUserAgent()
		params: @{@"show_dialog": @"true"}
		sessionUserDefaultsKey: options.sessionStorageKey()];
	resolve(@YES);
}

-(void)login:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
	if(_module == nil) {
		reject(@"Librespot.NotInitialized", @"Module is not initialized", nil);
		return;
	}
	[_module loginWithCompletionHandler:^(LibrespotSession* session, NSError* error) {
		if(error != nil) {
			reject([LibrespotUtils kindOfError:error], error.localizedDescription, error);
		} else {
			resolve(@(session != nil));
		}
	}];
}

-(void)loginWithUsernamePassword:(NSString*)username password:(NSString*)password resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
	if(_module == nil) {
		reject(@"Librespot.NotInitialized", @"Module is not initialized", nil);
		return;
	}
	reject(@"NotImplemented", @"I haven't done this yet", nil);
}

-(void)loginWithSession:(JS::NativeLibrespot::LibrespotSession&)sessionObj resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
	if(_module == nil) {
		reject(@"Librespot.NotInitialized", @"Module is not initialized", nil);
		return;
	}
	facebook::react::LazyVector<NSString*> scopesArr = sessionObj.scopes();
	NSMutableArray* scopes = [NSMutableArray array];
	for(NSString* scope : scopesArr) {
		[scopes addObject:scope];
	}
	LibrespotSession* session = [[LibrespotSession alloc]
		initWithClientID: sessionObj.clientID()
		accessToken: sessionObj.accessToken()
		expireDate: [NSDate dateWithTimeIntervalSince1970:sessionObj.expireTime() / 1000.0]
		refreshToken: sessionObj.refreshToken()
		scopes: scopes];
	[_module loginWithSession:session completionHandler:^(NSError* error) {
		if(error != nil) {
			reject([LibrespotUtils kindOfError:error], error.localizedDescription, error);
		} else {
			resolve(nil);
		}
	}];
}

-(void)logout {
	[_module logout];
}

-(void)initPlayer {
	[_module initPlayer:self];
}

-(void)deinitPlayer {
	[_module deinitPlayer];
}

-(void)loadTrack:(NSString*)trackURI startPlaying:(BOOL)startPlaying {
	[_module loadTrackURI:trackURI startPlaying:startPlaying position:0];
}

-(void)preloadTrack:(NSString*)trackURI {
	[_module preloadTrackURI:trackURI];
}

-(void)pause {
	[_module pause];
}

-(void)play {
	[_module play];
}

-(void)seek:(double)positionMs {
	[_module seekTo:(NSUInteger)positionMs];
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
	return @{};
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
	(const facebook::react::ObjCTurboModule::InitParams &)params
{
	return std::make_shared<facebook::react::NativeLibrespotSpecJSI>(params);
}

@end
