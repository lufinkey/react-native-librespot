package com.librespot

import android.content.Context
import android.util.Log
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Dynamic
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReadableType
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
	private var session: WeakReference<Session>? = null
	private var sessionPersistenceKey: String? = null

	@Volatile
	private var player: WeakReference<Player>? = null

	private var shuffle: Boolean = false

	override fun getName(): String {
		return NAME
	}

	// Example method
	// See https://reactnative.dev/docs/native-modules-android
	override fun doAThing() {
		Log.d(NAME, "We called a native function")
	}


	override fun initialize(options: ReadableMap?, promise: Promise) {
		try {
			val sharedPrefs = reactApplicationContext.getSharedPreferences("librespot", Context.MODE_PRIVATE)
			// TODO parse other login options
			val persistSession = options?.getDynamic("persistSession")
			var sessionPersistenceKey: String? = null
			if(persistSession?.type == ReadableType.Boolean) {
				if(persistSession.asBoolean()) {
					sessionPersistenceKey = "librespot_session";
				}
			} else if(persistSession?.type == ReadableType.String) {
				sessionPersistenceKey = persistSession.asString();
			}
			this.sessionPersistenceKey = sessionPersistenceKey
			this.session = WeakReference(createInitialSession(reactApplicationContext, this.sessionPersistenceKey))
			this.shuffle = sharedPrefs.getBoolean("librespot_shuffle", false)
		} catch(error: Throwable) {
			promise.reject(error)
			return
		}
		promise.resolve(null)
	}


	override fun login(promise: Promise) {
		CoroutineScope(Dispatchers.IO).launch {
			val loggedIn: Boolean
			try {
				loggedIn = loginAsync()
			} catch (e: Exception) {
				promise.reject("Librespot.LoginError", e)
				return@launch
			}
			promise.resolve(loggedIn)
		}
	}

	private suspend fun loginAsync(): Boolean {
		val session = createSessionWithOAuth(reactApplicationContext, this.sessionPersistenceKey)
		loginWithSession(session)
		return true
	}

	override fun loginWithUsernamePassword(username: String, password: String, promise: Promise) {
		try {
			val session = createSessionWithUsernamePassword(reactApplicationContext, username, password, this.sessionPersistenceKey);
			loginWithSession(session)
			promise.resolve(null)
		} catch(error: Exception) {
			promise.reject(error)
		}
	}

	override fun loginWithSession(map: ReadableMap, promise: Promise) {
		try {
			val accessToken = map.getString("accessToken")
			if(accessToken == null) {
				promise.reject("Librespot.MissingOption", "Missing accessToken")
				return
			}
			val session = createSessionWithAccessToken(reactApplicationContext, accessToken, this.sessionPersistenceKey)
			loginWithSession(session)
			promise.resolve(true)
		} catch(error: Exception) {
			promise.reject(error)
		}
	}

	private fun loginWithSession(session: Session) {
		val oldSession = this.session?.get();
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
		if(hadPlayer) {
			initPlayer()
		}
	}

	override fun logout() {
		val oldSession = this.session?.get()
		val hadPlayer = this.player?.get() != null
		val sessionPersistenceKey = this.sessionPersistenceKey
		if(sessionPersistenceKey != null) {
			val credentialsFile = getCredentialsFile(reactApplicationContext, sessionPersistenceKey)
			credentialsFile.delete()
		}
		// TODO figure out a way to swap sessions without interrupting the player
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
		this.session = WeakReference(createInitialSession(reactApplicationContext, sessionPersistenceKey))
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

		val session = this.session?.get() ?: createInitialSession(reactApplicationContext, this.sessionPersistenceKey)
		val player = Player(configuration, session)
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

		fun getCredentialsFile(context: Context, sessionPersistanceKey: String): File {
			return File(context.cacheDir, "$sessionPersistanceKey.json")
		}

		private data class SessionBuilderTuple(val builder: Session.Builder, val credentialsFile: File?)

		private fun createSessionBuilder(context: Context, sessionPersistenceKey: String?): SessionBuilderTuple {
			val cacheDir = context.cacheDir
			val credentialsFile = if (sessionPersistenceKey != null) getCredentialsFile(context, sessionPersistenceKey) else null
			val audioCacheDir = File(cacheDir, "librespot_audio_cache")

			var confBuilder = Session.Configuration.Builder()
				.setStoreCredentials(credentialsFile != null)
			if (credentialsFile != null) {
				confBuilder = confBuilder.setStoredCredentialsFile(credentialsFile)
			}
			val conf = confBuilder.setCacheEnabled(true)
				.setCacheDir(audioCacheDir)
				.build()

			val builder = Session.Builder(conf)
				.setPreferredLocale(Locale.getDefault().language)
				.setDeviceType(Connect.DeviceType.SMARTPHONE)
				.setDeviceId(null).setDeviceName("librespot-android")
			return SessionBuilderTuple(builder,credentialsFile)
		}

		fun createInitialSession(context: Context, sessionPersistenceKey: String?): Session {
			val (builder,credentialsFile) = createSessionBuilder(context, sessionPersistenceKey)
			if(credentialsFile != null) {
				return builder.stored(credentialsFile).create()
			}
			return builder.create()
		}

		fun createSessionWithAccessToken(context: Context, accessToken: String, sessionPersistenceKey: String?): Session {
			val (builder,_) = createSessionBuilder(context, sessionPersistenceKey)
			return builder.setClientToken(accessToken).create()
		}

		fun createSessionWithUsernamePassword(context: Context, username: String, password: String, sessionPersistenceKey: String?): Session {
			val (builder,_) = createSessionBuilder(context, sessionPersistenceKey)
			return builder.userPass(username, password).create()
		}

		/*fun createSessionFromMap(context: Context, map: ReadableMap, sessionPersistenceKey: String?): Session? {
			val clientID = LibrespotUtils.getOption("clientID", map)?.asString() ?: return null
			val accessToken = LibrespotUtils.getOption("accessToken", map)?.asString() ?: return null
			val expireTime = (LibrespotUtils.getOption("expireTime", map)?.asDouble() ?: return null) / 1000.0
			val scopes = LibrespotUtils.getOption("scopes", map)?.asArray()?.toArrayList()?.map { it.toString() } ?: return null
			val refreshToken = LibrespotUtils.getOption("refreshToken", map)?.asString()
			val (builder,_) = createSessionBuilder(context, sessionPersistenceKey)
			return builder.credentials() // TODO create from properties
		}*/

		suspend fun createSessionWithOAuth(context: Context, sessionPersistenceKey: String?): Session =
			withContext(Dispatchers.IO) {
			val (builder, _) = createSessionBuilder(context, sessionPersistenceKey)
			builder.oauth().create()
		}
	}
}
