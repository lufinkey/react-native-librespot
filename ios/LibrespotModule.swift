
@objc
public class LibrespotModule: NSObject {
	enum PlayerEventType: String, CaseIterable {
		case playing = "Playing"
		case paused = "Paused"
		case stopped = "Stopped"
		case loading = "Loading"
		case preloading = "Preloading"
		case timeToPreloadNextTrack = "TimeToPreloadNextTrack"
		case endOfTrack = "EndOfTrack"
		case unavailable = "Unavailable"
		case volumeChanged = "VolumeChanged"
		case positionCorrection = "PositionCorrection"
		case seeked = "Seeked"
		case trackChanged = "TrackChanged"
		case sessionConnected = "SessionConnected"
		case sessionDisconnected = "SessionDisconnected"
		case sessionClientChanged = "SessionClientChanged"
		case shuffleChanged = "ShuffleChanged"
		case repeatChanged = "RepeatChanged"
		case autoPlayChanged = "AutoPlayChanged"
		case filterExplicitContentChanged = "FilterExplicitContentChanged"
		case playRequestIdChanged = "PlayRequestIdChanged"
	}

	private var core: LibrespotCore
  
	public override init() {
		self.core = LibrespotCore()
		super.init()
	}

	@objc public func doAThing() -> Void {
		NSLog("We're calling a swift function!!!!");
	}

	@objc public func login(accessToken: String) async throws {
		try await core.login(accessToken);
	}

	@objc public func player_init() {
		core.player_init();
	}

	@objc public func player_deinit() {
		core.player_deinit();
	}

	@objc public func player_getEvent() async -> [String:Any] {
		let evtResult = await core.player_get_event();
		switch evtResult.event {
		case .Playing(let playRequestId, let trackId, let position):
			return [
				"type": PlayerEventType.playing.rawValue,
				"play_request_id": Double(playRequestId),
				"track_id": trackId.toString(),
				"position": Double(position)
			]
		case .Paused(let playRequestId, let trackId, let positionMs):
			return [
				"type": PlayerEventType.paused.rawValue,
				"play_request_id": Double(playRequestId),
				"track_id": trackId.toString(),
				"position": Double(positionMs)
			]
		case .Stopped(let playRequestId, let trackId):
			return [
				"type": PlayerEventType.stopped.rawValue,
				"play_request_id": Double(playRequestId),
				"track_id": trackId.toString()
			]
		case .Loading(let playRequestId, let trackId, let positionMs):
			return [
				"type": PlayerEventType.loading.rawValue,
				"play_request_id": Double(playRequestId),
				"track_id": trackId.toString(),
				"position": Double(positionMs)
			]
		case .Preloading(let trackId):
			return [
				"type": PlayerEventType.preloading.rawValue,
				"track_id": trackId.toString()
			]
		case .TimeToPreloadNextTrack(let playRequestId, let trackId):
			return [
				"type": PlayerEventType.timeToPreloadNextTrack.rawValue,
				"play_request_id": Double(playRequestId),
				"track_id": trackId.toString()
			]
		case .EndOfTrack(let playRequestId, let trackId):
			return [
				"type": PlayerEventType.endOfTrack.rawValue,
				"play_request_id": Double(playRequestId),
				"track_id": trackId.toString()
			]
		case .Unavailable(let playRequestId, let trackId):
			return [
				"type": PlayerEventType.unavailable.rawValue,
				"play_request_id": Double(playRequestId),
				"track_id": trackId.toString()
			]
		case .VolumeChanged(let volume):
			return [
				"type": PlayerEventType.volumeChanged.rawValue,
				"volume": Double(volume)
			]
		case .PositionCorrection(let playRequestId, let trackId, let positionMs):
			return [
				"type": PlayerEventType.positionCorrection.rawValue,
				"play_request_id": Double(playRequestId),
				"track_id": trackId.toString(),
				"position": Double(positionMs)
			]
		case .Seeked(let playRequestId, let trackId, let positionMs):
			return [
				"type": PlayerEventType.seeked.rawValue,
				"play_request_id": Double(playRequestId),
				"track_id": trackId.toString(),
				"position": Double(positionMs)
			]
		case .TrackChanged(let trackId, let durationMs):
			return [
				"type": PlayerEventType.trackChanged.rawValue,
				"track_id": trackId.toString(),
				"duration": Double(durationMs)
			]
		case .SessionConnected(let connectionId, let userName):
			return [
				"type": PlayerEventType.sessionConnected.rawValue,
				"connection_id": connectionId.toString(),
				"user_name": userName.toString()
			]
		case .SessionDisconnected(let connectionId, let userName):
			return [
				"type": PlayerEventType.sessionDisconnected.rawValue,
				"connection_id": connectionId.toString(),
				"user_name": userName.toString()
			]
		case .SessionClientChanged(let clientId, let clientName, let clientBrandName, let clientModelName):
			return [
				"type": PlayerEventType.sessionClientChanged.rawValue,
				"client_id": clientId.toString(),
				"client_name": clientName.toString(),
				"client_brand_name": clientBrandName.toString(),
				"client_model_name": clientModelName.toString()
			]
		case .ShuffleChanged(let shuffle):
			return [
				"type": PlayerEventType.shuffleChanged.rawValue,
				"shuffle": shuffle
			]
		case .RepeatChanged(let context, let track):
			return [
				"type": PlayerEventType.repeatChanged.rawValue,
				"context": context,
				"track": track
			]
		case .AutoPlayChanged(let autoPlay):
			return [
				"type": PlayerEventType.autoPlayChanged.rawValue,
				"auto_play": autoPlay
			]
		case .FilterExplicitContentChanged(let filter):
			return [
				"type": PlayerEventType.filterExplicitContentChanged.rawValue,
				"filter": filter
			]
		case .PlayRequestIdChanged(let playRequestId):
			return [
				"type": PlayerEventType.playRequestIdChanged.rawValue,
				"play_request_id": Double(playRequestId)
			]
		}
	}

	@objc(player_loadTrackID:startPlaying:position:)
	public func player_load(track_id: String, start_playing: Bool, position_ms: UInt32) {
		core.player_load(track_id,start_playing,position_ms);
	}

	@objc(player_preloadTrackID:)
	public func player_preload(track_id: String) {
		core.player_preload(track_id);
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
		var playerEventTypes: [String:String] = [:];
		for eventType in PlayerEventType.allCases {
			let eventTypeString = eventType.rawValue;
			playerEventTypes[eventTypeString] = eventTypeString;
		}
		return [
			"eventTypes": playerEventTypes
		];
	}
}
