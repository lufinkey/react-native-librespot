package com.librespot

import android.content.Context
import android.util.Log
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import com.spotify.connectstate.Connect
import xyz.gianlu.librespot.android.sink.AndroidSinkOutput
import xyz.gianlu.librespot.core.Session
import xyz.gianlu.librespot.player.Player
import xyz.gianlu.librespot.player.PlayerConfiguration
import java.io.File
import java.io.IOException
import java.lang.ref.WeakReference
import java.util.Locale
import kotlin.io.path.Path
import kotlin.io.path.deleteIfExists


@ReactModule(name = LibrespotModule.NAME)
class LibrespotModule(reactContext: ReactApplicationContext) :
	NativeLibrespotSpec(reactContext) {

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
		this.session = WeakReference(createSession(reactContext, this.storeCredentials, null))
	}


	override fun getName(): String {
		return NAME
	}

	// Example method
	// See https://reactnative.dev/docs/native-modules-android
	override fun doAThing() {
		Log.d(NAME, "We called a native function")
	}

	override fun login(accessToken: String, storeCredentials: Boolean, promise: Promise) {
		try {
			val session = createSession(reactApplicationContext, storeCredentials, accessToken);
			val oldSession = this.session.get();
			val hadPlayer = this.player?.get() != null;
			deinitPlayer()
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
			promise.resolve(null)
		} catch(error: Exception) {
			promise.reject(error);
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
		this.session = WeakReference(createSession(reactApplicationContext, false, null))
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
	}

	override fun deinitPlayer() {
		val p = this.player?.get();
		if (p != null) {
			Thread {
				p.close()
			}.start()
		}
		this.player = null
	}

	override fun loadTrack(trackId: String, startPlaying: Boolean) {
		val player = this.player?.get()
		if (player != null) {
			val trackURI = "spotify:track:$trackId"
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

	companion object {
		const val NAME = "Librespot"

		fun getCredentialsFile(context: Context): File {
			return File(context.cacheDir, "librespot_credentials.json")
		}

		fun createSession(context: Context, storeCredentials: Boolean, accessToken: String?): Session {
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

			if(accessToken != null) {
				return builder.setClientToken(accessToken).create();
			} else if(storeCredentials) {
				return builder.stored(credentialsFile).create();
			}
			return builder.create();
		}
	}
}
