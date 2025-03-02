package com.librespot

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = LibrespotModule.NAME)
class LibrespotModule(reactContext: ReactApplicationContext) :
	NativeLibrespotSpec(reactContext) {

	override fun getName(): String {
		return NAME
	}

	// Example method
	// See https://reactnative.dev/docs/native-modules-android
	override fun doAThing(a: Double, b: Double) {
		Log.e("We called a native function")
	}

	companion object {
		const val NAME = "Librespot"
	}
}
