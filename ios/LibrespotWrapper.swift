
@objc
public class LibrespotWrapper: NSObject {
	
	private var core: LibrespotCore;
	private var eventReceiver: LibrespotPlayerEventReceiver? = nil;
  
	@objc
	public override init() {
    let fileManager = FileManager.default;
		let credentialsPath = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)
      .first?.appendingPathComponent("Preferences/librespot_session").absoluteString;
		let audioCachePath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
      .first?.appendingPathComponent("librespot_audio_cache").absoluteString;
		
		self.core = LibrespotCore(
      credentialsPath,
      audioCachePath);
		super.init()
	}

	@objc public func doAThing() -> Void {
		NSLog("We're calling a swift function!!!!");
	}

	@objc public func login(accessToken: String, storeCredentials: Bool) async throws {
		try await core.login(accessToken, storeCredentials);
	}

	@objc public func logout() {
		core.logout();
	}

	@objc(player_init:)
	public func player_init(_ listener: LibrespotPlayerEventListener) {
		let initted = core.player_init();
		if(!initted) {
			return;
		}
		let evtReceiver = LibrespotPlayerEventReceiver(self.core, listener);
		self.eventReceiver = evtReceiver;
		Task {
			await evtReceiver.pollEvents();
		}
	}

	@objc public func player_deinit() {
		self.eventReceiver?.dispose();
		self.eventReceiver = nil;
		core.player_deinit();
	}

	@objc(player_loadTrackID:startPlaying:position:)
	public func player_load(track_uri: String, start_playing: Bool, position_ms: UInt32) {
		core.player_load(track_uri,start_playing,position_ms);
	}

	@objc(player_preloadTrackID:)
	public func player_preload(track_uri: String) {
		core.player_preload(track_uri);
	}

	@objc public func player_stop() {
		core.player_stop();
	}

	@objc public func player_play() {
		core.player_play();
	}

	@objc public func player_pause() {
		core.player_pause();
	}

	@objc(player_seekTo:)
	public func player_seek(position_ms: UInt32) {
		core.player_seek(position_ms);
	}

	@objc
	public func constantsToExport() -> [String: Any]! {
		return [:];
	}
}
