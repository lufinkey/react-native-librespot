
@objc public protocol LibrespotPlayerEventListener {
	func onEventPlaying(_ data: [String:Any]);
	func onEventPaused(_ data: [String:Any]);
	func onEventStopped(_ data: [String:Any]);
	func onEventSeeked(_ data: [String:Any]);
	func onEventLoading(_ data: [String:Any]);
	func onEventPreloading(_ data: [String:Any]);
	func onEventTimeToPreloadNextTrack(_ data: [String:Any]);
	func onEventEndOfTrack(_ data: [String:Any]);
	func onEventVolumeChanged(_ data: [String:Any]);
	func onEventPositionCorrection(_ data: [String:Any]);
	func onEventTrackChanged(_ data: [String:Any]);
	func onEventShuffleChanged(_ data: [String:Any]);
	func onEventRepeatChanged(_ data: [String:Any]);
	func onEventAutoPlayChanged(_ data: [String:Any]);
	func onEventFilterExplicitContentChanged(_ data: [String:Any]);
	func onEventPlayRequestIdChanged(_ data: [String:Any]);
	func onEventSessionConnected(_ data: [String:Any]);
	func onEventSessionDisconnected(_ data: [String:Any]);
	func onEventSessionClientChanged(_ data: [String:Any]);
	func onEventPlaybackFailed(_ data: [String:Any]);
}

class LibrespotPlayerEventReceiver {
	private var disposed: Bool = false;
	private var core: LibrespotCore;
	private var listener: LibrespotPlayerEventListener;

  init(_ core: LibrespotCore, _ listener: LibrespotPlayerEventListener) {
		self.core = core;
		self.listener = listener;
	}

	func dispose() {
		self.disposed = true;
	}
	
	func pollEvents() async {
		while (!self.disposed) {
			guard let evt = await self.core.player_get_event().event else {
				continue;
			}
			switch evt {
			case .Playing(let playRequestId, let trackURI, let position):
				self.listener.onEventPlaying([
					"play_request_id": Double(playRequestId),
					"track_uri": trackURI.toString(),
					"position": Double(position)
				]);
			case .Paused(let playRequestId, let trackURI, let positionMs):
				self.listener.onEventPaused([
					"play_request_id": Double(playRequestId),
					"track_uri": trackURI.toString(),
					"position": Double(positionMs)
				]);
			case .Stopped(let playRequestId, let trackURI):
				self.listener.onEventStopped([
					"play_request_id": Double(playRequestId),
					"track_uri": trackURI.toString()
				]);
			case .Seeked(let playRequestId, let trackURI, let positionMs):
				self.listener.onEventSeeked([
					"play_request_id": Double(playRequestId),
					"track_uri": trackURI.toString(),
					"position": Double(positionMs)
				]);
			case .Loading(let playRequestId, let trackURI, let positionMs):
				self.listener.onEventLoading([
					"play_request_id": Double(playRequestId),
					"track_uri": trackURI.toString(),
					"position": Double(positionMs)
				]);
			case .Preloading(let trackURI):
				self.listener.onEventPreloading([
					"track_uri": trackURI.toString()
				]);
			case .TimeToPreloadNextTrack(let playRequestId, let trackURI):
				self.listener.onEventTimeToPreloadNextTrack([
					"play_request_id": Double(playRequestId),
					"track_uri": trackURI.toString()
				]);
			case .EndOfTrack(let playRequestId, let trackURI):
				self.listener.onEventEndOfTrack([
					"play_request_id": Double(playRequestId),
					"track_uri": trackURI.toString()
				]);
			case .VolumeChanged(let volume):
				self.listener.onEventVolumeChanged([
					"volume": Double(volume)
				]);
			case .PositionCorrection(let playRequestId, let trackURI, let positionMs):
				self.listener.onEventPositionCorrection([
					"play_request_id": Double(playRequestId),
					"track_uri": trackURI.toString(),
					"position": Double(positionMs)
				]);
			case .TrackChanged(let trackURI, let durationMs):
				self.listener.onEventTrackChanged([
					"track_uri": trackURI.toString(),
					"duration": Double(durationMs)
				]);
			case .ShuffleChanged(let shuffle):
				self.listener.onEventShuffleChanged([
					"shuffle": shuffle
				]);
			case .RepeatChanged(let context, let track):
				listener.onEventRepeatChanged([
					"context": context,
					"track": track
				]);
			case .AutoPlayChanged(let autoPlay):
				self.listener.onEventAutoPlayChanged([
					"auto_play": autoPlay
				]);
			case .FilterExplicitContentChanged(let filter):
				self.listener.onEventFilterExplicitContentChanged([
					"filter": filter
				]);
			case .PlayRequestIdChanged(let playRequestId):
				self.listener.onEventPlayRequestIdChanged([
					"play_request_id": Double(playRequestId)
				]);
			case .SessionConnected(let connectionId, let userName):
				self.listener.onEventSessionConnected([
					"connection_id": connectionId.toString(),
					"user_name": userName.toString()
				]);
			case .SessionDisconnected(let connectionId, let userName):
				self.listener.onEventSessionDisconnected([
					"connection_id": connectionId.toString(),
					"user_name": userName.toString()
				]);
			case .SessionClientChanged(let clientId, let clientName, let clientBrandName, let clientModelName):
				self.listener.onEventSessionClientChanged([
					"client_id": clientId.toString(),
					"client_name": clientName.toString(),
					"client_brand_name": clientBrandName.toString(),
					"client_model_name": clientModelName.toString()
				]);
			case .Unavailable(let playRequestId, let trackURI):
				self.listener.onEventPlaybackFailed([
					"play_request_id": Double(playRequestId),
					"track_uri": trackURI.toString(),
					"reason": "Unavailable"
				]);
			}
		}
	}
}
