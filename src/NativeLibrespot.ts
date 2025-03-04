import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';
import type { EventEmitter } from 'react-native/Libraries/Types/CodegenTypes';

export interface Spec extends TurboModule {
	doAThing(): void;

	login(accessToken: string, storeCredentials: boolean): Promise<void>;
	logout(): void;

	player_init(): void;
	player_deinit(): void;
	player_pause(): void;
	player_play(): void;
	player_stop(): void;
	player_seek(position: number): void;

	onEventPlaying: EventEmitter<{
		play_request_id: number;
		track_id: string;
		position: number;
	}>;

	onEventPaused: EventEmitter<{
		play_request_id: number;
		track_id: string;
		position: number;
	}>;

	onEventStopped: EventEmitter<{
		play_request_id: number;
		track_id: string;
	}>;

	onEventSeeked: EventEmitter<{
		play_request_id: number;
		track_id: string;
		position: number;
	}>;

	onEventLoading: EventEmitter<{
		play_request_id: number;
		track_id: string;
		position: number;
	}>;

	onEventPreloading: EventEmitter<{
		track_id: string;
	}>;

	onEventTimeToPreloadNextTrack: EventEmitter<{
		play_request_id: number;
		track_id: string;
	}>;

	onEventEndOfTrack: EventEmitter<{
		play_request_id: number;
		track_id: string;
	}>;

	onEventVolumeChanged: EventEmitter<{
		volume: number;
	}>;

	onEventPositionCorrection: EventEmitter<{
		play_request_id: number;
		track_id: string;
		position: number;
	}>;

	onEventTrackChanged: EventEmitter<{
		track_id: string;
		duration: number;
	}>;

	onEventShuffleChanged: EventEmitter<{
		shuffle: boolean;
	}>;

	onEventRepeatChanged: EventEmitter<{
		context: string;
		track: string;
	}>;

	onEventAutoPlayChanged: EventEmitter<{
		auto_play: boolean;
	}>;

	onEventFilterExplicitContentChanged: EventEmitter<{
		filter: boolean;
	}>;

	onEventPlayRequestIdChanged: EventEmitter<{
		play_request_id: number;
	}>;

	onEventSessionConnected: EventEmitter<{
		connection_id: string;
		user_name: string;
	}>;

	onEventSessionDisconnected: EventEmitter<{
		connection_id: string;
		user_name: string;
	}>;

	onEventSessionClientChanged: EventEmitter<{
		client_id: string;
		client_name: string;
		client_brand_name: string;
		client_model_name: string;
	}>;

	onEventUnavailable: EventEmitter<{
		play_request_id: number;
		track_id: string;
	}>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Librespot');
