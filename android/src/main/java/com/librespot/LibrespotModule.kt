package com.librespot

import android.R.attr
import android.content.Context
import android.util.Log
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import com.spotify.connectstate.Connect
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import xyz.gianlu.librespot.android.sink.AndroidSinkOutput
import xyz.gianlu.librespot.audio.MetadataWrapper
import xyz.gianlu.librespot.core.Session
import xyz.gianlu.librespot.metadata.PlayableId
import xyz.gianlu.librespot.player.Player
import xyz.gianlu.librespot.player.PlayerConfiguration
import java.io.File
import java.io.IOException
import java.lang.ref.WeakReference
import java.util.Locale


@ReactModule(name = LibrespotModule.NAME)
class LibrespotModule(reactContext: ReactApplicationContext) :
	NativeLibrespotSpec(reactContext), Player.EventsListener {

	@Volatile
	private var session: WeakReference<Session>
	private var storeCredentials: Boolean

	@Volatile
	private var player: WeakReference<Player>? = null

	private var shuffle: Boolean = false

	init {
		val sharedPrefs = reactContext.getSharedPreferences("librespot", Context.MODE_PRIVATE)
		this.shuffle = sharedPrefs.getBoolean("shuffle", false)
		this.storeCredentials = true
		this.session = WeakReference(createInitialSession(reactContext, this.storeCredentials))
	}


	override fun getName(): String {
		return NAME
	}

	// Example method
	// See https://reactnative.dev/docs/native-modules-android
	override fun doAThing() {
		Log.d(NAME, "We called a native function")
	}

	override fun login(promise: Promise) {
		CoroutineScope(Dispatchers.IO).launch {
			try {
				loginAsync()
				promise.resolve(null)
			} catch (e: Exception) {
				promise.reject("SpotifyLoginError", e)
			}
		}
	}

	private suspend fun loginAsync() {
		val session = createSessionWithOAuth(reactApplicationContext, this.storeCredentials);
		loginWithSession(session)
	}

	override fun loginWithUsernamePassword(username: String, password: String, promise: Promise) {
		try {
			val session = createSessionWithUsernamePassword(reactApplicationContext, username, password, this.storeCredentials);
			loginWithSession(session)
			promise.resolve(null)
		} catch(error: Exception) {
			promise.reject(error)
		}
	}

	override fun loginWithAccessToken(accessToken: String, promise: Promise) {
		try {
			val session = createSessionWithAccessToken(reactApplicationContext, accessToken, this.storeCredentials);
			loginWithSession(session)
			promise.resolve(null)
		} catch(error: Exception) {
			promise.reject(error)
		}
	}

	private fun loginWithSession(session: Session) {
		val oldSession = this.session.get();
		val hadPlayer = this.player?.get() != null;
		deinitPlayer();
		if(oldSession != null) {
			Thread {
				try {
					oldSession.close()
				} catch (ignored: IOException) {
				}
			}.start()
		}
		this.session = WeakReference(session)
		this.storeCredentials = storeCredentials
		if(hadPlayer) {
			initPlayer()
		}
	}

	override fun logout() {
		val oldSession = this.session.get()
		val hadPlayer = this.player?.get() != null;
		if(this.storeCredentials) {
			val credentialsFile = getCredentialsFile(reactApplicationContext)
			credentialsFile.delete()
		}
		deinitPlayer()
		if(oldSession != null) {
			Thread {
				try {
					oldSession.close()
				} catch (error: IOException) {
					Log.e(NAME, error.toString())
				}
			}.start()
		}
		this.session = WeakReference(createInitialSession(reactApplicationContext, false))
		if (hadPlayer) {
			initPlayer()
		}
	}

	override fun initPlayer() {
		if (player?.get() != null) {
			Log.e(NAME, "player_init called multiple times")
			return
		}
		val configuration = PlayerConfiguration.Builder()
			.setOutput(PlayerConfiguration.AudioOutput.CUSTOM)
			.setOutputClass(AndroidSinkOutput::class.java.name)
			.build()

		val player = Player(configuration, this.session.get()!!)
		this.player = WeakReference(player)
		player.addEventsListener(this)
	}

	override fun deinitPlayer() {
		val p = this.player?.get();
		if (p != null) {
			p.removeEventsListener(this)
			Thread {
				p.close()
			}.start()
		}
		this.player = null
	}

	override fun loadTrack(trackURI: String, startPlaying: Boolean) {
		val player = this.player?.get()
		if (player != null) {
			player.load(trackURI, startPlaying, this.shuffle);
		} else {
			Log.e(NAME, "player has not been initialized");
		}
	}

	override fun pause() {
		player?.get()?.pause();
	}

	override fun play() {
		player?.get()?.play();
	}

	override fun seek(positionMs: Double) {
		player?.get()?.seek(positionMs.toInt());
	}

	override fun onContextChanged(player: Player, newUri: String) {
		val map = Arguments.createMap()
		map.putString("context_uri", newUri)
		// TODO make this cross platform
		//this.emitOnContextChanged(map)
	}

	override fun onTrackChanged(
		player: Player,
		id: PlayableId,
		metadata: MetadataWrapper?,
		userInitiated: Boolean
	) {
		val map = Arguments.createMap()
		map.putString("track_uri", id.toSpotifyUri())
		val duration = metadata?.duration()
		if (duration != null) {
			map.putInt("duration", duration);
		}
		this.emitOnTrackChanged(map)
	}

	override fun onPlaybackEnded(player: Player) {
		TODO("Not yet implemented")
	}

	override fun onPlaybackPaused(player: Player, trackTime: Long) {
		val map = Arguments.createMap()
		val trackURI = player.currentPlayable()?.toSpotifyUri()
		map.putString("track_uri", trackURI)
		map.putLong("position", trackTime)
		emitOnPaused(map)
	}

	override fun onPlaybackResumed(player: Player, trackTime: Long) {
		val map = Arguments.createMap()
		val trackURI = player.currentPlayable()?.toSpotifyUri()
		map.putString("track_uri", trackURI)
		map.putLong("position", trackTime)
		emitOnPlaying(map)
	}

	override fun onPlaybackFailed(player: Player, e: java.lang.Exception) {
		val map = Arguments.createMap()
		map.putString("track_uri", player.currentPlayable()?.toSpotifyUri())
		map.putString("reason", e.message)
		emitOnPlaybackFailed(map)
	}

	override fun onTrackSeeked(player: Player, trackTime: Long) {
		val map = Arguments.createMap()
		map.putString("track_uri", player.currentPlayable()?.toSpotifyUri())
		map.putLong("position", trackTime)
		emitOnPlaybackFailed(map)
	}

	override fun onMetadataAvailable(player: Player, metadata: MetadataWrapper) {
		TODO("Not yet implemented")
	}

	override fun onPlaybackHaltStateChanged(player: Player, halted: Boolean, trackTime: Long) {
		TODO("Not yet implemented")
	}

	override fun onInactiveSession(player: Player, timeout: Boolean) {
		TODO("Not yet implemented")
	}

	override fun onVolumeChanged(player: Player, volume: Float) {
		TODO("Not yet implemented")
	}

	override fun onPanicState(player: Player) {
		TODO("Not yet implemented")
	}

	override fun onStartedLoading(player: Player) {
		val map = Arguments.createMap()
		val trackURI = player.currentPlayable()?.toSpotifyUri()
		map.putString("track_uri", trackURI)
		val position = player.time()
		map.putInt("position", position)
		emitOnLoading(map)
	}

	override fun onFinishedLoading(player: Player) {
		TODO("Not yet implemented")
	}

	companion object {
		const val NAME = "Librespot"

		fun getCredentialsFile(context: Context): File {
			return File(context.cacheDir, "librespot_credentials.json")
		}

		private data class SessionBuilderTuple(val builder: Session.Builder, val credentialsFile: File)

		private fun createSessionBuilder(context: Context, storeCredentials: Boolean): SessionBuilderTuple {
			val cacheDir = context.cacheDir
			val credentialsFile = getCredentialsFile(context)
			val audioCacheDir = File(cacheDir, "librespot_audio_cache")

			val conf = Session.Configuration.Builder()
				.setStoreCredentials(storeCredentials)
				.setStoredCredentialsFile(credentialsFile)
				.setCacheEnabled(true)
				.setCacheDir(audioCacheDir)
				.build()

			val builder = Session.Builder(conf)
				.setPreferredLocale(Locale.getDefault().language)
				.setDeviceType(Connect.DeviceType.SMARTPHONE)
				.setDeviceId(null).setDeviceName("librespot-android")
			return SessionBuilderTuple(builder,credentialsFile)
		}

		fun createInitialSession(context: Context, storeCredentials: Boolean): Session {
			val (builder,credentialsFile) = createSessionBuilder(context, storeCredentials)
			if(storeCredentials) {
				return builder.stored(credentialsFile).create()
			}
			return builder.create()
		}

		fun createSessionWithAccessToken(context: Context, accessToken: String, storeCredentials: Boolean): Session {
			val (builder,_) = createSessionBuilder(context, storeCredentials)
			return builder.setClientToken(accessToken).create()
		}

		fun createSessionWithUsernamePassword(context: Context, username: String, password: String, storeCredentials: Boolean): Session {
			val (builder,credentialsFile) = createSessionBuilder(context, storeCredentials)
			return builder.userPass(username, password).create()
		}

		suspend fun createSessionWithOAuth(context: Context, storeCredentials: Boolean): Session =
			withContext(Dispatchers.IO) {
			val (builder, _) = createSessionBuilder(context, storeCredentials)
			builder.oauth().create()
		}
	}
}
