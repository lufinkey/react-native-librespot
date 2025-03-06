import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';
import type { EventEmitter } from 'react-native/Libraries/Types/CodegenTypes';

export interface Spec extends TurboModule {
	doAThing(): void;

	login(accessToken: string, storeCredentials: boolean): Promise<void>;
	logout(): void;

	initPlayer(): void;
	deinitPlayer(): void;
	loadTrack(trackId: string, startPlaying: boolean): void;
	pause(): void;
	play(): void;
	seek(position: number): void;

	onPlaying: EventEmitter<{
		//play_request_id: number;
		track_uri: string,
		position: number,
	}>;

	onPaused: EventEmitter<{
		//play_request_id: number;
		track_uri: string,
		position: number,
	}>;

	onStopped: EventEmitter<{
		//play_request_id: number;
		track_uri: string,
	}>;

	onSeeked: EventEmitter<{
		//play_request_id: number;
		track_uri: string,
		position: number,
	}>;

	onLoading: EventEmitter<{
		//play_request_id: number;
		track_uri: string,
		position: number,
	}>;

	onEndOfTrack: EventEmitter<{
		//play_request_id: number,
		track_uri: string,
	}>;

	onTrackChanged: EventEmitter<{
		track_uri: string,
		duration: number,
	}>;

	onPlaybackFailed: EventEmitter<{
		//play_request_id: number,
		track_uri: string,
		reason: string,
	}>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Librespot');
